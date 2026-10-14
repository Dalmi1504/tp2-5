import os
import logging

import pandas as pd
import mssql_python
from dotenv import load_dotenv
from esquema import nombre_tabla_sql, nombre_columna_sql


# Cargar las variables de conexión desde .env
load_dotenv()

# Configurar el registro de actividad
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def conectar_sql_server():
    """Establece la conexión con SQL Server."""
    logger.info("Conectando a SQL Server...")

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

    logger.info("Conexión establecida correctamente.")
    return conexion


def extraer_sql_server(conexion):
    """Extrae los pagos y sus datos comerciales de SQL Server."""
    logger.info("Iniciando extracción desde SQL Server...")

    # Los identificadores provienen exclusivamente del diccionario esquema.py.
    # Los alias conservan los nombres internos usados por pandas.
    consulta = f"""
        SELECT
            p.{nombre_columna_sql('payment', 'payment_id')} AS pago_id,
            p.{nombre_columna_sql('payment', 'staff_id')} AS empleado_id,
            p.{nombre_columna_sql('payment', 'customer_id')} AS cliente_id,
            p.{nombre_columna_sql('payment', 'amount')} AS monto,
            e.{nombre_columna_sql('staff', 'store_id')} AS tienda_id
        FROM {nombre_tabla_sql('payment')} AS p
        LEFT JOIN {nombre_tabla_sql('staff')} AS e
            ON p.{nombre_columna_sql('payment', 'staff_id')}
             = e.{nombre_columna_sql('staff', 'staff_id')}
    """

    df_pagos = pd.read_sql(consulta, conexion)
    logger.info("Extracción finalizada: %s pagos obtenidos.", len(df_pagos))
    return df_pagos


def extraer_csv():
    """Extrae las metas comerciales desde un archivo CSV."""
    logger.info("Iniciando extracción del archivo CSV...")

    ruta_csv = os.path.join(
        os.path.dirname(os.path.abspath(__file__)),
        "metas_comerciales.csv"
    )
    df_metas = pd.read_csv(ruta_csv)

    logger.info("Extracción CSV finalizada: %s filas obtenidas.", len(df_metas))
    return df_metas


def controlar_empleados_sin_operaciones(conexion):
    """Detecta empleados que no tienen pagos registrados."""
    logger.info("Iniciando control de empleados sin operaciones...")

    consulta = f"""
        SELECT
            e.{nombre_columna_sql('staff', 'staff_id')} AS empleado_id,
            e.{nombre_columna_sql('staff', 'store_id')} AS tienda_id
        FROM {nombre_tabla_sql('staff')} AS e
        LEFT JOIN {nombre_tabla_sql('payment')} AS p
            ON e.{nombre_columna_sql('staff', 'staff_id')}
             = p.{nombre_columna_sql('payment', 'staff_id')}
        WHERE p.{nombre_columna_sql('payment', 'payment_id')} IS NULL
    """

    df_sin_operaciones = pd.read_sql(consulta, conexion)
    logger.info(
        "Control finalizado: %s empleados sin operaciones.",
        len(df_sin_operaciones)
    )
    return df_sin_operaciones


def controlar_clientes_dos_tiendas(df_pagos):
    """Detecta clientes con pagos atendidos por ambas tiendas."""
    logger.info("Iniciando control de clientes en ambas tiendas...")

    tiendas_por_cliente = (
        df_pagos.dropna(subset=["cliente_id", "tienda_id"])
        .groupby("cliente_id")["tienda_id"]
        .nunique()
    )
    clientes_dos_tiendas = tiendas_por_cliente[tiendas_por_cliente > 1]

    logger.info(
        "Control finalizado: %s clientes operaron en ambas tiendas.",
        len(clientes_dos_tiendas)
    )
    return clientes_dos_tiendas


def transformar_datos(df_pagos, df_metas):
    """Limpia los pagos y calcula las métricas comerciales."""
    logger.info("Iniciando transformación de datos...")

    pagos_invalidos = df_pagos[
        df_pagos["empleado_id"].isna()
        | df_pagos["tienda_id"].isna()
    ]
    logger.info("Pagos sin empleado o tienda válida: %s", len(pagos_invalidos))

    df_limpio = df_pagos.dropna(
        subset=["empleado_id", "tienda_id", "monto"]
    ).copy()
    logger.info("Pagos válidos para el análisis: %s", len(df_limpio))

    df_resultado = (
        df_limpio.groupby(["tienda_id", "empleado_id"], as_index=False)
        .agg(
            ingreso_total=("monto", "sum"),
            cantidad_operaciones=("pago_id", "count")
        )
    )

    df_resultado["ticket_promedio"] = (
        df_resultado["ingreso_total"] / df_resultado["cantidad_operaciones"]
    )

    df_resultado = df_resultado.merge(
        df_metas,
        on="tienda_id",
        how="left",
        validate="many_to_one"
    )

    df_resultado["total_tienda"] = (
        df_resultado.groupby("tienda_id")["ingreso_total"].transform("sum")
    )

    df_resultado["participacion_empleado_pct"] = (
        df_resultado["ingreso_total"] / df_resultado["total_tienda"] * 100
    )

    total_negocio = df_resultado["ingreso_total"].sum()
    df_resultado["participacion_tienda_pct"] = (
        df_resultado["total_tienda"] / total_negocio * 100
    )

    df_resultado["cumplimiento_meta_pct"] = (
        df_resultado["total_tienda"] / df_resultado["meta_ingresos"] * 100
    )

    logger.info("Transformación finalizada: %s filas generadas.", len(df_resultado))
    return df_resultado


