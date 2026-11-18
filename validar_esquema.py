
from esquema import ESQUEMA
from config_conexion import conectar_sql_server

# 1. Conectarnos a SQL Server utilizando la función centralizada
conexion = conectar_sql_server()

cursor = conexion.cursor()

print("VALIDACIÓN DE COLUMNAS")
print("-" * 50)

errores = 0

# 2. Recorrer las tablas del diccionario
for nombre_original, datos in ESQUEMA.items():

    nombre_fisico = datos["tabla"]

    # Obtener las columnas reales de SQL Server
    cursor.execute("""
        SELECT COLUMN_NAME
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'dbo'
          AND TABLE_NAME = ?
    """, (nombre_fisico,))

    columnas_reales = {
        fila[0] for fila in cursor.fetchall()
    }

    # Comparar con las columnas del diccionario
    columnas_esperadas = set(datos["columnas"].values())

    faltantes = columnas_esperadas - columnas_reales

    if faltantes:
        errores += len(faltantes)
        print(f"{nombre_original}: ERROR")
        print(f"  Columnas faltantes: {faltantes}")
    else:
        print(f"{nombre_original}: OK")

# 3. Mostrar resultado final
print("-" * 50)
print(f"Columnas faltantes: {errores}")

cursor.close()
conexion.close()
