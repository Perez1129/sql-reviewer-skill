# Security Rules

Reglas de seguridad y operaciones destructivas. Cada regla tiene un ID único usado en los
reportes de hallazgos.

---

### SEC-01 — WHERE ausente en UPDATE/DELETE
```
IF statement = DELETE OR statement = UPDATE
AND WHERE is absent
THEN severity = CRITICAL
AND message = "La sentencia afecta todas las filas de la tabla. No ejecutar sin WHERE."
AND do not recommend executing the statement
```

### SEC-02 — WHERE tautológico (evade SEC-01 superficialmente)
```
IF statement = DELETE OR statement = UPDATE
AND WHERE is present
AND WHERE condition matches any of:
    - "1 = 1", "TRUE", "'a' = 'a'"
    - "<col> = <col>" (misma columna a ambos lados)
    - "<col> LIKE '%'" (comodín total, sin texto significativo)
    - "<col> IS NOT NULL" cuando <col> es NOT NULL por definición (siempre verdadero)
THEN severity = CRITICAL
AND message = "El WHERE existe pero es equivalente a no tener WHERE: afecta todas las filas."
```
Justificación: el caso del Red Team `DELETE FROM TA_USERS WHERE 1 = 1;` y
`UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%';` deben ser detectados aquí, no solo
por "existe un WHERE".

### SEC-03 — Concatenación de SQL / riesgo de SQL Injection
```
IF query is built via string concatenation with an external/unvalidated variable
   (e.g. "..." + var, "..." || var, string formatting %s/f-string embedding a variable
   directly into SQL text, en vez de parámetros bind / prepared statements)
THEN severity = CRITICAL
AND message = "Concatenación directa de variables en SQL. Usar consultas parametrizadas."
```
Nota: si el input es SQL puro sin capa de aplicación visible, esta regla se activa solo cuando el
propio texto muestra evidencia de concatenación (ej. comentarios, placeholders tipo `{}`/`?var`
mal usados, o el usuario pega código de aplicación junto al SQL).

### SEC-04 — Operación destructiva sin salvaguarda visible
```
IF statement = DROP TABLE|DROP DATABASE|TRUNCATE
THEN severity = CRITICAL
AND message = "Operación irreversible. Verificar backup y confirmar alcance antes de ejecutar."
```

### SEC-05 — DELETE/UPDATE masivo sin transacción explícita
```
IF statement = DELETE OR statement = UPDATE
AND affects a large/unknown number of rows (no LIMIT, WHERE poco selectivo)
AND no evidence of transaction wrapping (BEGIN/COMMIT) in the provided script
THEN severity = MEDIUM
AND message = "Operación masiva fuera de una transacción explícita: no hay forma sencilla de
   revertir si algo sale mal. Considerar envolver en una transacción con revisión previa."
```

### SEC-06 — Permisos/roles otorgados por condición débil
```
IF statement = UPDATE
AND SET clause modifies a column that looks like a role/permission/privilege field
    (nombre de columna contiene "role", "admin", "permission", "is_admin", etc.)
AND WHERE condition is broad (ver SEC-02) or ausente
THEN severity = CRITICAL
AND message = "Cambio de rol/permiso con condición insuficientemente selectiva. Alto riesgo de
   escalamiento de privilegios accidental o malicioso."
```