def crear_tabla_destino(conexion):
    """Crea la tabla destino si todavía no existe."""
    logger.info("Verificando tabla destino...")

    consulta = """
    IF OBJECT_ID('dbo.TP2_RendimientoComercial', 'U') IS NULL
    BEGIN
        CREATE TABLE dbo.TP2_RendimientoComercial (
            tienda_id INT NOT NULL,
            empleado_id INT NOT NULL,
            ingreso_total DECIMAL(18, 2) NOT NULL,
            cantidad_operaciones INT NOT NULL,
            ticket_promedio DECIMAL(18, 4) NOT NULL,
            meta_ingresos DECIMAL(18, 2) NULL,
            total_tienda DECIMAL(18, 2) NOT NULL,
            participacion_empleado_pct DECIMAL(9, 4) NOT NULL,
            participacion_tienda_pct DECIMAL(9, 4) NOT NULL,
            cumplimiento_meta_pct DECIMAL(9, 4) NULL,
            CONSTRAINT PK_TP2_RendimientoComercial
                PRIMARY KEY (tienda_id, empleado_id)
        )
    END
    """

    cursor = conexion.cursor()
    try:
        cursor.execute(consulta)
        conexion.commit()
        logger.info("Tabla destino verificada correctamente.")
    finally:
        cursor.close()


def cargar_datos(conexion, df_resultado):
    """Carga los resultados de forma idempotente en SQL Server."""
    logger.info("Iniciando carga de datos...")

    consulta_insertar = """
        INSERT INTO dbo.TP2_RendimientoComercial (
            tienda_id,
            empleado_id,
            ingreso_total,
            cantidad_operaciones,
            ticket_promedio,
            meta_ingresos,
            total_tienda,
            participacion_empleado_pct,
            participacion_tienda_pct,
            cumplimiento_meta_pct
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """

    columnas = [
        "tienda_id",
        "empleado_id",
        "ingreso_total",
        "cantidad_operaciones",
        "ticket_promedio",
        "meta_ingresos",
        "total_tienda",
        "participacion_empleado_pct",
        "participacion_tienda_pct",
        "cumplimiento_meta_pct"
    ]

    df_carga = df_resultado[columnas].astype(object)
    df_carga = df_carga.where(pd.notna(df_carga), None)

    registros = []
    for fila in df_carga.itertuples(index=False, name=None):
        registro = tuple(
            valor.item() if hasattr(valor, "item") else valor
            for valor in fila
        )
        registros.append(registro)

    cursor = conexion.cursor()
    try:
        cursor.execute("DELETE FROM dbo.TP2_RendimientoComercial")
        if registros:
            cursor.executemany(consulta_insertar, registros)
        conexion.commit()
        logger.info("Carga finalizada: %s filas insertadas.", len(registros))
    except Exception:
        conexion.rollback()
        logger.exception("Error durante la carga de datos.")
        raise
    finally:
        cursor.close()


def ejecutar_etl():
    """Coordina todas las etapas del pipeline ETL."""
    conexion = None
    try:
        logger.info("========== INICIO DEL ETL ==========")
        conexion = conectar_sql_server()

        df_pagos = extraer_sql_server(conexion)
        df_metas = extraer_csv()

        controlar_empleados_sin_operaciones(conexion)
        controlar_clientes_dos_tiendas(df_pagos)

        df_resultado = transformar_datos(df_pagos, df_metas)

        crear_tabla_destino(conexion)
        cargar_datos(conexion, df_resultado)

        logger.info("========== FIN DEL ETL ==========")
    except Exception:
        logger.exception("El pipeline ETL falló.")
        raise
    finally:
        if conexion is not None:
            conexion.close()
            logger.info("Conexión con SQL Server cerrada.")


if __name__ == "__main__":
    ejecutar_etl()
