USE HospitalReadmissions;
GO

/* ============================================================
   04. KPIs Y ANÁLISIS

   Fuente:
   dbo.vw_encounters_clean

   Objetivo:
   - Calcular KPIs principales.
   - Analizar reingreso a 30 días por distintas dimensiones.
   - Explorar patrones de utilización hospitalaria.
   ============================================================ */


/* ------------------------------------------------------------
   1. KPIs GENERALES
   ------------------------------------------------------------ */

SELECT
    COUNT(*) AS total_internaciones,
    COUNT(DISTINCT patient_nbr) AS pacientes_unicos,

    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct,

    ROUND(
        AVG(CAST(time_in_hospital AS FLOAT)),
        2
    ) AS estadia_promedio_dias,

    ROUND(
        AVG(CAST(num_medications AS FLOAT)),
        2
    ) AS medicamentos_promedio

FROM dbo.vw_encounters_clean;


/* ------------------------------------------------------------
   2. REINGRESO A 30 DÍAS POR GRUPO ETARIO
   ------------------------------------------------------------ */

SELECT
    age,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY age
ORDER BY age;


/* ------------------------------------------------------------
   3. REINGRESO A 30 DÍAS POR SEXO
   ------------------------------------------------------------ */

SELECT
    gender,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY gender
ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   4. REINGRESO POR TIPO DE ADMISIÓN
   ------------------------------------------------------------ */

SELECT
    admission_type,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY admission_type
ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   5. REINGRESO Y DURACIÓN DE LA INTERNACIÓN
   ------------------------------------------------------------ */

SELECT
    time_in_hospital,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY time_in_hospital
ORDER BY time_in_hospital;


/* ------------------------------------------------------------
   6. AGRUPAR LA DURACIÓN DE INTERNACIÓN

   Creamos categorías más fáciles de visualizar:
   - 1 a 3 días
   - 4 a 7 días
   - 8 días o más
   ------------------------------------------------------------ */

SELECT
    CASE
        WHEN time_in_hospital <= 3 THEN '1-3 días'
        WHEN time_in_hospital <= 7 THEN '4-7 días'
        ELSE '8+ días'
    END AS grupo_estadia,

    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY
    CASE
        WHEN time_in_hospital <= 3 THEN '1-3 días'
        WHEN time_in_hospital <= 7 THEN '4-7 días'
        ELSE '8+ días'
    END

ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   7. REINGRESO SEGÚN USO PREVIO DEL SISTEMA DE SALUD

   prior_healthcare_visits =
       number_outpatient
     + number_emergency
     + number_inpatient

   Agrupamos para que sea más fácil interpretar.
   ------------------------------------------------------------ */

SELECT
    CASE
        WHEN prior_healthcare_visits = 0 THEN '0 visitas'
        WHEN prior_healthcare_visits BETWEEN 1 AND 2 THEN '1-2 visitas'
        WHEN prior_healthcare_visits BETWEEN 3 AND 5 THEN '3-5 visitas'
        ELSE '6+ visitas'
    END AS grupo_visitas_previas,

    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY
    CASE
        WHEN prior_healthcare_visits = 0 THEN '0 visitas'
        WHEN prior_healthcare_visits BETWEEN 1 AND 2 THEN '1-2 visitas'
        WHEN prior_healthcare_visits BETWEEN 3 AND 5 THEN '3-5 visitas'
        ELSE '6+ visitas'
    END

ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   8. SEPARAR OUTPATIENT, EMERGENCY E INPATIENT

   Queremos ver cuál de estas variables parece asociarse más
   con el reingreso temprano.
   ------------------------------------------------------------ */

SELECT
    CASE
        WHEN number_inpatient = 0 THEN '0'
        WHEN number_inpatient = 1 THEN '1'
        WHEN number_inpatient = 2 THEN '2'
        ELSE '3+'
    END AS internaciones_previas,

    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY
    CASE
        WHEN number_inpatient = 0 THEN '0'
        WHEN number_inpatient = 1 THEN '1'
        WHEN number_inpatient = 2 THEN '2'
        ELSE '3+'
    END

ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   9. REINGRESO SEGÚN CAMBIO EN MEDICACIÓN
   ------------------------------------------------------------ */

SELECT
    change,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY change
ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   10. REINGRESO SEGÚN USO DE MEDICACIÓN PARA DIABETES
   ------------------------------------------------------------ */

SELECT
    diabetesMed,
    COUNT(*) AS internaciones,
    SUM(readmitted_30d) AS reingresos_30d,

    ROUND(
        100.0 * SUM(readmitted_30d) / COUNT(*),
        2
    ) AS tasa_reingreso_30d_pct

FROM dbo.vw_encounters_clean

GROUP BY diabetesMed
ORDER BY tasa_reingreso_30d_pct DESC;


/* ------------------------------------------------------------
   11. PACIENTES CON MÁS INTERNACIONES REGISTRADAS

   Acá sí agrupamos por paciente.
   ------------------------------------------------------------ */

SELECT TOP 20
    patient_nbr,
    COUNT(*) AS cantidad_internaciones

FROM dbo.vw_encounters_clean

GROUP BY patient_nbr
ORDER BY cantidad_internaciones DESC;


/* ------------------------------------------------------------
   12. CTE: RESUMEN POR PACIENTE

   Una CTE es una tabla temporal lógica que existe solamente
   durante esta consulta.

   Acá resumimos cada paciente en una sola fila.
   ------------------------------------------------------------ */

WITH patient_summary AS (

    SELECT
        patient_nbr,
        COUNT(*) AS total_internaciones,
        SUM(readmitted_30d) AS episodios_reingreso_30d,
        AVG(CAST(time_in_hospital AS FLOAT)) AS estadia_promedio

    FROM dbo.vw_encounters_clean

    GROUP BY patient_nbr
)

SELECT TOP 20
    patient_nbr,
    total_internaciones,
    episodios_reingreso_30d,
    ROUND(estadia_promedio, 2) AS estadia_promedio

FROM patient_summary

ORDER BY total_internaciones DESC;


/* ------------------------------------------------------------
   13. DISTRIBUCIÓN DE INTERNACIONES POR PACIENTE
   ------------------------------------------------------------ */

WITH patient_summary AS (

    SELECT
        patient_nbr,
        COUNT(*) AS total_internaciones

    FROM dbo.vw_encounters_clean

    GROUP BY patient_nbr
)

SELECT
    CASE
        WHEN total_internaciones = 1 THEN '1 internación'
        WHEN total_internaciones = 2 THEN '2 internaciones'
        WHEN total_internaciones = 3 THEN '3 internaciones'
        ELSE '4+ internaciones'
    END AS grupo_internaciones,

    COUNT(*) AS pacientes

FROM patient_summary

GROUP BY
    CASE
        WHEN total_internaciones = 1 THEN '1 internación'
        WHEN total_internaciones = 2 THEN '2 internaciones'
        WHEN total_internaciones = 3 THEN '3 internaciones'
        ELSE '4+ internaciones'
    END

ORDER BY grupo_internaciones;
