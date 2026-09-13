USE HospitalReadmissions;
GO

/* ============================================================
   01. EXPLORACIÓN INICIAL
   Dataset: Diabetes 130-US Hospitals
   Tabla: dbo.diabetic_data_raw
   ============================================================ */

-- 1. Primer vistazo
SELECT TOP 10 *
FROM dbo.diabetic_data_raw;

-- 2. Internaciones y pacientes únicos
SELECT 
    COUNT(*) AS total_internaciones,
    COUNT(DISTINCT patient_nbr) AS pacientes_unicos --con distinct elijo una columna
FROM dbo.diabetic_data_raw;

-- 3. Verificar que encounter_id sea único
SELECT
    COUNT(*) AS total_filas,
    COUNT(DISTINCT encounter_id) AS encounters_unicos
FROM dbo.diabetic_data_raw;

SELECT
    encounter_id,
    COUNT(*) AS cantidad
FROM dbo.diabetic_data_raw
GROUP BY encounter_id
HAVING COUNT(*) > 1;

-- 4. Nombres y tipos de columnas
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'diabetic_data_raw'
ORDER BY ORDINAL_POSITION;

-- 5. Distribución de reingresos
SELECT
    readmitted,
    COUNT(*) AS cantidad,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM dbo.diabetic_data_raw
GROUP BY readmitted
ORDER BY cantidad DESC;

-- 6. Distribución por sexo
SELECT
    gender,
    COUNT(*) AS internaciones,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM dbo.diabetic_data_raw
GROUP BY gender
ORDER BY internaciones DESC;

-- 7. Distribución por edad
SELECT
    age,
    COUNT(*) AS internaciones,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM dbo.diabetic_data_raw
GROUP BY age
ORDER BY age;

-- 8. Duración de la internación
SELECT
    MIN(time_in_hospital) AS estadia_minima,
    MAX(time_in_hospital) AS estadia_maxima,
    ROUND(AVG(CAST(time_in_hospital AS FLOAT)), 2) AS estadia_promedio
FROM dbo.diabetic_data_raw;

SELECT
    time_in_hospital,
    COUNT(*) AS internaciones
FROM dbo.diabetic_data_raw
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- 9. Utilización de recursos
SELECT
    ROUND(AVG(CAST(num_lab_procedures AS FLOAT)), 2) AS promedio_laboratorios,
    ROUND(AVG(CAST(num_procedures AS FLOAT)), 2) AS promedio_procedimientos,
    ROUND(AVG(CAST(num_medications AS FLOAT)), 2) AS promedio_medicamentos
FROM dbo.diabetic_data_raw;

-- 10. Uso previo del sistema
SELECT
    ROUND(AVG(CAST(number_outpatient AS FLOAT)), 2) AS promedio_outpatient,
    ROUND(AVG(CAST(number_emergency AS FLOAT)), 2) AS promedio_emergency,
    ROUND(AVG(CAST(number_inpatient AS FLOAT)), 2) AS promedio_inpatient
FROM dbo.diabetic_data_raw;

SELECT
    MAX(number_outpatient) AS max_outpatient,
    MAX(number_emergency) AS max_emergency,
    MAX(number_inpatient) AS max_inpatient
FROM dbo.diabetic_data_raw;

-- 11. Tipos de admisión
SELECT
    admission_type_id,
    COUNT(*) AS internaciones
FROM dbo.diabetic_data_raw
GROUP BY admission_type_id
ORDER BY internaciones DESC;

-- 12. Origen de admisión
SELECT
    admission_source_id,
    COUNT(*) AS internaciones
FROM dbo.diabetic_data_raw
GROUP BY admission_source_id
ORDER BY internaciones DESC;

-- 13. Disposición al alta
SELECT
    discharge_disposition_id,
    COUNT(*) AS internaciones
FROM dbo.diabetic_data_raw
GROUP BY discharge_disposition_id
ORDER BY internaciones DESC;

-- 14. Faltantes codificados como '?'
SELECT
    SUM(CASE WHEN race = '?' THEN 1 ELSE 0 END) AS race_missing,
    SUM(CASE WHEN weight = '?' THEN 1 ELSE 0 END) AS weight_missing,
    SUM(CASE WHEN payer_code = '?' THEN 1 ELSE 0 END) AS payer_code_missing,
    SUM(CASE WHEN medical_specialty = '?' THEN 1 ELSE 0 END) AS medical_specialty_missing
FROM dbo.diabetic_data_raw;

SELECT
    ROUND(100.0 * SUM(CASE WHEN race = '?' THEN 1 ELSE 0 END) / COUNT(*), 2) AS race_missing_pct,
    ROUND(100.0 * SUM(CASE WHEN weight = '?' THEN 1 ELSE 0 END) / COUNT(*), 2) AS weight_missing_pct,
    ROUND(100.0 * SUM(CASE WHEN payer_code = '?' THEN 1 ELSE 0 END) / COUNT(*), 2) AS payer_code_missing_pct,
    ROUND(100.0 * SUM(CASE WHEN medical_specialty = '?' THEN 1 ELSE 0 END) / COUNT(*), 2) AS medical_specialty_missing_pct
FROM dbo.diabetic_data_raw;

-- 15. Diagnósticos principales más frecuentes
SELECT TOP 15
    diag_1,
    COUNT(*) AS cantidad
FROM dbo.diabetic_data_raw
GROUP BY diag_1
ORDER BY cantidad DESC;

-- 16. Cantidad de diagnósticos
SELECT
    MIN(number_diagnoses) AS minimo_diagnosticos,
    MAX(number_diagnoses) AS maximo_diagnosticos,
    ROUND(AVG(CAST(number_diagnoses AS FLOAT)), 2) AS promedio_diagnosticos
FROM dbo.diabetic_data_raw;

-- 17. Medicación para diabetes
SELECT
    diabetesMed,
    COUNT(*) AS cantidad
FROM dbo.diabetic_data_raw
GROUP BY diabetesMed
ORDER BY cantidad DESC;

-- 18. Cambio en medicación
SELECT
    change,
    COUNT(*) AS cantidad
FROM dbo.diabetic_data_raw
GROUP BY change
ORDER BY cantidad DESC;

-- 19. Duración de internación según reingreso
SELECT
    readmitted,
    COUNT(*) AS internaciones,
    ROUND(AVG(CAST(time_in_hospital AS FLOAT)), 2) AS estadia_promedio
FROM dbo.diabetic_data_raw
GROUP BY readmitted
ORDER BY estadia_promedio DESC;

-- 20. Reingreso por grupo etario
SELECT
    age,
    readmitted,
    COUNT(*) AS cantidad
FROM dbo.diabetic_data_raw
GROUP BY age, readmitted
ORDER BY age, readmitted;
