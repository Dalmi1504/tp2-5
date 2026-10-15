
## Anexo de Trazabilidad de IA

## 1. Bitácora de prompts

Durante el desarrollo del trabajo utilizamos ChatGPT como herramienta de apoyo para interpretar los indicadores comerciales obtenidos mediante SQL Server y Python.

### Prompt 1 Conexión entre Python y SQL Server

**Prompt:**

«Estamos usando en una Mac con Python 3.12 y SQL Server ejecutándose en Docker. Necesito conectarme desde Python mediante mssql-python. ¿Cómo lo configuro usando .env?»

**Respuesta y correcciones:** La IA orientó la configuración del controlador y las variables de entorno. Durante las pruebas fue necesario revisar las bibliotecas utilizadas por macOS y configurar `DYLD_LIBRARY_PATH`.

**Verificación:** Se consiguió establecer la conexión con la base `Sakila_Espanol`.

### Prompt 2 Diferencias entre los nombres de las tablas

**Prompt reconstruido:**

«La consigna utiliza las tablas originales de Sakila en inglés pero nuestra base migrada a SQL Server tiene nombres en español. ¿Cómo podemos crear un diccionario de equivalencias y hacer que funcione?»

**Respuesta y correcciones:** Se implementó `esquema.py` para centralizar las equivalencias. Posteriormente, se incorporaron las funciones `nombre_tabla_sql()` y `nombre_columna_sql()` a las consultas del ETL, reemplazando referencias directas a nombres físicos.

**Verificación:** Se ejecutó `validar_esquema.py`, que informó cero columnas faltantes.

**Observación:** En este trabajo en particular, no experimentamos que la IA usara un nombre específico de tabla o columna inexistente porque siempre se adjuntaron scripts adelantándonos a que esto no suceda, por experiencia previa en otros trabajos. El problema documentado fue la necesidad de adaptar las consultas a los nombres reales de la migración utilizando el diccionario creado.

### Prompt 3 Funciones de ventana y pandas

**Prompt reconstruido:**

«Tenemos que calcular los ingresos totales, la cantidad de operaciones, el ticket promedio y la participación porcentual de cada empleado dentro de su tienda. La consigna exige SUM() OVER (PARTITION BY ...) en SQL Server y su equivalente con groupby y transform en pandas. ¿Qué tablas necesitamos y cómo podemos calcular esos valor para luego compararlos ? »

**Respuesta y correcciones:** Se desarrollaron consultas T-SQL y cálculos equivalentes mediante pandas. Se revisaron los resultados para comprobar que las participaciones e ingresos fueran consistentes.

**Verificación:** Los resultados de SQL Server y pandas coincidieron dentro de la tolerancia numérica utilizada.

### Prompt 4 Tratamiento de pagos atípicos

**Prompt reconstruido:**

«Tenemos 857 pagos atípicos a partir del IQR. ¿Cómo sabemos si son errores?»

**Respuesta y correcciones:** Se realizaron controles adicionales para verificar las relaciones de los pagos atípicos con sus alquileres y clientes.

**Decisión del equipo:** Conservar los 857 registros, ya que no se detectaron inconsistencias suficientes para considerarlos incorrectos.

**Verificación:** Se comprobaron las relaciones con alquileres existentes y la coincidencia de los clientes.

### Prompt 5 Problemas de conexión desde Jupyter

**Prompt reconstruido:**

«La conexión con SQL Server funciona cuando ejecuto un archivo Python, pero no cuando utilizo un notebook de Jupyter en Visual Studio Code. ¿Cómo lo solucionamos?»

**Respuesta y correcciones:** Se revisó el entorno virtual y el kernel utilizado por Jupyter, comprobando que estuviera seleccionado el intérprete correspondiente al proyecto.

**Verificación:** Se restableció la conexión y pudieron ejecutarse las consultas desde el notebook.

### Prompt 6 Construcción del pipeline ETL

**Prompt reconstruido:**

«Necesitamos desarrollar un ETL en Python que extraiga pagos y empleados desde SQL Server, combine los resultados con un CSV de metas comerciales y cargue los indicadores en una tabla que se cree en ese código. Tenemos que usar funciones, logging, manejo de errores y evitar duplicados cuando se ejecute varias veces. ¿Cómo empezamos?»

**Respuesta y correcciones:** Se desarrolló el pipeline `actividad4_etl.py`, utilizando pandas para las transformaciones y una estrategia transaccional de `DELETE + INSERT` para la carga.

Posteriormente, se corrigieron las consultas para utilizar el diccionario de equivalencias de `esquema.py`.

**Verificación:** Se ejecutó el ETL varias veces y la tabla de destino mantuvo dos registros, sin acumulación de duplicados.

### Prompt 7 Visualizaciones comerciales

**Prompt reconstruido:**

