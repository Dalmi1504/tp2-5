CREATE DATABASE Sakila_Espanol;
GO

USE Sakila_Espanol;
GO

CREATE TABLE actor (
    actor_id SMALLINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    apellido VARCHAR(45) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (actor_id)
);
GO

CREATE INDEX idx_actor_apellido
ON actor(apellido);
GO

CREATE TABLE categoria (
    categoria_id TINYINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(25) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (categoria_id)
);
GO

CREATE TABLE pais (
    pais_id SMALLINT IDENTITY(1,1) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY (pais_id)
);
GO

CREATE TABLE ciudad (
    ciudad_id SMALLINT IDENTITY(1,1) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    pais_id SMALLINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_ciudad
        PRIMARY KEY (ciudad_id),

    CONSTRAINT fk_ciudad_pais
        FOREIGN KEY (pais_id)
        REFERENCES pais(pais_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_pais_id
ON ciudad(pais_id);
GO

CREATE TABLE idioma (
    idioma_id TINYINT IDENTITY(1,1) NOT NULL,
    nombre CHAR(20) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    CONSTRAINT PK_idioma
        PRIMARY KEY (idioma_id)
);
GO

CREATE TABLE pelicula (
    pelicula_id SMALLINT NOT NULL IDENTITY(1,1),
    titulo VARCHAR(128) NOT NULL,
    descripcion VARCHAR(MAX) DEFAULT NULL,
    anio_estreno SMALLINT DEFAULT NULL,
    idioma_id TINYINT NOT NULL,
    idioma_original_id TINYINT DEFAULT NULL,
    duracion_alquiler TINYINT NOT NULL DEFAULT 3,
    precio_alquiler DECIMAL(4,2) NOT NULL DEFAULT 4.99,
    duracion SMALLINT DEFAULT NULL,
    costo_reemplazo DECIMAL(5,2) NOT NULL DEFAULT 19.99,
    clasificacion VARCHAR(10) DEFAULT 'G',
    caracteristicas_especiales VARCHAR(100) DEFAULT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (pelicula_id),

    CONSTRAINT fk_pelicula_idioma
        FOREIGN KEY (idioma_id)
        REFERENCES idioma(idioma_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_pelicula_idioma_original
        FOREIGN KEY (idioma_original_id)
        REFERENCES idioma(idioma_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_titulo
ON pelicula(titulo);
GO

CREATE INDEX idx_fk_idioma_id
ON pelicula(idioma_id);
GO

CREATE INDEX idx_fk_idioma_original_id
ON pelicula(idioma_original_id);
GO

CREATE TABLE direccion (
    direccion_id SMALLINT NOT NULL IDENTITY(1,1),
    direccion VARCHAR(50) NOT NULL,
    direccion2 VARCHAR(50) DEFAULT NULL,
    distrito VARCHAR(20) NOT NULL,
    ciudad_id SMALLINT NOT NULL,
    codigo_postal VARCHAR(10) DEFAULT NULL,
    telefono VARCHAR(20) NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (direccion_id),

    CONSTRAINT fk_direccion_ciudad
        FOREIGN KEY (ciudad_id)
        REFERENCES ciudad(ciudad_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_ciudad_id
ON direccion(ciudad_id);
GO

CREATE TABLE tienda (
    tienda_id TINYINT IDENTITY(1,1) NOT NULL,
    gerente_empleado_id TINYINT NOT NULL,
    direccion_id SMALLINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (tienda_id),

    CONSTRAINT fk_tienda_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion(direccion_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE UNIQUE INDEX idx_gerente_unico
ON tienda(gerente_empleado_id);
GO

CREATE INDEX idx_fk_direccion_id
ON tienda(direccion_id);
GO

CREATE TABLE empleado (
    empleado_id TINYINT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    apellido VARCHAR(45) NOT NULL,
    direccion_id SMALLINT NOT NULL,
    foto VARBINARY(MAX) DEFAULT NULL,
    email VARCHAR(50) DEFAULT NULL,
    tienda_id TINYINT NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    usuario VARCHAR(16) NOT NULL,
    contrasena VARCHAR(40) COLLATE Latin1_General_BIN2 DEFAULT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (empleado_id),

    CONSTRAINT fk_empleado_tienda
        FOREIGN KEY (tienda_id)
        REFERENCES tienda(tienda_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_empleado_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion(direccion_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_tienda_id
ON empleado(tienda_id);
GO

CREATE INDEX idx_fk_direccion_id_empleado
ON empleado(direccion_id);
GO

ALTER TABLE tienda
ADD CONSTRAINT fk_tienda_empleado
    FOREIGN KEY (gerente_empleado_id)
    REFERENCES empleado(empleado_id)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
GO

CREATE TABLE cliente (
    cliente_id SMALLINT NOT NULL IDENTITY(1,1),
    tienda_id TINYINT NOT NULL,
    nombre VARCHAR(45) NOT NULL,
    apellido VARCHAR(45) NOT NULL,
    email VARCHAR(50) DEFAULT NULL,
    direccion_id SMALLINT NOT NULL,
    activo BIT NOT NULL DEFAULT 1,
    fecha_creacion DATETIME NOT NULL,
    ultima_actualizacion DATETIME DEFAULT GETDATE(),

    PRIMARY KEY (cliente_id),

    CONSTRAINT fk_cliente_direccion
        FOREIGN KEY (direccion_id)
        REFERENCES direccion(direccion_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_cliente_tienda
        FOREIGN KEY (tienda_id)
        REFERENCES tienda(tienda_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_tienda_id
ON cliente(tienda_id);
GO

CREATE INDEX idx_fk_direccion_id
ON cliente(direccion_id);
GO

CREATE INDEX idx_apellido
ON cliente(apellido);
GO

CREATE TABLE inventario (
    inventario_id INT IDENTITY(1,1) NOT NULL,
    pelicula_id SMALLINT NOT NULL,
    tienda_id TINYINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (inventario_id),

    CONSTRAINT fk_inventario_tienda
        FOREIGN KEY (tienda_id)
        REFERENCES tienda(tienda_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_inventario_pelicula
        FOREIGN KEY (pelicula_id)
        REFERENCES pelicula(pelicula_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_pelicula_id
ON inventario(pelicula_id);
GO

CREATE INDEX idx_tienda_id_pelicula_id
ON inventario(tienda_id, pelicula_id);
GO

CREATE TABLE alquiler (
    alquiler_id INT IDENTITY(1,1) NOT NULL,
    fecha_alquiler DATETIME NOT NULL,
    inventario_id INT NOT NULL,
    cliente_id SMALLINT NOT NULL,
    fecha_devolucion DATETIME DEFAULT NULL,
    empleado_id TINYINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (alquiler_id),

    CONSTRAINT fk_alquiler_empleado
        FOREIGN KEY (empleado_id)
        REFERENCES empleado(empleado_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_alquiler_inventario
        FOREIGN KEY (inventario_id)
        REFERENCES inventario(inventario_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_alquiler_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES cliente(cliente_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE UNIQUE INDEX uq_fecha_alquiler_inventario_cliente
ON alquiler(fecha_alquiler, inventario_id, cliente_id);
GO

CREATE INDEX idx_fk_inventario_id
ON alquiler(inventario_id);
GO

CREATE INDEX idx_fk_cliente_id
ON alquiler(cliente_id);
GO

CREATE INDEX idx_fk_empleado_id
ON alquiler(empleado_id);
GO

CREATE TABLE pago (
    pago_id SMALLINT IDENTITY(1,1) NOT NULL,
    cliente_id SMALLINT NOT NULL,
    empleado_id TINYINT NOT NULL,
    alquiler_id INT DEFAULT NULL,
    monto DECIMAL(5,2) NOT NULL,
    fecha_pago DATETIME NOT NULL,
    ultima_actualizacion DATETIME DEFAULT GETDATE(),

    PRIMARY KEY (pago_id),

    CONSTRAINT fk_pago_alquiler
        FOREIGN KEY (alquiler_id)
        REFERENCES alquiler(alquiler_id)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,

    CONSTRAINT fk_pago_cliente
        FOREIGN KEY (cliente_id)
        REFERENCES cliente(cliente_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_pago_empleado
        FOREIGN KEY (empleado_id)
        REFERENCES empleado(empleado_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_empleado_id
ON pago(empleado_id);
GO

CREATE INDEX idx_fk_cliente_id
ON pago(cliente_id);
GO

CREATE TABLE pelicula_actor (
    actor_id SMALLINT NOT NULL,
    pelicula_id SMALLINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (actor_id, pelicula_id),

    CONSTRAINT fk_pelicula_actor_actor
        FOREIGN KEY (actor_id)
        REFERENCES actor(actor_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_pelicula_actor_pelicula
        FOREIGN KEY (pelicula_id)
        REFERENCES pelicula(pelicula_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE INDEX idx_fk_pelicula_id
ON pelicula_actor(pelicula_id);
GO

CREATE TABLE pelicula_categoria (
    pelicula_id SMALLINT NOT NULL,
    categoria_id TINYINT NOT NULL,
    ultima_actualizacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (pelicula_id, categoria_id),

    CONSTRAINT fk_pelicula_categoria_pelicula
        FOREIGN KEY (pelicula_id)
        REFERENCES pelicula(pelicula_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_pelicula_categoria_categoria
        FOREIGN KEY (categoria_id)
        REFERENCES categoria(categoria_id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);
GO

CREATE TABLE pelicula_texto (
    pelicula_id SMALLINT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion VARCHAR(MAX),

    CONSTRAINT PK_pelicula_texto
        PRIMARY KEY (pelicula_id)
);
GO

CREATE TRIGGER ins_pelicula
ON pelicula
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO pelicula_texto (
        pelicula_id,
        titulo,
        descripcion
    )
    SELECT
        pelicula_id,
        titulo,
        descripcion
    FROM inserted;
END;
GO

CREATE TRIGGER act_pelicula
ON pelicula
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE pt
    SET
        pt.titulo = i.titulo,
        pt.descripcion = i.descripcion,
        pt.pelicula_id = i.pelicula_id
    FROM pelicula_texto AS pt
    INNER JOIN deleted AS d
        ON pt.pelicula_id = d.pelicula_id
    INNER JOIN inserted AS i
        ON i.pelicula_id = d.pelicula_id
    WHERE
        ISNULL(d.titulo, '') <> ISNULL(i.titulo, '')
        OR ISNULL(d.descripcion, '') <> ISNULL(i.descripcion, '')
        OR d.pelicula_id <> i.pelicula_id;
END;
GO

CREATE TRIGGER eli_pelicula
ON pelicula
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE pt
    FROM pelicula_texto AS pt
    INNER JOIN deleted AS d
        ON pt.pelicula_id = d.pelicula_id;
END;
GO

CREATE VIEW lista_clientes
AS
SELECT
    cl.cliente_id AS ID,
    CONCAT(cl.nombre, ' ', cl.apellido) AS nombre,
    d.direccion AS direccion,
    d.codigo_postal AS [codigo postal],
    d.telefono AS telefono,
    ci.ciudad AS ciudad,
    p.pais AS pais,
    CASE
        WHEN cl.activo = 1 THEN 'activo'
        ELSE ''
    END AS notas,
    cl.tienda_id AS ID_tienda
FROM cliente AS cl
JOIN direccion AS d
    ON cl.direccion_id = d.direccion_id
JOIN ciudad AS ci
    ON d.ciudad_id = ci.ciudad_id
JOIN pais AS p
    ON ci.pais_id = p.pais_id;
GO

CREATE VIEW lista_peliculas
AS
SELECT
    p.pelicula_id AS ID_pelicula,
    p.titulo AS titulo,
    p.descripcion AS descripcion,
    c.nombre AS categoria,
    p.precio_alquiler AS precio,
    p.duracion AS duracion,
    p.clasificacion AS clasificacion,
    STRING_AGG(
        CONCAT(a.nombre, ' ', a.apellido),
        ', '
    ) AS actores
FROM pelicula AS p
LEFT JOIN pelicula_categoria AS pc
    ON pc.pelicula_id = p.pelicula_id
LEFT JOIN categoria AS c
    ON c.categoria_id = pc.categoria_id
LEFT JOIN pelicula_actor AS pa
    ON p.pelicula_id = pa.pelicula_id
LEFT JOIN actor AS a
    ON pa.actor_id = a.actor_id
GROUP BY
    p.pelicula_id,
    p.titulo,
    p.descripcion,
    c.nombre,
    p.precio_alquiler,
    p.duracion,
    p.clasificacion;
GO

CREATE VIEW lista_peliculas_mejorada_pero_mas_lenta
AS
SELECT
    p.pelicula_id AS ID_pelicula,
    p.titulo AS titulo,
    p.descripcion AS descripcion,
    c.nombre AS categoria,
    p.precio_alquiler AS precio,
    p.duracion AS duracion,
    p.clasificacion AS clasificacion,

    STRING_AGG(
        CONCAT(
            UPPER(LEFT(a.nombre, 1)),
            LOWER(SUBSTRING(a.nombre, 2, LEN(a.nombre))),
            ' ',
            UPPER(LEFT(a.apellido, 1)),
            LOWER(SUBSTRING(a.apellido, 2, LEN(a.apellido)))
        ),
        ', '
    ) AS actores

FROM pelicula AS p
LEFT JOIN pelicula_categoria AS pc
    ON pc.pelicula_id = p.pelicula_id
LEFT JOIN categoria AS c
    ON c.categoria_id = pc.categoria_id
LEFT JOIN pelicula_actor AS pa
    ON p.pelicula_id = pa.pelicula_id
LEFT JOIN actor AS a
    ON pa.actor_id = a.actor_id

GROUP BY
    p.pelicula_id,
    p.titulo,
    p.descripcion,
    c.nombre,
    p.precio_alquiler,
    p.duracion,
    p.clasificacion;
GO

CREATE VIEW lista_empleados
AS
SELECT
    e.empleado_id AS ID,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre,
    d.direccion AS direccion,
    d.codigo_postal AS [codigo postal],
    d.telefono AS telefono,
    c.ciudad AS ciudad,
    p.pais AS pais,
    e.tienda_id AS ID_tienda
FROM empleado AS e
JOIN direccion AS d
    ON e.direccion_id = d.direccion_id
JOIN ciudad AS c
    ON d.ciudad_id = c.ciudad_id
JOIN pais AS p
    ON c.pais_id = p.pais_id;
GO

CREATE VIEW ventas_por_tienda
AS
SELECT
    CONCAT(c.ciudad, ', ', p.pais) AS tienda,
    CONCAT(e.nombre, ' ', e.apellido) AS gerente,
    SUM(pg.monto) AS total_ventas
FROM pago AS pg
INNER JOIN alquiler AS al
    ON pg.alquiler_id = al.alquiler_id
INNER JOIN inventario AS i
    ON al.inventario_id = i.inventario_id
INNER JOIN tienda AS t
    ON i.tienda_id = t.tienda_id
INNER JOIN direccion AS d
    ON t.direccion_id = d.direccion_id
INNER JOIN ciudad AS c
    ON d.ciudad_id = c.ciudad_id
INNER JOIN pais AS p
    ON c.pais_id = p.pais_id
INNER JOIN empleado AS e
    ON t.gerente_empleado_id = e.empleado_id
GROUP BY
    t.tienda_id,
    c.ciudad,
    p.pais,
    e.nombre,
    e.apellido;
GO

CREATE VIEW ventas_por_categoria_pelicula
AS
SELECT
    c.nombre AS categoria,
    SUM(pg.monto) AS total_ventas
FROM pago AS pg
INNER JOIN alquiler AS al
    ON pg.alquiler_id = al.alquiler_id
INNER JOIN inventario AS i
    ON al.inventario_id = i.inventario_id
INNER JOIN pelicula AS p
    ON i.pelicula_id = p.pelicula_id
INNER JOIN pelicula_categoria AS pc
    ON p.pelicula_id = pc.pelicula_id
INNER JOIN categoria AS c
    ON pc.categoria_id = c.categoria_id
GROUP BY
    c.nombre;
GO

CREATE VIEW informacion_actor
AS
WITH categorias_peliculas AS
(
    SELECT
        a.actor_id,
        a.nombre,
        a.apellido,
        c.categoria_id,
        c.nombre AS nombre_categoria,
        STRING_AGG(p.titulo, ', ') AS titulos_peliculas
    FROM actor AS a
    LEFT JOIN pelicula_actor AS pa
        ON a.actor_id = pa.actor_id
    LEFT JOIN pelicula_categoria AS pc
        ON pa.pelicula_id = pc.pelicula_id
    LEFT JOIN categoria AS c
        ON pc.categoria_id = c.categoria_id
    LEFT JOIN pelicula AS p
        ON pa.pelicula_id = p.pelicula_id
       AND pc.categoria_id = c.categoria_id
    GROUP BY
        a.actor_id,
        a.nombre,
        a.apellido,
        c.categoria_id,
        c.nombre
)
SELECT
    actor_id,
    nombre,
    apellido,
    STRING_AGG(
        CONCAT(nombre_categoria, ': ', titulos_peliculas),
        '; '
    ) AS informacion_peliculas
FROM categorias_peliculas
GROUP BY
    actor_id,
    nombre,
    apellido;
GO

CREATE PROCEDURE reporte_recompensas
    @compras_mensuales_minimas TINYINT,
    @monto_minimo_mensual DECIMAL(10,2),
    @cantidad_beneficiados INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @inicio_mes_anterior DATE;
    DECLARE @fin_mes_anterior DATE;

    /* Validaciones */
    IF @compras_mensuales_minimas = 0
    BEGIN
        SELECT 'El parámetro de compras mensuales mínimas debe ser mayor que 0' AS mensaje;
        RETURN;
    END;

    IF @monto_minimo_mensual = 0.00
    BEGIN
        SELECT 'El monto mínimo mensual debe ser mayor que $0.00' AS mensaje;
        RETURN;
    END;

    /* Primer y último día del mes anterior */
    SET @inicio_mes_anterior =
        DATEFROMPARTS(
            YEAR(DATEADD(MONTH, -1, GETDATE())),
            MONTH(DATEADD(MONTH, -1, GETDATE())),
            1
        );

    SET @fin_mes_anterior = EOMONTH(@inicio_mes_anterior);

    /* Tabla temporal */
    CREATE TABLE #clientes_beneficiados (
        cliente_id SMALLINT NOT NULL PRIMARY KEY
    );

    /* Clientes que cumplen las condiciones */
    INSERT INTO #clientes_beneficiados (cliente_id)
    SELECT p.cliente_id
    FROM pago AS p
    WHERE CAST(p.fecha_pago AS DATE)
          BETWEEN @inicio_mes_anterior AND @fin_mes_anterior
    GROUP BY p.cliente_id
    HAVING SUM(p.monto) > @monto_minimo_mensual
       AND COUNT(p.cliente_id) > @compras_mensuales_minimas;

    /* Cantidad de clientes encontrados */
    SELECT @cantidad_beneficiados = COUNT(*)
    FROM #clientes_beneficiados;

    /* Datos completos de los clientes */
    SELECT c.*
    FROM #clientes_beneficiados AS b
    INNER JOIN cliente AS c
        ON b.cliente_id = c.cliente_id;

    /* Limpieza */
    DROP TABLE #clientes_beneficiados;
END;
GO

CREATE FUNCTION obtener_saldo_cliente
(
    @cliente_id INT,
    @fecha_consulta DATETIME
)
RETURNS DECIMAL(5,2)
AS
BEGIN

    DECLARE @tarifas_alquiler DECIMAL(5,2);
    DECLARE @recargos_demora INT;
    DECLARE @pagos_realizados DECIMAL(5,2);

    /* Tarifas de alquiler */
    SELECT @tarifas_alquiler = ISNULL(SUM(p.precio_alquiler), 0)
    FROM pelicula AS p
    INNER JOIN inventario AS i
        ON p.pelicula_id = i.pelicula_id
    INNER JOIN alquiler AS a
        ON i.inventario_id = a.inventario_id
    WHERE a.fecha_alquiler <= @fecha_consulta
      AND a.cliente_id = @cliente_id;

    /* Recargos por demora */
    SELECT @recargos_demora = ISNULL(
        SUM(
            CASE
                WHEN DATEDIFF(DAY, a.fecha_alquiler, a.fecha_devolucion) > p.duracion_alquiler
                THEN DATEDIFF(DAY, a.fecha_alquiler, a.fecha_devolucion) - p.duracion_alquiler
                ELSE 0
            END
        ), 0)
    FROM alquiler AS a
    INNER JOIN inventario AS i
        ON a.inventario_id = i.inventario_id
    INNER JOIN pelicula AS p
        ON i.pelicula_id = p.pelicula_id
    WHERE a.fecha_alquiler <= @fecha_consulta
      AND a.cliente_id = @cliente_id;

    /* Pagos realizados */
    SELECT @pagos_realizados = ISNULL(SUM(monto), 0)
    FROM pago
    WHERE fecha_pago <= @fecha_consulta
      AND cliente_id = @cliente_id;

    RETURN @tarifas_alquiler + @recargos_demora - @pagos_realizados;

END;
GO


CREATE FUNCTION inventario_en_poder_cliente
(
    @inventario_id INT
)
RETURNS INT
AS
BEGIN
    DECLARE @cliente_id INT;

    SELECT TOP 1
        @cliente_id = cliente_id
    FROM alquiler
    WHERE fecha_devolucion IS NULL
      AND inventario_id = @inventario_id;

    RETURN @cliente_id;
END;
GO

CREATE FUNCTION inventario_disponible
(
    @inventario_id INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @cantidad_alquileres INT;
    DECLARE @cantidad_pendientes INT;

    /* Cuenta cuántos alquileres tuvo el ejemplar */
    SELECT @cantidad_alquileres = COUNT(*)
    FROM alquiler
    WHERE inventario_id = @inventario_id;

    /* Si nunca fue alquilado, está disponible */
    IF @cantidad_alquileres = 0
        RETURN 1;

    /* Busca si existe un alquiler sin fecha de devolución */
    SELECT @cantidad_pendientes = COUNT(a.alquiler_id)
    FROM inventario AS i
    LEFT JOIN alquiler AS a
        ON i.inventario_id = a.inventario_id
    WHERE i.inventario_id = @inventario_id
      AND a.fecha_devolucion IS NULL;

    IF @cantidad_pendientes > 0
        RETURN 0;

    RETURN 1;
END;
GO


CREATE PROCEDURE pelicula_disponible_en_tienda
    @pelicula_id INT,
    @tienda_id INT,
    @cantidad_peliculas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* Devuelve los ejemplares disponibles */
    SELECT inventario_id
    FROM inventario
    WHERE pelicula_id = @pelicula_id
      AND tienda_id = @tienda_id
      AND dbo.inventario_disponible(inventario_id) = 1;

    /* Guarda la cantidad en el parámetro de salida */
    SELECT @cantidad_peliculas = COUNT(*)
    FROM inventario
    WHERE pelicula_id = @pelicula_id
      AND tienda_id = @tienda_id
      AND dbo.inventario_disponible(inventario_id) = 1;
END;
GO


CREATE PROCEDURE pelicula_no_disponible_en_tienda
    @pelicula_id INT,
    @tienda_id INT,
    @cantidad_peliculas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* Devuelve los ejemplares no disponibles */
    SELECT inventario_id
    FROM inventario
    WHERE pelicula_id = @pelicula_id
      AND tienda_id = @tienda_id
      AND dbo.inventario_disponible(inventario_id) = 0;

    /* Guarda la cantidad en el parámetro de salida */
    SELECT @cantidad_peliculas = COUNT(*)
    FROM inventario
    WHERE pelicula_id = @pelicula_id
      AND tienda_id = @tienda_id
      AND dbo.inventario_disponible(inventario_id) = 0;
END;
GO