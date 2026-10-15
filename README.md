TP2  Análisis comercial de Sakila
Variante 5: Rendimiento comercial por tienda y por empleado
Seminario de Actualización – Trabajo Práctico 2

Este proyecto analiza el rendimiento comercial de las tiendas y los empleados de la base de datos Sakila, utilizando SQL Server y Python.

Incluye la reconciliación de datos migrados desde MySQL, consultas T-SQL, controles de calidad, procesamiento con pandas, visualizaciones y un pipeline ETL que integra información de SQL Server con un archivo CSV.

El trabajo se organiza en seis actividades:

- Actividad 0 preparación, conexión y reconciliación.
- Actividad 1: integración SQL Server y Python.
- Actividad 2: perfilado y diagnóstico de calidad de datos.
- Actividad 3: análisis comercial y visualizaciones.
- Actividad 4: pipeline ETL.
- Actividad 5: informe final y documentación.

1. Requisitos previos

Para ejecutar el proyecto es necesario contar con:

- Python 3.12.
- Docker Desktop.
- SQL Server.
- Visual Studio Code o un editor equivalente.
- Git.
- Base de datos Sakila cargada en SQL Server.

Durante el desarrollo se utilizó la base de datos `Sakila_Espanol`.

Importante: el repositorio contiene el código del trabajo, pero su ejecución requiere disponer de SQL Server y de una base Sakila previamente cargada.

El proyecto utiliza `esquema.py` para centralizar las equivalencias entre los nombres originales de Sakila y los nombres físicos utilizados en la base migrada.

2. Descargar el proyecto

Abrir una terminal y ejecutar:

`git clone https://github.com/Dalmi1504/tp2-5.git`

Ingresar a la carpeta:

`cd TP2-Sakila-Analisis`

También es posible descargar el proyecto desde GitHub mediante Code → Download ZIP.

3. Preparar SQL Server

Iniciar Docker Desktop y comprobar que el contenedor de SQL Server esté ejecutándose.

La base utilizada durante el desarrollo se llama `Sakila_Espanol`.

Se debe verificar que SQL Server esté disponible y que las tablas de Sakila estén cargadas.

Entre las tablas utilizadas se encuentran:

- `pago`
- `empleado`
- `cliente`
- `alquiler`
- `tienda`

Estos nombres corresponden a nuestra versión de la base.

Las consultas ejecutadas desde Python utilizan el mapeo definido en `esquema.py`.

El pipeline ETL crea automáticamente la tabla analítica `dbo.TP2_RendimientoComercial` si todavía no existe.

4. Crear el entorno virtual de Python

Desde la carpeta principal del proyecto, ejecutar:

`python3.12 -m venv .venv`

Activar el entorno virtual en macOS o Linux:

`source .venv/bin/activate`

En Windows, utilizando PowerShell:

`.venv\Scripts\Activate.ps1`

5. Instalar las dependencias

Con el entorno virtual activado, ejecutar:

`python -m pip install -r requirements.txt`

El archivo `requirements.txt` contiene las dependencias necesarias para ejecutar el proyecto.

Entre las principales bibliotecas utilizadas se encuentran:

- `pandas`: procesamiento, limpieza y transformación.
- `mssql-python`: conexión con SQL Server.
- `python-dotenv`: lectura de variables de entorno.
- `numpy`: operaciones numéricas.
- `matplotlib`: generación de gráficos.
- Herramientas de Jupyter: ejecución de notebooks.

En Visual Studio Code se debe seleccionar el intérprete correspondiente al entorno virtual `.venv`.

6. Configurar la conexión a SQL Server

En la carpeta principal del proyecto, crear un archivo llamado `.env`.

Agregar las siguientes variables:

`DB_SERVER=localhost`  
`DB_PORT=1433`  
`DB_NAME=Sakila_Espanol`  
`DB_USER=tu_usuario`  
`DB_PASSWORD=tu_contrasena`

Reemplazar el usuario y la contraseña por las credenciales de la instalación local.

