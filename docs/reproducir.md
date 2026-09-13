# Cómo abrir o reproducir el proyecto

## Explorar el informe existente

1. Descargar el repositorio mediante **Code → Download ZIP** y descomprimirlo.
2. Abrir `powerbi/hospital_readmissions_dashboard.pbix` con Power BI Desktop para Windows, preferentemente actualizado. El archivo adjunto tiene metadatos de la edición de agosto de 2026 y contiene el rediseño final del proyecto.
3. Explorar los datos importados. No es necesario pulsar **Actualizar** para utilizar esa copia.

Los modelos en modo Importación conservan los datos importados. Actualizarlos requiere volver a acceder al origen, que en este proyecto es SQL Server. [Microsoft: modos del modelo](https://learn.microsoft.com/en-us/power-bi/connect-data/service-dataset-modes-understand).

## Reconstruir los datos en SQL Server

Se necesita SQL Server y un editor compatible con T-SQL, por ejemplo SQL Server Management Studio (SSMS). Los scripts utilizan `GO`, `TOP`, `ISNULL` y `CREATE OR ALTER VIEW`: no están escritos para MySQL o PostgreSQL.

### 1. Ubicar los archivos de origen

Los cinco CSV ya están incluidos en [data/](../data/). `diabetic_data.csv` es la tabla de registros; los tres catálogos están separados en `admission_type.csv`, `discharge_disposition.csv` y `admission_source.csv`. También se conserva `IDS_mapping.csv`, que reúne los tres bloques. La fuente original está en [UCI](https://doi.org/10.24432/C5230J).

### 2. Crear la base e importar las cuatro tablas

En SSMS, ejecutar:

```sql
IF DB_ID(N'HospitalReadmissions') IS NULL
    EXEC(N'CREATE DATABASE HospitalReadmissions');
GO
USE HospitalReadmissions;
GO
```

En el explorador de objetos, hacer clic derecho en esa base y abrir **Tareas → Importar archivo plano**. Importar cada CSV como una tabla nueva:

| CSV | Tabla de destino |
|---|---|
| `diabetic_data.csv` | `dbo.diabetic_data_raw` |
| `admission_type.csv` | `dbo.dim_admission_type` |
| `discharge_disposition.csv` | `dbo.dim_discharge_disposition` |
| `admission_source.csv` | `dbo.dim_admission_source` |

Revisar los tipos inferidos antes de finalizar:

- `encounter_id` y `patient_nbr`: `BIGINT`.
- Los tres IDs administrativos: `INT`, tanto en la tabla principal como en los catálogos.
- Estadía, cantidades de procedimientos, medicamentos, diagnósticos y visitas: `INT`.
- `race`, `gender`, `age`, `weight`, `payer_code`, `medical_specialty`, `diag_1`, `diag_2`, `diag_3` y los demás campos categóricos: texto; `NVARCHAR(255)` evita truncamientos en este dataset.
- `description` de los catálogos: `NVARCHAR(255)`.

Conservar los encabezados originales y los valores `?`; la limpieza se realiza después mediante vistas. No transformar los diagnósticos a números ni importar `IDS_mapping.csv` completo como una sola tabla, porque contiene tres bloques con diferentes encabezados.

Si las tablas ya existen, continuar con la verificación y los scripts; no volver a anexar el mismo CSV. La preparación original de la base es un paso manual: los cuatro SQL del proyecto parten de estas tablas cargadas.

### 3. Ejecutar los SQL en orden

Abrir y ejecutar los cuatro archivos de `sql/` en orden numérico. `02` crea `dbo.vw_encounters_enriched`; `03` crea `dbo.vw_encounters_clean`; `04` consulta esta última vista.

Al terminar, comprobar:

```sql
SELECT COUNT(*) AS filas,
       COUNT(DISTINCT encounter_id) AS internaciones_distintas,
       COUNT(DISTINCT patient_nbr) AS pacientes_unicos,
       SUM(readmitted_30d) AS reingresos_30d
FROM dbo.vw_encounters_clean;
```

Resultado esperado: **101766, 101766, 71518, 11357**. Si las filas aumentan después de los joins, revisar si los catálogos tienen IDs duplicados; si disminuyen, revisar la carga de origen. La tasa general esperada es **11,159915885… %**.

### 4. Configurar Power BI

Para un informe nuevo: **Inicio → Obtener datos → SQL Server**, indicar el servidor propio y la base `HospitalReadmissions`, elegir **Importar** y seleccionar `dbo.vw_encounters_clean`.

Para actualizar el PBIX existente: usar **Configuración de origen de datos → Cambiar origen** para reemplazar el servidor por el de la nueva instalación y configurar las credenciales propias. Luego pulsar **Actualizar**. Los nombres de tabla y columnas deben coincidir con los del modelo.

`sql/sql.slnx` es un archivo auxiliar del editor. No crea la base ni reemplaza la ejecución de las consultas; se pueden abrir los `.sql` por separado.

## Medidas de referencia en Power BI

Estas expresiones documentan los cálculos del proyecto. Si se reconstruye el informe, crear cada medida por separado con **Nueva medida**, dentro de `vw_encounters_clean`:

```dax
Total Internaciones = COUNTROWS(vw_encounters_clean)
```

```dax
Pacientes Únicos = DISTINCTCOUNT(vw_encounters_clean[patient_nbr])
```

```dax
Reingresos 30d = SUM(vw_encounters_clean[readmitted_30d])
```

```dax
Tasa Reingreso 30d = DIVIDE([Reingresos 30d], [Total Internaciones], 0)
```

```dax
Estadía Promedio = AVERAGE(vw_encounters_clean[time_in_hospital])
```

Formatear la tasa como **porcentaje**: DAX devuelve una proporción, por lo que no se multiplica nuevamente por 100. En las tarjetas de cantidades, usar **Mostrar unidades → Ninguno**, cero decimales y código de formato `#,##0` para el separador de miles. El tercer argumento de `DIVIDE` muestra 0 si el denominador es cero; comprobar el total de internaciones antes de interpretar una selección vacía.

Las agrupaciones de estadía e internaciones previas utilizadas por los gráficos se describen en [metodologia.md](metodologia.md) y en las consultas 6 y 8 del archivo `04_kpis_y_analisis.sql`. El PBIX ya contiene las columnas calculadas `Grupo Estadía`, `Grupo Internaciones Previas` y `Tipo de admisión (ES)`; la traducción al español se usa en el gráfico de admisión.

La segmentación «Tipo de admisión» usa el campo original `admission_type`, por lo que puede mostrar las categorías en inglés aunque el gráfico esté traducido.

## Compartirlo

En GitHub se comparten el PBIX descargable, las consultas, las imágenes y la documentación. El archivo PBIX puede abrirse e interactuarse en Power BI Desktop; una imagen del README es estática.

También existe **Publicar en la web** en Power BI Service. Permite lectura pública interactiva, pero depende de los permisos y la configuración de la cuenta; además expone los datos subyacentes del modelo. Este repositorio no depende de esa modalidad. [Microsoft: publicar en la web](https://learn.microsoft.com/en-us/power-bi/collaborate-share/service-publish-to-web).
