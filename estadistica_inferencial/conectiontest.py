import pyodbc

# ⚙️ CONFIGURA TU CONEXIÓN AQUÍ
server   = r'OCYRIZ'  # Si tu instancia tiene nombre usa: r'OCYRIZ\SQLEXPRESS'
database = 'Estadistica_Inferencial'
driver   = '{ODBC Driver 17 for SQL Server}'  # Cambia a 18 si ese es tu driver

# 🔹 Para Windows Authentication:
conn_str = f'DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;'

print("Intentando conectar a SQL Server...\n")
try:
    cnxn = pyodbc.connect(conn_str)
    cursor = cnxn.cursor()
    cursor.execute("SELECT COUNT(*) FROM dbo.Habitos_de_estudio;")
    result = cursor.fetchone()
    print(f"✅ Conexión exitosa. Total de registros en tabla: {result[0]}")
    cnxn.close()
except Exception as e:
    print("❌ Error al conectar:")
    print(e)