Importante: `.env` contiene información privada y no debe subirse a GitHub. Debe permanecer excluido mediante `.gitignore`.

Para comprobar la conexión, ejecutar:

`python conexion.py`

La conexión debe establecerse correctamente antes de continuar con las actividades.

 Configuración de OpenSSL en macOS

Durante el desarrollo se presentó el error:

`OpenSSL library could not be loaded`

En el entorno utilizado se resolvió ejecutando:

`export DYLD_LIBRARY_PATH=/Library/Frameworks/Python.framework/Versions/3.12/lib`

Esta ruta corresponde a la instalación de Python utilizada durante el desarrollo y puede variar en otras computadoras.

---

 ACTIVIDAD 0 – PREPARACIÓN, CONEXIÓN Y RECONCILIACIÓN

7. Objetivo

Preparar el entorno de trabajo en Python, conectarse a la base Sakila migrada a SQL Server, centralizar las equivalencias de nombres y comprobar las cantidades de registros después de la migración.

8. Archivos utilizados

| Archivo | Función |
|---|---|
| `conexion.py` | Conexión con SQL Server |
| `esquema.py` | Equivalencias de tablas y columnas |
| `validar_esquema.py` | Validación del esquema físico |
| `conteo_mysql.py` | Recuento de datos originales |
| `conteo_origen_mysql.csv` | Cantidades del origen |
| `reconciliacion.py` | Comparación de recuentos |
| `reconciliacion_final.csv` | Resultados de la reconciliación |
| `sakila-data.sql` | Datos originales de Sakila |

9. Ejecución

Los comandos deben ejecutarse desde la carpeta principal del proyecto.

 9.1. Generar el conteo de origen

`python conteo_mysql.py`

El programa analiza las inserciones del archivo `sakila-data.sql` y genera `conteo_origen_mysql.csv`.

 9.2. Verificar la conexión

`python conexion.py`

 9.3. Ejecutar la reconciliación

`python reconciliacion.py`

El programa compara los recuentos de origen con las cantidades registradas en SQL Server y genera `reconciliacion_final.csv`.

 9.4. Validar el esquema

`python validar_esquema.py`

El programa verifica que las tablas y columnas físicas definidas en `esquema.py` existan en SQL Server.

Durante el desarrollo se validaron las 16 tablas contempladas en el mapeo, sin detectar columnas faltantes.

10. Resultados de la reconciliación

Se compararon las cantidades de registros de las 16 tablas de Sakila entre los datos originales de MySQL y la base migrada a SQL Server.

Las 15 tablas con inserciones directas en el archivo original presentaron la misma cantidad de registros en SQL Server.

 Particularidad de la tabla film_text

La tabla `film_text` no contiene instrucciones `INSERT` directas en `sakila-data.sql`.

Esto se debe a que el esquema original incluye el trigger `ins_film`, que inserta automáticamente un registro en `film_text` cuando se agrega una película.

Inicialmente se estableció un recuento esperado de 1.000 registros a partir de las 1.000 películas y del funcionamiento del trigger.

Para comprobar esta cantidad sin depender únicamente de la deducción, se realizó una verificación directa en MySQL Workbench:

`SELECT COUNT(*) AS cantidad FROM sakila.film_text;`

Resultado obtenido: 1.000 registros.

En SQL Server se verificó la tabla equivalente:

`SELECT COUNT(*) AS cantidad FROM pelicula_texto;`

Resultado obtenido: 1.000 registros.

Por lo tanto, ambas tablas presentan el mismo recuento.

Esta comprobación complementa el análisis de los archivos originales y permite validar directamente la cantidad de registros de `film_text`.

 Archivo de reconciliación

Los resultados se guardan en `reconciliacion_final.csv`, con las siguientes columnas:

- Tabla: nombre canónico de la tabla original.
- Filas de origen: cantidad obtenida a partir de los datos originales.
- Filas de SQL Server: cantidad consultada en la base migrada.
- Diferencia: resta entre los recuentos de destino y origen.

