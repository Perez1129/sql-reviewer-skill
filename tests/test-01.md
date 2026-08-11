# Test 01 — Happy path

## Input
```sql
SELECT id, email, created_at
FROM users
WHERE status = 'active'
LIMIT 100;
```

## Expected behavior
La skill no debe generar hallazgos artificiales. Columnas explícitas, WHERE selectivo real y
LIMIT razonable cumplen todas las reglas de `security.md`, `performance.md` y `conventions.md`
salvo, opcionalmente, un `INFO` por falta de esquema (no se puede confirmar índice en `status`).

## Actual behavior
```
Statement #1: SELECT ... FROM users
Sin hallazgos de severidad CRITICAL/HIGH/MEDIUM/LOW.
- [INFO] PERF-05 — No se puede confirmar si 'status' está indexado: no se proveyó esquema.

Resumen general:
- Severidad máxima encontrada: INFO
```

## Pass / Fail
PASS — no se inventaron problemas donde no los hay; el único hallazgo es INFO por falta de
contexto, tal como especifica `SKILL.md`.

## Problem detected
Ninguno.

## Modification made to the skill
Ninguna.
