
-- TP2 - SAKILA | ACTIVIDAD 1  CONSULTAS SQL
-- Variante 5: Rendimiento comercial por tienda y empleado
-- IMPORTANTE:
-- Ejecutar estas consultas con la base Sakila correspondiente
-- seleccionada en SQL Server.
-- Este archivo contiene las consultas SQL de referencia
-- para nuestra base actual.
-- Para la portabilidad entre equipos, las consultas ejecutadas
-- desde Python deben obtener los nombres físicos de esquema.py.

-- CLASIFICACIÓN:
-- Consulta 1: relación entre pagos, empleados y tiendas.
-- Consulta 2: control de pagos sin empleado.
-- Consulta 3: control de empleados sin operaciones.
-- Consulta 4: clientes con pagos en ambas tiendas.
-- Consulta 5: distribución de clientes por tienda.
-- Consulta 6: métricas comerciales por empleado.
-- Consulta 7: participación de empleados y tiendas.
-- Consulta 8: validación SQL vs pandas.
-- Consulta 9: pagos individuales para pandas.



-- CONSULTA 1: RELACIÓN ENTRE PAGOS, EMPLEADOS Y TIENDAS

-- Pregunta:
-- ¿Podemos identificar qué empleado procesó cada pago
-- y a qué tienda pertenece?

-- Objetivo:
-- Comprobar las relaciones entre las tablas pago y empleado
-- y visualizar los primeros 10 registros.

SELECT TOP (10)
    p.pago_id,
    p.monto,
    p.fecha_pago,
    p.empleado_id,
    e.nombre AS empleado_nombre,
    e.apellido AS empleado_apellido,
    e.tienda_id
FROM pago AS p
LEFT JOIN empleado AS e
    ON p.empleado_id = e.empleado_id
ORDER BY p.pago_id;


-- CONSULTA 2: CONTROL DE PAGOS SIN EMPLEADO

-- Preguntas:
-- ¿Cuántos pagos existen?
-- ¿Hay pagos sin un empleado válido?

-- Objetivo:
-- Identificar pagos que no puedan asociarse con un empleado.

SELECT
    COUNT(*) AS total_pagos,
    SUM(
        CASE
            WHEN e.empleado_id IS NULL THEN 1
            ELSE 0
        END
    ) AS pagos_sin_empleado
FROM pago AS p
LEFT JOIN empleado AS e
    ON p.empleado_id = e.empleado_id;


-- CONSULTA 3: CONTROL DE EMPLEADOS SIN OPERACIONES

-- Preguntas:
-- ¿Cuántas operaciones registró cada empleado?
-- ¿Existen empleados sin pagos?

-- Objetivo:
-- Contar operaciones por empleado, incluyendo aquellos
-- que no hayan registrado ninguna.
--
-- LEFT JOIN permite conservar empleados sin pagos.

SELECT
    e.empleado_id,
    e.nombre,
    e.apellido,
    e.tienda_id,
    COUNT(p.pago_id) AS cantidad_operaciones
FROM empleado AS e
LEFT JOIN pago AS p
    ON e.empleado_id = p.empleado_id
GROUP BY
    e.empleado_id,
    e.nombre,
    e.apellido,
    e.tienda_id
ORDER BY e.empleado_id;



-- CONSULTA 4: CLIENTES CON PAGOS EN AMBAS TIENDAS

-- Preguntas:
-- ¿Existen clientes cuyos pagos fueron procesados
-- por empleados de ambas tiendas?
-- ¿En cuántas tiendas distintas registraron pagos?

-- Aclaración:
-- Se considera la tienda del empleado que procesó el pago,
-- no necesariamente la tienda asignada al cliente.

SELECT
    p.cliente_id,
    COUNT(DISTINCT e.tienda_id) AS tiendas_distintas
FROM pago AS p
INNER JOIN empleado AS e
    ON p.empleado_id = e.empleado_id
GROUP BY p.cliente_id
HAVING COUNT(DISTINCT e.tienda_id) > 1
ORDER BY p.cliente_id;



-- CONSULTA 5: DISTRIBUCIÓN DE CLIENTES POR TIENDA

-- Preguntas:
-- ¿Cuántos clientes están registrados en cada tienda?
-- ¿Cómo se distribuyen entre las sucursales?

-- Objetivo:
-- Diferenciar la tienda asignada al cliente de la tienda
-- del empleado que procesa sus pagos.