Resultado: las 16 tablas presentaron una diferencia de cero registros.

La coincidencia de cantidades permite verificar la consistencia de los recuentos, aunque no garantiza por sí sola que todos los valores migrados sean idénticos.

11. Diccionario de esquema y portabilidad

El archivo `esquema.py` centraliza las equivalencias entre los nombres canónicos de Sakila y los nombres físicos de la base migrada.

Por ejemplo:

| Nombre canónico | Nombre físico |
|---|---|
| `payment` | `pago` |
| `staff` | `empleado` |

Las consultas ejecutadas desde Python utilizan las funciones `nombre_tabla_sql()` y `nombre_columna_sql()`.

Estas funciones permiten obtener los identificadores físicos desde el diccionario.

Si otra migración conserva nombres diferentes, el objetivo es adaptar las equivalencias en `esquema.py` sin modificar la lógica de las consultas que utilizan ese mapeo.

El archivo independiente de consultas SQL de la Actividad 1 conserva los nombres físicos de nuestra base como referencia.

La validación del esquema comprueba que las columnas físicas registradas en el diccionario existan en SQL Server.

Esta comprobación verifica la existencia de las columnas, pero no garantiza por sí sola que todas las equivalencias sean semánticamente correctas.



 ACTIVIDAD 1  INTEGRACIÓN SQL SERVER Y PYTHON

12. Objetivo

Analizar el rendimiento comercial por tienda y empleado mediante consultas T-SQL y procesamiento con pandas.

Se busca calcular las métricas comerciales, comprobar la coincidencia de resultados entre SQL Server y pandas y comparar los tiempos de ejecución.

13. Archivos utilizados

- `actividad1_consultas.sql`
- `actividad1_analisis.ipynb`
- `esquema.py`

14. Consultas SQL

El archivo `actividad1_consultas.sql` contiene nueve consultas documentadas:

1. Relación entre pagos, empleados y tiendas.
2. Control de pagos sin empleado válido.
3. Control de empleados sin operaciones.
4. Clientes con pagos procesados en ambas tiendas.
5. Distribución de clientes por tienda.
6. Métricas comerciales por empleado.
7. Participación de empleados y tiendas.
8. Validación SQL vs. pandas.
9. Pagos individuales para procesar en pandas.

Las consultas principales permiten obtener cantidad de operaciones, ingresos totales, ticket promedio y participaciones comerciales.

Las uniones y agregaciones principales se realizan en SQL Server para evitar trasladar innecesariamente todos los pagos al DataFrame principal.

15. Ejecutar el notebook

Abrir `actividad1_analisis.ipynb`.

Seleccionar el kernel de Python correspondiente a `.venv`.

Ejecutar todas las celdas en orden mediante Run All.

El notebook utiliza `pandas.read_sql()` para ejecutar las consultas y cargar los resultados.

Las consultas del notebook obtienen los nombres físicos de las tablas y columnas desde `esquema.py`.

16. Validación SQL vs. pandas

Se calculan métricas equivalentes mediante dos enfoques:

- Agrupación directamente en SQL Server.
- Agrupación con pandas a partir de los pagos individuales.

Los resultados se comparan para verificar su coincidencia.

También se miden los tiempos de ejecución.

La comparación de tiempos debe interpretarse considerando que una consulta puede incluir la transferencia de resultados desde SQL Server hacia Python.

Esta actividad permite justificar qué operaciones se realizan en SQL Server y cuáles se procesan mediante pandas.


 ACTIVIDAD 2 PERFILADO Y DIAGNÓSTICO DE CALIDAD

17. Objetivo

Evaluar la calidad de los datos utilizados en el análisis comercial antes de calcular indicadores y formular conclusiones.

18. Archivos utilizados

- `actividad2_perfilado.ipynb`
- `actividad2_diagnostico.md`
- `actividad2_diagnostico.pdf`
- `esquema.py`

19. Ejecutar el notebook