«Tenemos que hacer tres gráficos: participación de ingresos por empleado con barras apiladas al 100 %, comparación del ticket promedio y evolución mensual de ingresos. ¿Cómo los generamos con Matplotlib ?»

**Respuesta y correcciones:** Se generaron los gráficos en Python y se revisó su presentación para que representaran los indicadores calculados.

**Verificación:** El notebook de la Actividad 3 se ejecutó completamente sin errores y los indicadores coincidieron con los resultados obtenidos mediante SQL Server.

## 2. Crítica de código generado con asistencia de IA

Para realizar la crítica de código seleccionamos la función de extracción de datos del pipeline ETL, desarrollada durante la Actividad 4.

Durante el proyecto utilizamos ChatGPT como apoyo para construir y revisar consultas SQL desde Python. Una de las mejoras realizadas fue adaptar el código a los requisitos de portabilidad de la consigna.

### Versión inicial: nombres físicos escritos directamente desde la base ya migrada a español.

El siguiente fragmento ilustra el enfoque utilizado inicialmente, en el que los nombres de las tablas y columnas estaban escritos directamente en la consulta.

```python
consulta = """
    SELECT
        p.pago_id AS pago_id,
        p.empleado_id AS empleado_id,
        p.monto AS monto,
        e.tienda_id AS tienda_id
    FROM pago AS p
    LEFT JOIN empleado AS e
        ON p.empleado_id = e.empleado_id
"""
```

**Ventajas de este enfoque:**

- Es sencillo de leer.
- Permite comprender rápidamente qué tablas y columnas se utilizan.
- Resulta práctico cuando se trabaja con una única base de datos cuyo esquema no cambia, ej sakila_espanol

**Desventajas:**

- Depende de los nombres específicos de nuestra base migrada.
- Si otra instalación utiliza nombres diferentes, es necesario modificar la consulta.
- Repite nombres físicos que deberían estar centralizados en el diccionario de esquema.

### Versión corregida: utilización del diccionario de equivalencias

En la implementación final se utilizaron las funciones de `esquema.py` para resolver los nombres de tablas y columnas.

```python
consulta = f"""
    SELECT
        p.{nombre_columna_sql('payment', 'payment_id')} AS pago_id,
        p.{nombre_columna_sql('payment', 'staff_id')} AS empleado_id,
        p.{nombre_columna_sql('payment', 'amount')} AS monto,
        e.{nombre_columna_sql('staff', 'store_id')} AS tienda_id
    FROM {nombre_tabla_sql('payment')} AS p
    LEFT JOIN {nombre_tabla_sql('staff')} AS e
        ON p.{nombre_columna_sql('payment', 'staff_id')}
         = e.{nombre_columna_sql('staff', 'staff_id')}
"""
```

**Ventajas de la versión corregida con IA:**

- Respeta el requisito de portabilidad establecido en la consigna.
- Centraliza los nombres físicos de las tablas y columnas.
- Facilita el mantenimiento del código.
- Permite adaptar las consultas a otras migraciones de Sakila modificando el diccionario.
- Conserva los alias utilizados por pandas, evitando cambios innecesarios en las transformaciones posteriores.

**Desventajas:**

- La consulta resulta más extensa y menos sencilla de leer.
- Depende de que las equivalencias de `esquema.py` sean correctas.
- Requiere una validación adicional para comprobar que los nombres físicos existen en SQL Server.

### Comparación crítica

A lo largo del trabajo fuimos controlando respetar las diferentes consignas. Aun así, iniciando el pipeline no tuvimos en cuenta el uso del diccionario [esquema.py](http://esquema.py/) para su posterior prueba en la defensa oral. Al iniciar un supuesto último repaso notamos que estábamos citando directamente a nuestra base migrada lo que no cumplia con los requisitos.

Le pedimos a la IA que nos corrija nuestra consulta enviandole el archivo de diccionario.

La versión corregida se adapta mejor a nuestro trabajo práctico porque permite utilizar los nombres canónicos de Sakila sin depender directamente de los nombres físicos de nuestra migración.

La mejora principal no estuvo en modificar el resultado del análisis, sino en hacer que el código fuera más reutilizable y fácil de mantener.

La asistencia de IA permitió avanzar en la implementación, pero fue necesario revisar el código considerando las características de nuestra base de datos y las exigencias de portabilidad del trabajo práctico.

## 3. Verificación de conclusiones analíticas generadas por IA

En las interacciones revisadas no identificamos un caso en el que la IA propusiera una conclusión analítica incorrecta que luego tuviéramos que descartar.

La verificación consistió en comparar los resultados obtenidos y distinguir entre los hechos observados y conclusiones que requerían información adicional.

Esta experiencia permitió reconocer que, aunque una herramienta de IA pueda ayudar a explicar resultados, la interpretación final debe estar respaldada por los datos disponibles y sus limitaciones.
