# SQL Reviewer

## Purpose
Actuar como revisor técnico de sentencias y scripts SQL. La skill analiza SQL entregado por el
usuario y produce un reporte estructurado de hallazgos clasificados por severidad, con
recomendaciones concretas. No genera SQL desde cero, no ejecuta el SQL, y no asume intención
del usuario más allá de lo que el texto y el contexto explícitamente permiten inferir.

## When to activate
- El input contiene una o más sentencias SQL identificables (`SELECT`, `INSERT`, `UPDATE`,
  `DELETE`, `CREATE`, `ALTER`, `DROP`, `MERGE`, etc.), ya sea pegadas directamente o en un
  archivo `.sql`.
- El usuario pide explícitamente revisión, auditoría, "code review" o "¿está bien este SQL?".
- El usuario pega un script con múltiples sentencias separadas por `;`.

## When NOT to activate
- El input no contiene SQL identificable (texto plano, otro lenguaje de programación, JSON, etc.).
- Se pide **generar** SQL nuevo sin código previo que revisar (es una responsabilidad distinta,
  fuera del alcance de esta skill).
- El SQL es en realidad DDL de otra tecnología no relacional (ej. sintaxis de un motor NoSQL) —
  se informa que está fuera de alcance en vez de forzar un análisis.
- El texto parece SQL pero está tan corrompido/truncado que no se puede tokenizar en sentencias
  (ver "Failure handling").

## Inputs
- **Requerido:** texto SQL crudo (una o más sentencias).
- **Opcional:** motor de base de datos objetivo (MySQL, PostgreSQL, SQL Server, Oracle, SQLite).
  Si no se especifica, se analiza como SQL ANSI genérico y se marca explícitamente cualquier
  regla cuyo resultado dependa del motor (ver rule `PERF-04` en `rules/performance.md`).
- **Opcional:** contexto de esquema (definición de tablas/columnas, índices existentes). Si no se
  provee, las reglas que dependen de esquema (tipos de datos reales, índices existentes) no se
  evalúan de forma concluyente y se emite un hallazgo `INFO` en su lugar — nunca se asume el
  esquema.

## Procedure
1. **Tokenizar**: separar el input en sentencias individuales (por `;` respetando strings/comentarios).
2. **Clasificar** cada sentencia por tipo (`SELECT`, `INSERT`, `UPDATE`, `DELETE`, `DDL`, otro).
3. **Verificar sintaxis mínima**: si una sentencia no es parseable, no se revisa su contenido;
   se reporta como fallo de parseo (ver Failure handling).
4. Para cada sentencia válida, ejecutar las categorías de reglas en este orden fijo:
   1. Seguridad (`rules/security.md`)
   2. Operaciones destructivas (`rules/security.md`)
   3. Corrección lógica (NULL, tipos) (`rules/conventions.md`)
   4. Rendimiento (`rules/performance.md`)
   5. Convenciones de nombres (`rules/conventions.md`)
5. Cada hallazgo debe citar el **rule ID** exacto que lo originó (ej. `SEC-01`). No se permiten
   hallazgos "por impresión general" sin una regla que los respalde.
6. Si una regla requiere información no disponible (esquema, motor), no se infiere: se emite un
   hallazgo `INFO` indicando qué información falta y por qué no se pudo evaluar.
7. Nunca se reescribe el SQL del usuario a menos que se pida explícitamente; se puede sugerir un
   ejemplo corregido dentro de la recomendación de un hallazgo.
8. Se arma el reporte final: por sentencia + resumen general (severidad máxima encontrada).

## Rules
El detalle formal de cada regla vive en `rules/security.md`, `rules/performance.md` y
`rules/conventions.md`. Resumen de cobertura mínima obligatoria:

| Categoría | Reglas |
|---|---|
| Seguridad | `SELECT *`, WHERE ausente o tautológico en UPDATE/DELETE, concatenación de SQL (SQLi), operaciones destructivas sin salvaguardas |
| Rendimiento | LIMIT ausente o inútil, índices potencialmente faltantes, `ORDER BY` sin índice, joins cartesianos |
| Corrección | uso incorrecto de NULL (`= NULL` / `!= NULL`), tipos de datos inadecuados |
| Convenciones | nombres poco descriptivos de tablas/columnas/alias |

Ejemplo de regla formalizada (ver más ejemplos en cada archivo de `rules/`):

```
IF statement = DELETE OR statement = UPDATE
AND WHERE is absent
THEN severity = CRITICAL
AND do not recommend executing the statement
```

```
IF statement = DELETE OR statement = UPDATE
AND WHERE is present
AND WHERE condition is tautological (e.g. "1=1", "TRUE", "col = col", "col LIKE '%'")
THEN severity = CRITICAL
AND treat as equivalent to a missing WHERE clause
```

## Severity levels
- **CRITICAL**: riesgo real de pérdida de datos o brecha de seguridad. La sentencia no debería
  ejecutarse tal cual está.
- **HIGH**: defecto funcional o de rendimiento serio. Debe corregirse antes de producción.
- **MEDIUM**: problema real que conviene corregir, no es bloqueante inmediato.
- **LOW**: desviación de buenas prácticas / estilo, impacto menor.
- **INFO**: no se pudo evaluar de forma concluyente por falta de contexto (esquema/motor), o nota
  informativa que requiere juicio humano.

## Expected output
Reporte estructurado por sentencia:

```
Statement #N: <tipo> <snippet resumido>
- [SEVERIDAD] RULE-ID — descripción del hallazgo — recomendación
...
(o "Sin hallazgos" si la sentencia pasa todas las reglas — el happy path NO debe forzarse a
tener problemas artificiales)

Resumen general:
- Severidad máxima encontrada: <SEVERIDAD>
- Limitaciones del análisis: <lista de INFO por falta de esquema/motor, si aplica>
```

## Validation
Antes de entregar el reporte final, verificar:
1. Todo hallazgo `CRITICAL`/`HIGH` cita el rule ID exacto que lo generó.
2. Ninguna sentencia sin problemas reales fue "rellenada" con hallazgos inventados.
3. Cada regla que dependía de esquema/motor no disponible generó `INFO` en vez de una suposición.
4. El resumen general refleja la severidad máxima real encontrada, sin suavizarla.

## Failure handling
- **SQL no parseable**: reportar el fallo de parseo puntual (qué sentencia y por qué), no
  intentar adivinar la intención de una sentencia rota.
- **Motor no especificado y el comportamiento difiere entre motores** (ej. `LIMIT` vs `TOP` vs
  `ROWNUM`): marcar explícitamente el supuesto tomado (ANSI genérico) y advertir que el resultado
  puede variar por motor. No se asume un motor específico en silencio.
- **Esquema no provisto**: reglas de índices y tipos de datos reales se marcan `INFO`, nunca se
  inventa que "probablemente" existe o no un índice.
- **Ambigüedad de intención** (ej. no está claro si un `DELETE` masivo es intencional): se reporta
  como `CRITICAL`/`HIGH` según la regla aplicable y se pide confirmación explícita del contexto de
  negocio — no se asume que es correcto porque "parece intencional".
- Nunca se inventa contexto de negocio, nombres de tablas relacionadas, ni propósito de columnas
  que no fueron provistos.