Abrir `actividad2_perfilado.ipynb`.

Seleccionar el entorno virtual `.venv` como kernel y ejecutar Run All.

20. Controles realizados

Se analizaron 16.044 registros y seis columnas relacionadas con los pagos y la tienda del empleado que procesó cada operación.

Los controles incluyen:

- Dimensiones y estructura del conjunto.
- Tipos de datos.
- Valores faltantes.
- Duplicados según la clave de negocio.
- Rangos válidos.
- Valores atípicos mediante IQR.
- Reglas de negocio.
- Relaciones entre pagos, empleados y tiendas.
- Comparación de controles SQL vs. pandas.
- Cobertura temporal.

21. Resultados del diagnóstico

| Control | Resultado |
|---|---:|
| Pagos analizados | 16.044 |
| Valores faltantes | 0 |
| Pagos duplicados por identificador | 0 |
| Pagos sin empleado válido | 0 |
| Empleados sin operaciones | 0 |
| Pagos con montos negativos | 0 |
| Pagos con fechas futuras | 0 |
| Clientes con pagos procesados en ambas tiendas | 599 |
| Pagos atípicos mediante IQR | 857 |

 Análisis de los pagos atípicos

Se aplicó el método del rango intercuartílico:

- Q1: $2,99.
- Q3: $4,99.
- IQR: $2,00.
- Límite inferior: -$0,01.
- Límite superior: $7,99.

Se identificaron 857 pagos atípicos, equivalentes aproximadamente al 5,34 % de los registros.

De ellos, 855 presentan importes terminados en ,99, compatibles con un patrón de precios comerciales.

Los dos restantes, de $8,97 y $9,98, aparecen una sola vez cada uno y requieren una revisión particular.

También se comprobó que los 857 pagos atípicos tienen un alquiler asociado y que el cliente registrado en cada pago coincide con el del alquiler.

Esta validación aporta evidencia de integridad referencial, pero no demuestra por sí sola que los importes cobrados sean correctos.

Decisión de transformación

Se decidió conservar los 857 pagos atípicos sin modificar sus importes.

No se encontraron inconsistencias en sus relaciones y eliminarlos sin comprobar errores podría distorsionar los ingresos totales y el ticket promedio.

El diagnóstico completo se encuentra en `actividad2_diagnostico.md` y su versión PDF.



ACTIVIDAD 3 ANÁLISIS COMERCIAL Y VISUALIZACIONES

22. Objetivo

Comparar el rendimiento comercial de las tiendas y los empleados mediante indicadores, participaciones porcentuales y gráficos.

23. Archivos utilizados

- `actividad3_analisis.ipynb`
- `esquema.py`
- Carpeta `graficos/`

24. Ejecutar el notebook

Abrir `actividad3_analisis.ipynb`.

Seleccionar el kernel correspondiente a `.venv` y ejecutar **Run All**.

El notebook genera los resultados del análisis y exporta los gráficos.

25. Indicadores comerciales

Se calculan:

- Ingresos totales por empleado.
- Cantidad de operaciones por empleado.
- Ticket promedio.
- Ingresos totales por tienda.
- Participación de cada empleado en los ingresos de su tienda.
- Participación de cada tienda en los ingresos del negocio.

Las participaciones se calculan utilizando funciones de ventana en SQL Server y operaciones de agrupación en pandas.

26. Visualizaciones

El notebook genera gráficos para representar los resultados comerciales.

Incluye el gráfico obligatorio de barras apiladas al 100 %, que muestra la participación de los empleados dentro de cada tienda.

También incorpora gráficos complementarios para analizar los ingresos y su comportamiento.

Los gráficos se exportan como PNG con una resolución de 150 dpi.

La carpeta `graficos/` almacena las imágenes generadas.

Si la carpeta todavía no existe, puede crearse automáticamente mediante:

`from pathlib import Path`

`Path("graficos").mkdir(parents=True, exist_ok=True)`

27. Interpretación de resultados

Los indicadores permiten comparar el volumen de operaciones, los ingresos y el ticket promedio.

