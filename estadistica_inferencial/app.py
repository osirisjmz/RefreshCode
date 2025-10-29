from flask import Flask, render_template, jsonify
import pyodbc
import pandas as pd
import numpy as np
from scipy import stats

# ====== CONFIG ======
# Conexión a SQL Server (Windows Authentication)
server   = r'OCYRIZ'                # o r'OCYRIZ\SQLEXPRESS' si así te conectaste
database = 'Estadistica_Inferencial'
driver   = '{ODBC Driver 17 for SQL Server}'
CNSTR = f'DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;Encrypt=no;'


app = Flask(__name__)

def fetch_df(query: str) -> pd.DataFrame:
    with pyodbc.connect(CNSTR) as cn:
        return pd.read_sql(query, cn)

def load_data() -> pd.DataFrame:
    q = """
        SELECT id_estudiante, turno, genero, promedio, horas_estudio,
               aprobacion, herramientas_digitales, lugar_estudio
        FROM dbo.Habitos_de_estudio;
    """
    df = fetch_df(q)
    # normalizamos strings por si acaso
    for c in ['turno','genero','aprobacion','herramientas_digitales','lugar_estudio']:
        df[c] = df[c].astype(str).str.strip().str.lower()
    return df

# === METRICAS / PRUEBAS ===
def compute_metrics(df: pd.DataFrame):
    # --- descriptivos por turno ---
    g = df.groupby('turno')['promedio']
    desc = g.agg(['count','mean','std']).reset_index()
    # sacamos en el orden manana/tarde si existen
    def safe(v): return float(v) if pd.notna(v) else np.nan

    prom_m = df.loc[df['turno']=='manana','promedio'].astype(float).values
    prom_t = df.loc[df['turno']=='tarde','promedio'].astype(float).values
    n_m, n_t = len(prom_m), len(prom_t)
    xbar_m, xbar_t = np.mean(prom_m), np.mean(prom_t)
    sd_m, sd_t = np.std(prom_m, ddof=1), np.std(prom_t, ddof=1)

    # Levene
    levene_stat, levene_p = stats.levene(prom_m, prom_t, center='mean')

    # Welch t
    SE = np.sqrt(sd_m**2/n_m + sd_t**2/n_t)
    t_w = (xbar_m - xbar_t) / SE
    df_w = (sd_m**2/n_m + sd_t**2/n_t)**2 / ((sd_m**2/n_m)**2/(n_m-1) + (sd_t**2/n_t)**2/(n_t-1))
    p_w = 2*stats.t.sf(np.abs(t_w), df=df_w)

    # Hedges g
    sp2 = ((n_m-1)*sd_m**2 + (n_t-1)*sd_t**2) / (n_m+n_t-2)
    sp  = np.sqrt(sp2)
    d   = (xbar_m - xbar_t)/sp
    J   = 1 - (3/(4*(n_m+n_t)-9))
    g_hedges = d*J

    # --- proporciones de aprobación ---
    ap_m = (df.loc[df['turno']=='manana','aprobacion']=='aprobo').sum()
    ap_t = (df.loc[df['turno']=='tarde','aprobacion']=='aprobo').sum()
    p1 = ap_m/n_m
    p2 = ap_t/n_t
    p_pool = (ap_m+ap_t)/(n_m+n_t)
    SEp = np.sqrt(p_pool*(1-p_pool)*(1/n_m + 1/n_t))
    z = (p1 - p2)/SEp
    p_prop = 2*(1 - stats.norm.cdf(abs(z)))
    # Wald CI
    def wald_ci(x,n,alpha=0.05):
        ph = x/n
        zc = stats.norm.ppf(1-alpha/2)
        se = np.sqrt(ph*(1-ph)/n)
        return (ph - zc*se, ph + zc*se)
    ci_m = wald_ci(ap_m, n_m)
    ci_t = wald_ci(ap_t, n_t)

    # --- chi-cuadrado ---
    # Turno x Lugar
    tab_lugar = pd.crosstab(df['turno'], df['lugar_estudio'])
    chi_l, p_l, dof_l, exp_l = stats.chi2_contingency(tab_lugar)

    # Genero x Herramientas (2x2 => con Yates por default)
    tab_h = pd.crosstab(df['genero'], df['herramientas_digitales'])
    chi_h, p_h, dof_h, exp_h = stats.chi2_contingency(tab_h)

    # --- Shapiro ---
    sh_global = stats.shapiro(df['promedio'])
    sh_m = stats.shapiro(prom_m)
    sh_t = stats.shapiro(prom_t)

    return {
        "desc": desc.to_dict(orient='records'),
        "t_test": {
            "n_m": int(n_m), "n_t": int(n_t),
            "mean_m": xbar_m, "mean_t": xbar_t,
            "sd_m": sd_m, "sd_t": sd_t,
            "levene_stat": levene_stat, "levene_p": levene_p,
            "SE": SE, "t": t_w, "df": df_w, "p": p_w, "hedges_g": g_hedges
        },
        "prop": {
            "ap_m": int(ap_m), "ap_t": int(ap_t),
            "p1": p1, "p2": p2, "p_pool": p_pool,
            "SE": SEp, "z": z, "p": p_prop,
            "ci_m": ci_m, "ci_t": ci_t
        },
        "chi2": {
            "turno_lugar": {
                "table": tab_lugar.to_dict(),
                "chi2": chi_l, "p": p_l, "dof": int(dof_l)
            },
            "genero_herr": {
                "table": tab_h.to_dict(),
                "chi2": chi_h, "p": p_h, "dof": int(dof_h)
            }
        },
        "shapiro": {
            "global": {"W": sh_global.statistic, "p": sh_global.pvalue},
            "manana": {"W": sh_m.statistic, "p": sh_m.pvalue},
            "tarde":  {"W": sh_t.statistic, "p": sh_t.pvalue},
        }
    }

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/metrics')
def api_metrics():
    df = load_data()
    metrics = compute_metrics(df)
    # también mandamos series para gráficas
    means = df.groupby('turno')['promedio'].mean().reindex(['manana','tarde']).fillna(0)
    aprob = df.assign(apr=(df['aprobacion']=='aprobo').astype(int)) \
              .groupby('turno')['apr'].mean().reindex(['manana','tarde']).fillna(0)
    # Turno x Lugar (para barras apiladas)
    txl = pd.crosstab(df['turno'], df['lugar_estudio']).reindex(['manana','tarde']).fillna(0)
    metrics.update({
        "chart_means": {"labels": list(means.index), "data": list(means.values)},
        "chart_approvals": {"labels": list(aprob.index), "data": list(aprob.values)},
        "chart_turno_lugar": {
            "labels": list(txl.columns),
            "series": [
                {"name": "manana", "data": list(txl.loc['manana'].values)},
                {"name": "tarde",  "data": list(txl.loc['tarde'].values)}
            ]
        }
    })
    # redondeos para UI
    def rnd(x): 
        try: return round(float(x),4)
        except: return x
    def deep_round(o):
        if isinstance(o, dict): return {k: deep_round(v) for k,v in o.items()}
        if isinstance(o, list): return [deep_round(v) for v in o]
        return rnd(o)
    return jsonify(deep_round(metrics))

if __name__ == '__main__':
    app.run(debug=True)