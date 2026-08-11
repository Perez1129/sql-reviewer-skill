# Conventions & Correctness Rules

---

### CONV-01 — Comparación incorrecta con NULL
```
IF WHERE or JOIN condition contains "<col> = NULL" or "<col> != NULL" or "<col> <> NULL"
THEN severity = HIGH
AND message = "'= NULL' / '!= NULL' siempre evalúa a UNKNOWN (nunca TRUE) en SQL estándar. La
   condición nunca hará match como el autor probablemente espera. Usar IS NULL / IS NOT NULL."
```

### CONV-02 — NULL vs valor por defecto ambiguo
```
IF a column intended to be always meaningful (ej. montos, fechas de vencimiento, cantidades)
AND allows NULL without an explicit business justification stated by the user
THEN severity = LOW
AND message = "Permitir NULL en <col> introduce ambigüedad (¿'sin dato' o 'cero'/'no aplica'?).
   Confirmar si es intencional o si conviene NOT NULL + DEFAULT."
NOTE: si no hay contexto de negocio suficiente para saber si NULL es válido aquí, degradar a
INFO en vez de asumir que es un error — no se inventa la regla de negocio.
```

### CONV-03 — Tipo de dato inadecuado
```
IF column stores currency/money AND type = FLOAT or DOUBLE
THEN severity = HIGH
AND message = "FLOAT/DOUBLE introducen errores de redondeo en valores monetarios. Usar
   DECIMAL/NUMERIC con precisión fija."

IF column stores dates/timestamps AND type = VARCHAR/CHAR
THEN severity = MEDIUM
AND message = "Fechas almacenadas como texto impiden comparaciones y ordenamientos correctos,
   y permiten valores inválidos. Usar DATE/DATETIME/TIMESTAMP."

IF column stores boolean-like values (0/1, 'S'/'N', 'true'/'false') AND type = VARCHAR sin
   restricción (CHECK/ENUM)
THEN severity = LOW
AND message = "Valor booleano representado como texto libre permite estados inconsistentes.
   Usar BOOLEAN/BIT o un CHECK/ENUM que restrinja los valores posibles."
```
Si no se provee el esquema con tipos reales, esta categoría completa se reporta como `INFO`
("no se puede evaluar tipos de datos sin definición de esquema"), nunca se asume el tipo.

### CONV-04 — Nombres poco descriptivos
```
IF table or column name matches generic/non-descriptive patterns
   (ej. "data", "info", "temp", "tmp", "col1", "x", "value", "aux", nombres de una sola letra)
THEN severity = LOW
AND message = "El nombre '<nombre>' no comunica su propósito. Usar un nombre descriptivo del
   dominio (ej. 'created_at' en vez de 'x1')."
```

### CONV-05 — Alias no descriptivo en JOIN múltiple
```
IF query has 2+ JOINs
AND table aliases are single ambiguous letters not clearly tied to the table name
   (ej. "a", "b", "c" en vez de "u" para users, "o" para orders)
THEN severity = LOW
AND message = "Con múltiples JOINs, los alias genéricos dificultan la lectura. Preferir alias
   que referencien la tabla."
```

### CONV-06 — Inconsistencia de convención de nombres dentro del mismo script
```
IF the same script mixes naming conventions (ej. snake_case y camelCase en distintas columnas,
   o prefijos inconsistentes como "FC" en unas tablas y ninguno en otras)
THEN severity = LOW
AND message = "Convención de nombres inconsistente dentro del mismo script. Unificar el
   estándar del equipo/proyecto."
```
