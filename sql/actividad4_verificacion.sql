-- TP2 - ACTIVIDAD 4
-- Verificación de la carga del pipeline ETL
-- Base utilizada: Sakila_Espanol

USE Sakila_Espanol;
GO

-- 1. Verificar la cantidad de registros
SELECT COUNT(*) AS cantidad_registros
FROM dbo.TP2_RendimientoComercial;

-- 2. Verificar los indicadores cargados
SELECT *
FROM dbo.TP2_RendimientoComercial
ORDER BY tienda_id, empleado_id;