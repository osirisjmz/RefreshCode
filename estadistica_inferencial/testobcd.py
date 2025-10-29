import pyodbc

# 🔧 reemplaza con tu configuración real
server = r'OCYRIZ\SQLEXPRESS'      # pon tu instancia exacta
database = 'Estadistica_Inferencial'
driver = '{ODBC Driver 17 for SQL Server}'  # o 18 si es el tuyo

try:
    print("Intentando conectar...")
    cnxn = pyodbc.connect(
        f'DRIVER={driver};SERVER={server};DATABASE={database};Trusted_Connection=yes;Encrypt=no;'
    )
    print("✅ Conexión exitosa!")
    cursor = cnxn.cursor()
    cursor.execute("SELECT TOP 5 * FROM dbo.Habitos_de_estudio;")
    rows = cursor.fetchall()
    for r in rows:
        print(r)
    cnxn.close()
except Exception as e:
    print("❌ Error al conectar:")
    print(e)
