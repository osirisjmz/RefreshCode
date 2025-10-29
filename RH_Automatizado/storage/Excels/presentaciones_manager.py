# ============================================================
# presentaciones_manager.py
# ------------------------------------------------------------
# Autor: Osiris Jiménez
# Descripción:
#   Maneja los registros post-entrevista de los candidatos.
#   Incluye confirmación de entrevista, días 1 y 2 de asistencia
#   y encuesta de inducción para control de calidad.
# ============================================================

import os
import pandas as pd
from datetime import datetime

# Ruta base (ajusta si usas sincronización con Drive)
BASE_PATH = r"C:\Users\Ocyriz\Drive\Vacantes\Excels"
CANDIDATOS_PATH = os.path.join(BASE_PATH, "Candidatos.xlsx")

# ------------------------------------------------------------
# Funciones auxiliares
# ------------------------------------------------------------
def load_candidatos():
    """Carga el archivo de candidatos o crea uno nuevo si no existe."""
    if not os.path.exists(CANDIDATOS_PATH):
        cols = [
            "ID_Candidato", "Nombre", "Edad", "Vacante_ID", "RutaTransporte",
            "TurnoDeseado", "Telefono", "Escolaridad", "Estado",
            "Fecha_Entrevista", "Presentado", "Contratado",
            "Dia1_Asistencia", "Dia2_Asistencia",
            "Induccion_Rating", "Induccion_Comentarios",
            "Quien_Atendio_Induccion", "Evidencia_Path", "Notas"
        ]
        df = pd.DataFrame(columns=cols)
        df.to_excel(CANDIDATOS_PATH, index=False)
    else:
        df = pd.read_excel(CANDIDATOS_PATH)
    return df

def save_candidatos(df):
    """Guarda los cambios en el archivo Excel."""
    df.to_excel(CANDIDATOS_PATH, index=False)
    print("✅ Cambios guardados correctamente en Candidatos.xlsx")

def find_candidate(df, id_candidato):
    """Busca un candidato por ID."""
    match = df[df["ID_Candidato"] == id_candidato]
    if match.empty:
        print(f"⚠️ No se encontró el candidato con ID {id_candidato}")
        return None
    return match.index[0]

# ------------------------------------------------------------
# Operaciones principales
# ------------------------------------------------------------
def registrar_presentacion(id_candidato, asistio=True):
    """Marca si el candidato asistió a la entrevista."""
    df = load_candidatos()
    idx = find_candidate(df, id_candidato)
    if idx is None:
        return
    df.loc[idx, "Presentado"] = "Sí" if asistio else "No"
    df.loc[idx, "Estado"] = "Presentado" if asistio else "No asistió"
    df.loc[idx, "Fecha_Entrevista"] = datetime.now().strftime("%Y-%m-%d %H:%M")
    save_candidatos(df)
    print(f"📅 Entrevista {'asistida' if asistio else 'no asistida'} para {id_candidato}")

def registrar_contratacion(id_candidato, contratado=True):
    """Marca si fue contratado después de la entrevista."""
    df = load_candidatos()
    idx = find_candidate(df, id_candidato)
    if idx is None:
        return
    df.loc[idx, "Contratado"] = "Sí" if contratado else "No"
    df.loc[idx, "Estado"] = "Contratado" if contratado else "No Contratado"
    save_candidatos(df)
    print(f"💼 Candidato {id_candidato} {'contratado' if contratado else 'no contratado'}")

def registrar_asistencia_dia(id_candidato, dia=1, asistio=True):
    """Registra asistencia en Día 1 o Día 2."""
    df = load_candidatos()
    idx = find_candidate(df, id_candidato)
    if idx is None:
        return
    col = f"Dia{dia}_Asistencia"
    df.loc[idx, col] = "Sí" if asistio else "No"
    df.loc[idx, "Estado"] = "En capacitación" if asistio else "Ausente"
    save_candidatos(df)
    print(f"🗓️ Día {dia}: {'asistió' if asistio else 'ausente'} → {id_candidato}")

def registrar_encuesta_induccion(id_candidato, rating, comentarios, quien_atendio, evidencia_path=None):
    """Guarda calificación de inducción / entrenamiento."""
    df = load_candidatos()
    idx = find_candidate(df, id_candidato)
    if idx is None:
        return
    df.loc[idx, "Induccion_Rating"] = rating
    df.loc[idx, "Induccion_Comentarios"] = comentarios
    df.loc[idx, "Quien_Atendio_Induccion"] = quien_atendio
    df.loc[idx, "Evidencia_Path"] = evidencia_path or ""
    df.loc[idx, "Estado"] = "Evaluado"
    save_candidatos(df)
    print(f"⭐ Encuesta de inducción registrada para {id_candidato} (rating {rating})")

# ------------------------------------------------------------
# Ejemplo de uso manual
# ------------------------------------------------------------
if __name__ == "__main__":
    # Ejemplo de flujo:
    registrar_presentacion("CAND-0003", asistio=True)
    registrar_contratacion("CAND-0003", contratado=True)
    registrar_asistencia_dia("CAND-0003", dia=1, asistio=True)
    registrar_asistencia_dia("CAND-0003", dia=2, asistio=True)
    registrar_encuesta_induccion(
        "CAND-0003",
        rating=5,
        comentarios="Excelente inducción, personal amable y proceso rápido.",
        quien_atendio="María Hernández",
        evidencia_path=r"C:\Users\Ocyriz\Drive\Vacantes\Evidencias\CAND-0003_foto.jpg"
    )