Las participaciones porcentuales muestran cuánto aporta cada empleado a su tienda y cuánto representa cada tienda sobre el negocio.

Las conclusiones deben considerar las limitaciones del conjunto, especialmente su período histórico y los resultados del diagnóstico de calidad.


ACTIVIDAD 4 PIPELINE ETL

28. Objetivo

Desarrollar un proceso de extracción, transformación y carga que integre información de SQL Server con un archivo CSV y almacene los resultados en una tabla analítica.

29. Archivos utilizados

- `actividad4_etl.py`
- `metas_comerciales.csv`
- `actividad4_verificacion.sql`
- `actividad4_evidencia.md`
- `esquema.py`

30. Verificar el archivo CSV

Comprobar que `metas_comerciales.csv` se encuentre en la misma carpeta que `actividad4_etl.py`.

Su contenido es:

`tienda_id,meta_ingresos`  
`1,35000`  
`2,35000`

Este archivo representa el segundo origen de datos del ETL.

Las metas comerciales son son valores ficticios utilizados exclusivamente con fines académicos.

31. Ejecutar el pipeline

Con SQL Server disponible, el entorno virtual activado y .env configurado, ejecutar:

python actividad4_etl.py

El script realiza automáticamente las siguientes operaciones:

Se conecta a SQL Server.

Extrae los pagos y los datos de los empleados.

Lee las metas comerciales del CSV.

Ejecuta controles de calidad de datos.

Agrupa los pagos por tienda y empleado.

Calcula ingresos, cantidad de operaciones y ticket promedio.

Combina los resultados con las metas mediante merge() de pandas.

Calcula porcentajes de participación y cumplimiento de metas.

Crea la tabla de destino si no existe.

Carga los resultados procesados en SQL Server.

Durante la ejecución se muestran mensajes de logging con el avance del proceso y las cantidades de registros procesados.

Si ocurre un error, el script lo registra y propaga la excepción.

32. Verificar los resultados

Una vez finalizado el ETL, conectarse a la base Sakila desde un cliente SQL.

Ejecutar:

SELECT * FROM dbo.TP2_RendimientoComercial;

Para comprobar la cantidad de registros:

SELECT COUNT(*) AS cantidad_registros FROM dbo.TP2_RendimientoComercial;

Con los datos utilizados durante el desarrollo, el resultado esperado es 2 registros, correspondientes a las combinaciones de tienda y empleado analizadas.

También puede utilizarse actividad4_verificacion.sql.

33. Comprobar la idempotencia

Para verificar que el proceso no acumula registros duplicados:

Ejecutar python actividad4_etl.py.

Consultar la cantidad de registros de la tabla de destino.

Ejecutar nuevamente python actividad4_etl.py, sin modificar los datos de origen.

Volver a consultar la cantidad de registros.

En las pruebas realizadas el 14 de octubre de 2026, ambas ejecuciones terminaron correctamente e informaron dos filas insertadas.

Posteriormente, la consulta COUNT(*) confirmó que la tabla destino contenía 2 registros en total.

La estrategia implementada es una carga completa mediante DELETE + INSERT dentro de una transacción.

Esto permite reemplazar los resultados anteriores por los nuevos, sin acumular filas de ejecuciones previas.

Si la inserción falla, se utiliza ROLLBACK para revertir los cambios de la transacción.

La prueba realizada confirma que las ejecuciones repetidas no acumularon registros duplicados. Una comprobación más completa también puede comparar los valores de las filas entre ejecuciones.

34. Resultados esperados

Durante las pruebas del proyecto se obtuvieron:

Indicador: Resultado

Pagos extraídos: 16.044

Ingresos totales: $67.406,56

Empleados sin operaciones: 0

Pagos sin empleado o tienda: 0

Clientes atendidos por empleados de ambas tiendas: 599

Registros cargados: 2

Estos valores corresponden a la versión de la base de datos utilizada durante el desarrollo. Pueden variar si se modifica el origen.

