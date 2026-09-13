# Datos utilizados

| Archivo | Uso |
|---|---|
| `diabetic_data.csv` | 101.766 registros de internaciones, con 50 columnas de origen |
| `IDS_mapping.csv` | Catálogos originales reunidos en tres bloques |
| `admission_type.csv` | 8 tipos de admisión; importar como `dbo.dim_admission_type` |
| `discharge_disposition.csv` | 30 disposiciones al alta; importar como `dbo.dim_discharge_disposition` |
| `admission_source.csv` | 25 orígenes de admisión; importar como `dbo.dim_admission_source` |

Se incluyen los archivos utilizados en el proyecto, con sus nombres normalizados y sin cambios en sus bytes. Los catálogos separados conservan la cadena de texto `NULL`; no equivale automáticamente a un nulo SQL.

Fuente: [UCI, DOI 10.24432/C5230J](https://doi.org/10.24432/C5230J). Los créditos completos y la licencia CC BY 4.0 del dataset figuran en el [README principal](../README.md#fuente-y-créditos).

Para cargar los archivos en SQL Server, seguir [la guía de reproducción](../docs/reproducir.md).
