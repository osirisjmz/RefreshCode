# db_connection.py
import pyodbc

def get_connection():
    try:
        connection = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=OCYRIZ;'
            'DATABASE=BibliotecaUniversitaria;'
            'Trusted_Connection=yes;'
        )
        print("✅ Conexión exitosa a la base de datos.")
        return connection
    except Exception as e:
        print("❌ Error de conexión:", e)
        return None
