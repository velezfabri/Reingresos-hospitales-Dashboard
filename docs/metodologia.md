# Definiciones y decisiones metodológicas

## Unidad de análisis

Una fila corresponde a una internación, identificada por `encounter_id`. `patient_nbr` permite contar pacientes distintos. Los 101.766 registros corresponden a 71.518 identificadores de paciente: el análisis conserva las internaciones repetidas de un mismo paciente.

## Reingreso en menos de 30 días

El campo original `readmitted` se transforma así:

```sql
CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END AS readmitted_30d
```

Se utiliza la clasificación provista por el dataset, sin reconstruir fechas de ingreso y alta. El rótulo «30d» abrevia la categoría **<30 días**.

La tasa general se calcula como:

```sql
100.0 * SUM(readmitted_30d) / COUNT(*)
```

Por ejemplo, 11.357 / 101.766 × 100 = 11,1599… %. La tarjeta con un decimal muestra 11,2 %. Cada barra aplica esa misma fórmula dentro de su grupo y de los filtros activos. No es un promedio simple de los porcentajes de las barras.

`readmitted_any` vale 1 para las categorías originales `<30` y `>30`; tiene otro significado y no es el numerador de los cuatro gráficos principales.

## Limpieza y enriquecimiento

- Los `LEFT JOIN` agregan las descripciones de tres catálogos administrativos. Se verifica la unicidad de sus claves para no multiplicar internaciones.
- `NULLIF(campo, '?')` convierte ese código de faltante a `NULL` en `race`, `weight`, `payer_code`, `medical_specialty` y los tres diagnósticos.
- No se imputan esos faltantes ni se eliminan filas por ellos.
- Los diagnósticos se conservan como texto: sus códigos pueden incluir letras o puntos.
- `prior_healthcare_visits` suma `number_outpatient`, `number_emergency` y `number_inpatient`, usando `ISNULL(..., 0)` en la suma.
- La vista limpia selecciona campos para el análisis. Conserva el número de filas, pero no reproduce todas las columnas de medicación de la tabla original.

El catálogo incluye la cadena de texto `NULL`, además de «Not Available» y «Not Mapped». Son valores administrativos del origen. Una comprobación `IS NULL` detecta nulos SQL, pero no esa cadena literal. En el rediseño se muestran como «No informado», «No disponible» y «Sin mapear», manteniendo categorías separadas.

## Agrupaciones

| Análisis | Campo | Categorías |
|---|---|---|
| Admisión | `admission_type_id` y su descripción | Catálogo original; etiquetas en español en el rediseño |
| Internaciones previas | `number_inpatient` | 0, 1, 2, 3+ |
| Edad | `age` | Intervalos originales de 10 años |
| Estadía | `time_in_hospital` | 1–3, 4–7, 8+ días |

Las visitas previas del dataset corresponden al año anterior a la internación. `number_inpatient` describe internaciones en ese período; no se calculó contando filas anteriores del paciente en este archivo. [Diccionario de UCI](https://archive.ics.uci.edu/dataset/296/diabetes+130+us+hospitals+for+years+1999+2008).

## Interpretación

El grupo «Centro de trauma» contiene 21 internaciones y ningún reingreso `<30`; «Recién nacido» contiene 10 y un reingreso. Tasas de grupos tan pequeños son muy sensibles a unos pocos registros. Por eso los gráficos de documentación muestran `n` y los SQL conservan numerador y denominador.

Se mantienen todos los registros de origen, sin exclusiones adicionales por disposición al alta, fallecimiento o cuidados paliativos. La tasa no está ajustada por gravedad, comorbilidades ni diferencias entre grupos. No permite atribuir causalidad, medir el riesgo individual ni comparar hospitales mediante un estándar de calidad.

## Verificación de los resultados

Se recalcularon los indicadores y las cuatro agrupaciones desde `data/diabetic_data.csv`, incluido en este repositorio. Se comprobaron 101.766 filas y `encounter_id` distintos, 71.518 pacientes y 11.357 etiquetas `<30`. Los grupos de cada gráfico suman el total de internaciones y reingresos, y sus porcentajes coinciden a dos decimales con los resultados documentados durante el desarrollo del informe.

Los valores y el SHA-256 del CSV están en [resultados_verificados.json](resultados_verificados.json). Los catálogos proporcionados tienen claves únicas y cubren todos los códigos presentes en ese CSV. También se inspeccionó el PBIX actualizado: contiene cinco tarjetas, cuatro gráficos con tooltips de conteos y la acción `ClearAllSlicers` del botón. La validación se limita a datos y definiciones; no se ejecutó SQL Server ni el motor visual de Power BI Desktop en este entorno.
