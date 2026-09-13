USE HospitalReadmissions;
GO

/* ============================================================
   03. LIMPIEZA Y PREPARACIÓN DE DATOS

   Objetivo:
   - No modificar la tabla RAW.
   - Convertir valores faltantes codificados como '?' a NULL.
   - Crear variables útiles para el análisis.
   - Dejar una vista lista para KPIs y Power BI.
   ============================================================ */

GO

CREATE OR ALTER VIEW dbo.vw_encounters_clean
AS

SELECT
    encounter_id,
    patient_nbr,

    NULLIF(race, '?') AS race,
    gender,
    age,

    NULLIF(weight, '?') AS weight,
    NULLIF(payer_code, '?') AS payer_code,
    NULLIF(medical_specialty, '?') AS medical_specialty,

    admission_type_id,
    admission_type,

    discharge_disposition_id,
    discharge_disposition,

    admission_source_id,
    admission_source,

    time_in_hospital,

    num_lab_procedures,
    num_procedures,
    num_medications,

    number_outpatient,
    number_emergency,
    number_inpatient,

    (
        ISNULL(number_outpatient, 0) +
        ISNULL(number_emergency, 0) +
        ISNULL(number_inpatient, 0)
    ) AS prior_healthcare_visits,

    /* Los diagnósticos vienen codificados con ICD-9.
       '?' significa diagnóstico no disponible. */
    NULLIF(diag_1, '?') AS diag_1,
    NULLIF(diag_2, '?') AS diag_2,
    NULLIF(diag_3, '?') AS diag_3,

    number_diagnoses,

    max_glu_serum,
    A1Cresult,

    change,
    diabetesMed,

    readmitted,

    /* 1 = reingreso dentro de 30 días
       0 = no reingresó dentro de 30 días */
    CASE
        WHEN readmitted = '<30' THEN 1
        ELSE 0
    END AS readmitted_30d,

    /* 1 = hubo algún reingreso
       0 = no hubo reingreso */
    CASE
        WHEN readmitted IN ('<30', '>30') THEN 1
        ELSE 0
    END AS readmitted_any

FROM dbo.vw_encounters_enriched;
GO


/* ------------------------------------------------------------
   1. Probar la nueva vista
   ------------------------------------------------------------ */

SELECT TOP 20 *
FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   2. Confirmar que no perdimos filas
   ------------------------------------------------------------ */

SELECT
    (SELECT COUNT(*) FROM dbo.diabetic_data_raw) AS filas_raw,
    (SELECT COUNT(*) FROM dbo.vw_encounters_clean) AS filas_clean;


/* ------------------------------------------------------------
   3. Revisar valores faltantes generales
   ------------------------------------------------------------ */

SELECT
    SUM(CASE WHEN race IS NULL THEN 1 ELSE 0 END) AS race_null,
    SUM(CASE WHEN weight IS NULL THEN 1 ELSE 0 END) AS weight_null,
    SUM(CASE WHEN payer_code IS NULL THEN 1 ELSE 0 END) AS payer_code_null,
    SUM(CASE WHEN medical_specialty IS NULL THEN 1 ELSE 0 END) AS medical_specialty_null
FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   4. Revisar valores faltantes en diagnósticos

   diag_1 = diagnóstico principal
   diag_2 = diagnóstico secundario
   diag_3 = diagnóstico secundario adicional

   Los tres están codificados mediante ICD-9.
   ------------------------------------------------------------ */

SELECT
    SUM(CASE WHEN diag_1 IS NULL THEN 1 ELSE 0 END) AS diag_1_null,
    SUM(CASE WHEN diag_2 IS NULL THEN 1 ELSE 0 END) AS diag_2_null,
    SUM(CASE WHEN diag_3 IS NULL THEN 1 ELSE 0 END) AS diag_3_null
FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   5. Revisar las nuevas variables de reingreso
   ------------------------------------------------------------ */

SELECT
    readmitted,
    readmitted_30d,
    readmitted_any,
    COUNT(*) AS cantidad
FROM dbo.vw_encounters_clean
GROUP BY
    readmitted,
    readmitted_30d,
    readmitted_any
ORDER BY readmitted;


/* ------------------------------------------------------------
   6. Tasa de reingreso dentro de 30 días

   IMPORTANTE:
   Esta tasa está calculada sobre INTERNACIONES (encounters),
   no sobre pacientes únicos.

   readmitted_30d vale:
   - 1 si esa internación terminó seguida de un reingreso <30 días
   - 0 en los demás casos

   SUM(readmitted_30d) cuenta los reingresos <30 días.
   COUNT(*) cuenta todas las internaciones.
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS total_internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   7. Recordatorio: pacientes únicos vs internaciones
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS total_internaciones,
    COUNT(DISTINCT patient_nbr) AS pacientes_unicos
FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   8. Uso previo del sistema de salud
   ------------------------------------------------------------ */

SELECT
    MIN(prior_healthcare_visits) AS minimo_visitas_previas,
    MAX(prior_healthcare_visits) AS maximo_visitas_previas,
    ROUND(AVG(CAST(prior_healthcare_visits AS FLOAT)), 2)
        AS promedio_visitas_previas
FROM dbo.vw_encounters_clean;