SELECT
    c.tienda_id AS tienda_asignada,
    COUNT(*) AS cantidad_clientes
FROM cliente AS c
GROUP BY c.tienda_id
ORDER BY c.tienda_id;



-- CONSULTA 6: MÉTRICAS COMERCIALES POR EMPLEADO

-- Preguntas:
-- ¿Cuántas operaciones procesó cada empleado?
-- ¿Cuánto dinero representan?
-- ¿Cuál es el importe promedio por pago?

-- Métricas:
-- COUNT(): cantidad de operaciones.
-- SUM(): ingreso total.
-- AVG(): ticket promedio.

SELECT
    e.empleado_id,
    e.nombre,
    e.apellido,
    e.tienda_id,
    COUNT(p.pago_id) AS cantidad_operaciones,
    COALESCE(SUM(p.monto), 0) AS ingreso_total,
    AVG(p.monto) AS ticket_promedio
FROM empleado AS e
LEFT JOIN pago AS p
    ON e.empleado_id = p.empleado_id
GROUP BY
    e.empleado_id,
    e.nombre,
    e.apellido,
    e.tienda_id
ORDER BY e.tienda_id, e.empleado_id;



-- CONSULTA 7: PARTICIPACIÓN DE EMPLEADOS Y TIENDAS

-- Preguntas:
-- ¿Qué porcentaje de los ingresos de su tienda
-- representa cada empleado?
-- ¿Qué porcentaje del ingreso total representa cada tienda?

-- Funciones de ventana:
-- SUM(...) OVER (PARTITION BY tienda_id):
-- Calcula el ingreso total de cada tienda.

-- SUM(...) OVER ():
-- Calcula el ingreso total del negocio.

-- NULLIF():
-- Evita divisiones por cero.

WITH rendimiento AS (
    SELECT
        e.empleado_id,
        e.nombre,
        e.apellido,
        e.tienda_id,
        COUNT(p.pago_id) AS cantidad_operaciones,
        COALESCE(SUM(p.monto), 0) AS ingreso_total,
        AVG(p.monto) AS ticket_promedio
    FROM empleado AS e
    LEFT JOIN pago AS p
        ON e.empleado_id = p.empleado_id
    GROUP BY
        e.empleado_id,
        e.nombre,
        e.apellido,
        e.tienda_id
),
participaciones AS (
    SELECT
        *,
        SUM(ingreso_total) OVER (
            PARTITION BY tienda_id
        ) AS ingreso_tienda,
        SUM(ingreso_total) OVER () AS ingreso_negocio
    FROM rendimiento
)
SELECT
    empleado_id,
    nombre,
    apellido,
    tienda_id,
    cantidad_operaciones,
    ingreso_total,
    ticket_promedio,
    100.0 * ingreso_total
        / NULLIF(ingreso_tienda, 0)
        AS porcentaje_empleado_tienda,
    100.0 * ingreso_tienda
        / NULLIF(ingreso_negocio, 0)
        AS porcentaje_tienda_negocio
FROM participaciones
ORDER BY tienda_id, empleado_id;



-- CONSULTA 8: VALIDACIÓN SQL VS PANDAS

-- Pregunta:
-- ¿Coinciden los ingresos y las cantidades de pagos
-- calculados en SQL Server con los calculados en pandas?

-- Objetivo:
-- Obtener las métricas agrupadas en SQL Server
-- para compararlas con pandas en el notebook.

-- El notebook también debe medir los tiempos de ejecución.

SELECT
    e.tienda_id,
    p.empleado_id,
    COUNT(*) AS cantidad_pagos,
    SUM(p.monto) AS ingresos_sql
FROM pago AS p
INNER JOIN empleado AS e
    ON p.empleado_id = e.empleado_id
GROUP BY
    e.tienda_id,
    p.empleado_id
ORDER BY
    e.tienda_id,
    p.empleado_id;



-- CONSULTA 9: PAGOS INDIVIDUALES PARA PANDAS

-- Objetivo:
-- Obtener los pagos individuales y la tienda del empleado
-- que procesó cada operación.

-- Este conjunto no está agrupado porque pandas debe
-- realizar el agrupamiento para comparar los resultados
-- con SQL Server.

SELECT
    p.pago_id,
    p.empleado_id,
    p.cliente_id,
    p.monto,
    e.tienda_id
FROM pago AS p
LEFT JOIN empleado AS e
    ON p.empleado_id = e.empleado_id;
