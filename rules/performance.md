# Performance Rules


### PERF-01 — SELECT * 
IF statement = SELECT
AND columns = "*"
THEN severity = MEDIUM
AND message = "SELECT * trae columnas innecesarias, rompe con cambios de esquema y dificulta
   usar índices de cobertura. Listar columnas explícitamente."
EXCEPTION:
IF SELECT * is used inside EXISTS(...) or COUNT(*) context
THEN severity = LOW
AND message = "SELECT * dentro de EXISTS/COUNT es aceptable, pero preferir SELECT 1 por claridad."


### PERF-02 — LIMIT ausente en consulta potencialmente masiva
IF statement = SELECT
AND LIMIT is absent
AND WHERE is absent OR WHERE predicate is not selective (ver SEC-02)
AND query is not an aggregate-only query (no COUNT/SUM/AVG sin GROUP BY que colapse a una fila)
THEN severity = HIGH
AND message = "Consulta sin LIMIT y sin filtro selectivo: riesgo de traer un volumen de filas
   no acotado. Agregar LIMIT/paginación o un WHERE selectivo."


### PERF-03 — LIMIT presente pero inútil
IF statement = SELECT
AND LIMIT is present
AND LIMIT value > threshold (ej. > 100,000, o mayor al tamaño razonable esperado de la tabla)
THEN severity = MEDIUM
AND message = "El LIMIT declarado es tan alto que no mitiga el riesgo real. Un LIMIT no protege
   por sí solo si el valor es igual o mayor al total de filas esperado."

Justificación directa del caso Red Team: `SELECT * FROM TA_USERS LIMIT 1000000000;` — tiene
LIMIT, pero no cumple el propósito de acotar el resultado. Este caso se marca PERF-01 (MEDIUM) +
PERF-03 (MEDIUM), no se descarta solo por "tiene LIMIT".

### PERF-04 — Sintaxis de paginación dependiente del motor
IF query uses LIMIT/TOP/ROWNUM/FETCH FIRST
AND target engine was not specified by the user
THEN severity = INFO
AND message = "La sintaxis de paginación difiere entre motores (LIMIT en MySQL/Postgres, TOP en
   SQL Server, ROWNUM/FETCH FIRST en Oracle). Se asumió sintaxis ANSI/MySQL genérica; confirmar
   el motor objetivo si esto es relevante."


### PERF-05 — Índice potencialmente faltante
IF WHERE or JOIN condition filters on <col>
AND schema context was provided
AND <col> is not marked as indexed/PK/unique in that schema
AND table is expected to be large (declarado por el usuario o evidencia en el propio script)
THEN severity = MEDIUM
AND message = "La columna <col> se usa como filtro/join y no aparece indexada. Evaluar agregar
   un índice si la tabla es grande."
ELSE IF schema context was NOT provided
THEN severity = INFO
AND message = "No se puede confirmar si <col> está indexada: no se proveyó esquema. No se asume
   la existencia ni ausencia del índice."


### PERF-06 — JOIN sin condición (producto cartesiano)
IF statement contains JOIN (or comma-join in FROM)
AND no matching ON/USING/WHERE join predicate is present between the involved tables
THEN severity = HIGH
AND message = "JOIN sin condición de unión: genera producto cartesiano. Verificar si es
   intencional; si no, agregar la condición ON/WHERE correspondiente."


### PERF-07 — ORDER BY sobre columna no indexada con LIMIT alto o ausente
IF statement = SELECT
AND ORDER BY is present on <col>
AND (LIMIT is absent OR LIMIT is high, ver PERF-03)
AND schema context provided AND <col> not indexed
THEN severity = MEDIUM
AND message = "ORDER BY sin índice de soporte y sin LIMIT bajo puede forzar un sort completo
   costoso. Considerar índice o acotar el resultado."

### PERF-08 — Función aplicada sobre columna indexada en WHERE (sargable)
IF WHERE clause wraps an indexed column in a function (ej. UPPER(col) = ..., YEAR(col) = ...)
THEN severity = MEDIUM
AND message = "Aplicar una función sobre la columna en el WHERE impide usar el índice
   (no-sargable). Considerar reescribir la condición o usar un índice funcional si el motor
   lo soporta."

