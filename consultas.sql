
/*1. Ranking de Clientes: Listar los 10 clientes que más dinero han gastado en alquileres. La salida debe
mostrar: ID del cliente, Nombre Completo (concatenado), cantidad de películas alquiladas y el total
pagado.*/
SELECT TOP 10
    c.cliente_id,
    CONCAT(c.nombre, ' ', c.apellido) AS nombre_completo,
    COUNT(DISTINCT a.alquiler_id) AS cantidad_peliculas_alquiladas,
    SUM(p.monto) AS total_pagado
FROM cliente AS c
INNER JOIN alquiler AS a
    ON c.cliente_id = a.cliente_id
INNER JOIN pago AS p
    ON a.alquiler_id = p.alquiler_id
GROUP BY
    c.cliente_id,
    c.nombre,
    c.apellido
ORDER BY
    total_pagado DESC;
/*2. Rendimiento de Categorías por Tienda: Mostrar el total de ingresos generados por cada categoría de
película, desglosado por cada una de las tiendas del negocio.*/
SELECT
    t.tienda_id,
    c.categoria_id,
    c.nombre AS categoria,
    SUM(p.monto) AS total_ingresos
FROM pago AS p
INNER JOIN alquiler AS a
    ON p.alquiler_id = a.alquiler_id
INNER JOIN inventario AS i
    ON a.inventario_id = i.inventario_id
INNER JOIN tienda AS t
    ON i.tienda_id = t.tienda_id
INNER JOIN pelicula_categoria AS pc
    ON i.pelicula_id = pc.pelicula_id
INNER JOIN categoria AS c
    ON pc.categoria_id = c.categoria_id
GROUP BY
    t.tienda_id,
    c.categoria_id,
    c.nombre
ORDER BY
    t.tienda_id,
    total_ingresos DESC;
/*3. Análisis de Inventario No Retornado: Listar todas las películas (título y nombre de la tienda) que fueron
alquiladas hace más de 15 días y que aún no han sido devueltas (la columna return_date está vacía).
Incluir los datos del cliente que la tiene en su poder.*/
SELECT
    p.titulo,
    t.tienda_id,
    CONCAT(c.nombre, ' ', c.apellido) AS cliente,
    c.email,
    a.fecha_alquiler,
    DATEDIFF(DAY, a.fecha_alquiler, GETDATE()) AS dias_alquilada
FROM alquiler AS a
INNER JOIN inventario AS i
    ON a.inventario_id = i.inventario_id
INNER JOIN pelicula AS p
    ON i.pelicula_id = p.pelicula_id
INNER JOIN tienda AS t
    ON i.tienda_id = t.tienda_id
INNER JOIN cliente AS c
    ON a.cliente_id = c.cliente_id
WHERE
    a.fecha_devolucion IS NULL
    AND a.fecha_alquiler < DATEADD(DAY, -15, GETDATE())
ORDER BY
    a.fecha_alquiler;
/*4. Actores Versátiles: Encontrar aquellos actores que han participado en películas de al menos 5 categorías
diferentes. Mostrar el nombre del actor y la cantidad de categorías distintas en las que ha actuado.*/
SELECT
    a.actor_id,
    CONCAT(a.nombre, ' ', a.apellido) AS actor,
    COUNT(DISTINCT pc.categoria_id) AS cantidad_categorias
FROM actor AS a
INNER JOIN pelicula_actor AS pa
    ON a.actor_id = pa.actor_id
INNER JOIN pelicula_categoria AS pc
    ON pa.pelicula_id = pc.pelicula_id
GROUP BY
    a.actor_id,
    a.nombre,
    a.apellido
HAVING
    COUNT(DISTINCT pc.categoria_id) >= 5
ORDER BY
    cantidad_categorias DESC,
    actor;
/*5. Películas Populares vs. No Alquiladas: Generar un reporte que clasifique las películas en tres categorías
según su cantidad de alquileres: "Alta Demanda" (más de 30 alquileres), "Demanda Media" (entre 10 y 30
alquileres) y "Baja Demanda / Sin Alquileres" (menos de 10 alquileres). Ordenar el resultado de mayor a
menor popularidad.*/
SELECT
    p.pelicula_id,
    p.titulo,
    COUNT(a.alquiler_id) AS cantidad_alquileres,
    CASE
        WHEN COUNT(a.alquiler_id) > 30
            THEN 'Alta Demanda'
        WHEN COUNT(a.alquiler_id) BETWEEN 10 AND 30
            THEN 'Demanda Media'
        ELSE 'Baja Demanda / Sin Alquileres'
    END AS clasificacion_demanda
FROM pelicula AS p
LEFT JOIN inventario AS i
    ON p.pelicula_id = i.pelicula_id
LEFT JOIN alquiler AS a
    ON i.inventario_id = a.inventario_id
GROUP BY
    p.pelicula_id,
    p.titulo
ORDER BY
    cantidad_alquileres DESC,
    p.titulo;