# Test 05 — Adversarial (Red Team)

## Input
```sql
SELECT * FROM TA_USERS LIMIT 1000000000;
```

## Expected behavior
Diseñado deliberadamente para evadir la regla ingenua "¿tiene LIMIT? entonces está bien". La
skill debe reconocer que un LIMIT con un valor absurdamente alto no cumple ningún propósito de
mitigación real, y seguir marcando la falta de columnas explícitas.

## Actual behavior (primera corrida, antes de ajustar la skill)
```
Statement #1: SELECT * FROM TA_USERS LIMIT 1000000000
- [MEDIUM] PERF-01 — SELECT * trae columnas innecesarias.
(PERF-02 no se disparó porque, en la versión inicial, la regla solo verificaba
"¿existe la palabra LIMIT?", sin evaluar el valor)

Resumen general:
- Severidad máxima encontrada: MEDIUM
```

## Pass / Fail
FAIL en la primera corrida — el ataque tuvo éxito: la sola presencia sintáctica de `LIMIT`
neutralizó la regla de rendimiento, subestimando el riesgo real (severidad quedó en MEDIUM
en vez de reflejar que el LIMIT es inútil).

## Problem detected
`PERF-02` (v1) solo comprobaba la existencia de la cláusula LIMIT, no si el valor era
razonable respecto al volumen esperado de la tabla.

## Modification made to the skill
Se agregó `PERF-03` (LIMIT presente pero inútil) en `rules/performance.md`, con un umbral
explícito (> 100,000 o mayor al tamaño razonable esperado de la tabla) que se dispara
independientemente de que exista la cláusula LIMIT. Tras el fix:

```
Statement #1: SELECT * FROM TA_USERS LIMIT 1000000000
- [MEDIUM] PERF-01 — SELECT * trae columnas innecesarias.
- [MEDIUM] PERF-03 — El LIMIT declarado es tan alto que no mitiga el riesgo real.

Resumen general:
- Severidad máxima encontrada: MEDIUM (con dos hallazgos independientes, en vez de que el
  LIMIT "tapara" el problema por completo)
```
PASS tras la corrección — la skill ya no puede ser engañada por la sola presencia sintáctica
de LIMIT, WHERE, etc.; evalúa el valor/selectividad real en cada caso (ver también SEC-02).
