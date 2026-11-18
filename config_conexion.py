
import os
import mssql_python
from dotenv import load_dotenv

# Cargar las variables de conexión desde .env
load_dotenv()


def conectar_sql_server():
    """Devuelve una conexión abierta a SQL Server."""

    servidor = os.getenv("DB_SERVER")
    puerto = os.getenv("DB_PORT")
    base_datos = os.getenv("DB_NAME")
    usuario = os.getenv("DB_USER")
    contrasena = os.getenv("DB_PASSWORD")

    conexion = mssql_python.connect(
        f"SERVER={servidor},{puerto};"
        f"DATABASE={base_datos};"
        f"UID={usuario};"
        f"PWD={contrasena};"
        "Encrypt=yes;"
        "TrustServerCertificate=yes;"
    )

    return conexion
