
from config_conexion import conectar_sql_server

try:
    conexion = conectar_sql_server()

    cursor = conexion.cursor()
    cursor.execute("SELECT DB_NAME()")
    resultado = cursor.fetchone()

    print("¡Conexión exitosa!")
    print("Base de datos:", resultado[0])

    cursor.close()
    conexion.close()

except Exception as error:
    print("Error al conectar:", error)