35. Solución de problemas

Error de conexión a SQL Server

Verificar que:

Docker Desktop esté iniciado.

El contenedor de SQL Server esté funcionando.

La base de datos configurada exista.

Las credenciales de .env sean correctas.

El servidor y el puerto sean accesibles.

Error de OpenSSL en macOS

Durante el desarrollo se presentó el error OpenSSL library could not be loaded.

En el entorno utilizado se resolvió mediante:

export DYLD_LIBRARY_PATH=/Library/Frameworks/Python.framework/Versions/3.12/lib

La ruta puede variar según la instalación local de Python.

Error por dependencias faltantes

Comprobar que .venv esté activado y ejecutar:

python -m pip install -r requirements.txt

Error al ejecutar notebooks

Verificar que:

El kernel corresponda al entorno virtual.

SQL Server esté disponible.

.env esté configurado.

esquema.py sea accesible.

Las dependencias estén instaladas.

Error al guardar gráficos

Si aparece un error porque no existe la carpeta graficos, crearla mediante:

from pathlib import Path

Path("graficos").mkdir(parents=True, exist_ok=True)

36. Estructura del proyecto

Los principales archivos utilizados son:

Archivo o carpeta: Función

README.md: Instrucciones del proyecto

requirements.txt: Dependencias de Python

conexion.py: Conexión a SQL Server

esquema.py: Mapeo de nombres canónicos y físicos

validar_esquema.py: Validación del esquema

conteo_mysql.py: Conteo de datos originales

conteo_origen_mysql.csv: Recuentos de MySQL

reconciliacion.py: Comparación de recuentos

reconciliacion_final.csv: Resultados de reconciliación

sakila-data.sql: Datos originales de Sakila

actividad1_consultas.sql: Consultas SQL de la Actividad 1

actividad1_analisis.ipynb: Integración SQL y Python

actividad2_perfilado.ipynb: Perfilado de calidad

actividad2_diagnostico.md: Diagnóstico de calidad

actividad2_diagnostico.pdf: Diagnóstico en PDF

actividad3_analisis.ipynb: Análisis comercial

graficos/: Gráficos exportados

actividad4_etl.py: Pipeline ETL

metas_comerciales.csv: Metas comerciales simuladas

actividad4_verificacion.sql: Consultas de verificación

actividad4_evidencia.md: Evidencia de ejecución

El archivo .env y el entorno virtual .venv son elementos locales de ejecución y no deben incorporarse al repositorio.

37. Limitaciones

La ejecución requiere SQL Server y una base Sakila disponible.

Los nombres físicos pueden variar entre migraciones; por eso las consultas ejecutadas desde Python utilizan esquema.py.

El archivo SQL independiente de la Actividad 1 utiliza los nombres físicos de la base empleada durante el desarrollo.

Las metas comerciales del CSV son simuladas.

La carga ETL es completa, no incremental.

Los resultados pueden variar si se modifican los datos de origen.

La configuración de OpenSSL documentada corresponde al entorno macOS utilizado.

Los pagos analizados pertenecen a un período histórico (los pagos de nuestra base Sakila son antiguos, no corresponden a ventas actuales).

Los valores atípicos identificados mediante IQR requieren interpretación comercial antes de considerarse errores.

38. Archivos originales de Sakila

El archivo `sakila-data.sql` fue utilizado en la Actividad 0 por el script auxiliar `conteo_mysql.py` para obtener los recuentos de registros del origen y compararlos con los de la base migrada a SQL Server, como parte del proceso de reconciliación.

Por su parte, `sakila-schema.sql` se conservó como referencia de la estructura original de la base de datos.

Durante la revisión posterior se comprobó que estos archivos no forman parte del flujo principal de análisis ni del pipeline ETL, ya que los notebooks y el ETL trabajan directamente con `Sakila_Espanol` en SQL Server.

Se decidió conservar ambos archivos como material de referencia y apoyo para la documentación y las verificaciones del proyecto.
