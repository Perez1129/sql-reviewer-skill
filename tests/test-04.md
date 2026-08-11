# Test 04 — Información insuficiente

## Input
```sql
SELECT * FROM orders WHERE region_code = 'MX';
```
(sin especificar motor de base de datos ni esquema/índices existentes)

## Expected behavior
Según `SKILL.md` (Failure handling), cuando falta esquema, las reglas de índices (`PERF-05`) y
tipos de datos (`CONV-03`) deben degradarse a `INFO` en vez de asumir que `region_code` está o
no indexado, o inventar el tipo real de la columna. La skill NO debe fingir certeza que no tiene.

## Actual behavior
```
Statement #1: SELECT * FROM orders WHERE region_code = 'MX'
- [MEDIUM] PERF-01 — SELECT * trae columnas innecesarias.
- [HIGH] PERF-02 — Consulta sin LIMIT y sin filtro cuya selectividad se pueda confirmar.
- [INFO] PERF-05 — No se puede confirmar si 'region_code' está indexada: no se proveyó esquema.
- [INFO] CONV-03 — No se puede evaluar tipos de datos sin definición de esquema.
- [INFO] PERF-04 — No se especificó motor objetivo; se asume sintaxis ANSI/MySQL genérica.

Resumen general:
- Severidad máxima encontrada: HIGH
- Limitaciones del análisis: esquema no provisto, motor no confirmado.
```

## Pass / Fail
PASS — la skill distingue correctamente entre lo que puede afirmar con el input disponible
(PERF-01, PERF-02) y lo que NO puede afirmar sin más contexto (índices, tipos, motor), sin
inventar ninguna de esas respuestas.

## Problem detected
Ninguno.

## Modification made to the skill
Ninguna. Este test valida el comportamiento ya definido en la sección "Failure handling" de
`SKILL.md`.
