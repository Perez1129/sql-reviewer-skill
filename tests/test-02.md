# Test 02 — Error evidente

## Input
```sql
DELETE FROM orders;

SELECT * FROM users;

SELECT id FROM users WHERE deleted_at = NULL;
```

## Expected behavior
Cada sentencia debe disparar al menos una regla claramente identificable: `SEC-01` (DELETE sin
WHERE), `PERF-01` + `PERF-02` (SELECT * sin LIMIT ni WHERE selectivo), y `CONV-01` (comparación
inválida con NULL).

## Actual behavior
```
Statement #1: DELETE FROM orders
- [CRITICAL] SEC-01 — Sentencia afecta todas las filas de la tabla. No ejecutar sin WHERE.

Statement #2: SELECT * FROM users
- [MEDIUM] PERF-01 — SELECT * trae columnas innecesarias.
- [HIGH] PERF-02 — Consulta sin LIMIT y sin filtro selectivo.

Statement #3: SELECT id FROM users WHERE deleted_at = NULL
- [HIGH] CONV-01 — '= NULL' siempre evalúa a UNKNOWN, nunca hará match. Usar IS NULL.

Resumen general:
- Severidad máxima encontrada: CRITICAL
```

## Pass / Fail
PASS — las tres sentencias fueron detectadas con el rule ID correcto y la severidad esperada.

## Problem detected
Ninguno.

## Modification made to the skill
Ninguna.
