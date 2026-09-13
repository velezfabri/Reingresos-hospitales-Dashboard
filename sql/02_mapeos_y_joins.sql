USE HospitalReadmissions;
GO

/* ============================================================
   02. MAPEOS Y JOINS

   Estas consultas asumen que ya importamos tres tablas:
   - dbo.dim_admission_type
   - dbo.dim_discharge_disposition
   - dbo.dim_admission_source
   ============================================================ */


/* ------------------------------------------------------------
   1. Verificar que las tablas de referencia estén cargadas
   ------------------------------------------------------------ */

SELECT *
FROM dbo.dim_admission_type
ORDER BY admission_type_id;

SELECT *
FROM dbo.dim_discharge_disposition
ORDER BY discharge_disposition_id;

SELECT *
FROM dbo.dim_admission_source
ORDER BY admission_source_id;


/* ------------------------------------------------------------
   2. Primer JOIN:
      traducir admission_type_id a su descripción
   ------------------------------------------------------------ */

SELECT TOP 20
    d.encounter_id,
    d.patient_nbr,
    d.age,
    d.admission_type_id,
    a.description AS admission_type
FROM dbo.diabetic_data_raw AS d
LEFT JOIN dbo.dim_admission_type AS a
    ON d.admission_type_id = a.admission_type_id;


/* ------------------------------------------------------------
   3. Contar internaciones por tipo de admisión
   Ahora usamos nombres en lugar de IDs.
   ------------------------------------------------------------ */

SELECT
    a.description AS admission_type,
    COUNT(*) AS internaciones
FROM dbo.diabetic_data_raw AS d
LEFT JOIN dbo.dim_admission_type AS a
    ON d.admission_type_id = a.admission_type_id
GROUP BY a.description
ORDER BY internaciones DESC;


/* ------------------------------------------------------------
   4. JOIN con las tres tablas de referencia
   ------------------------------------------------------------ */

SELECT TOP 20
    d.encounter_id,
    d.patient_nbr,
    d.age,
    d.gender,
    d.time_in_hospital,

    d.admission_type_id,
    a.description AS admission_type,

    d.discharge_disposition_id,
    dd.description AS discharge_disposition,

    d.admission_source_id,
    s.description AS admission_source,

    d.readmitted

FROM dbo.diabetic_data_raw AS d

LEFT JOIN dbo.dim_admission_type AS a
    ON d.admission_type_id = a.admission_type_id

LEFT JOIN dbo.dim_discharge_disposition AS dd
    ON d.discharge_disposition_id = dd.discharge_disposition_id

LEFT JOIN dbo.dim_admission_source AS s
    ON d.admission_source_id = s.admission_source_id;


/* ------------------------------------------------------------
   IMPORTANTE:
   CREATE OR ALTER VIEW tiene que comenzar un batch nuevo.
   ------------------------------------------------------------ */

GO


/* ------------------------------------------------------------
   5. Crear una vista enriquecida

   Una VIEW es una consulta guardada que podemos reutilizar.
   No duplica los datos: muestra la información a partir de las
   tablas originales cada vez que la consultamos.
   ------------------------------------------------------------ */

CREATE OR ALTER VIEW dbo.vw_encounters_enriched
AS

SELECT
    d.*,
    a.description AS admission_type,
    dd.description AS discharge_disposition,
    s.description AS admission_source

FROM dbo.diabetic_data_raw AS d

LEFT JOIN dbo.dim_admission_type AS a
    ON d.admission_type_id = a.admission_type_id

LEFT JOIN dbo.dim_discharge_disposition AS dd
    ON d.discharge_disposition_id = dd.discharge_disposition_id

LEFT JOIN dbo.dim_admission_source AS s
    ON d.admission_source_id = s.admission_source_id;
GO


/* ------------------------------------------------------------
   6. Probar la vista
   ------------------------------------------------------------ */

SELECT TOP 20
    encounter_id,
    age,
    gender,
    admission_type,
    discharge_disposition,
    admission_source,
    time_in_hospital,
    readmitted
FROM dbo.vw_encounters_enriched;


/* ------------------------------------------------------------
   7. Verificar si quedaron IDs sin descripción

   Si da 0 en las tres columnas, todos los IDs encontraron
   correctamente su descripción en las tablas de referencia.
   ------------------------------------------------------------ */

SELECT
    SUM(CASE WHEN admission_type IS NULL THEN 1 ELSE 0 END)
        AS admission_type_sin_mapeo,

    SUM(CASE WHEN discharge_disposition IS NULL THEN 1 ELSE 0 END)
        AS discharge_sin_mapeo,

    SUM(CASE WHEN admission_source IS NULL THEN 1 ELSE 0 END)
        AS admission_source_sin_mapeo

FROM dbo.vw_encounters_enriched;
