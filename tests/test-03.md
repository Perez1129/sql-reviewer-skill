# Test 03 — Edge case

## Input
```sql
UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%';
```

## Expected behavior
La sentencia tiene un `WHERE`, así que una revisión ingenua ("¿tiene WHERE? sí, ok") la dejaría
pasar. La skill debe reconocer que `LIKE '%'` es un comodín total equivalente a no tener
condición, y además que la columna modificada es un campo de rol/permiso — debe combinarse
`SEC-02` con `SEC-06`.

## Actual behavior (primera corrida, antes de ajustar la skill)
```
Statement #1: UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%'
Sin hallazgos. (la primera versión de SEC-01 solo verificaba "¿existe WHERE?", sin evaluar
si la condición era tautológica)
```

## Pass / Fail
FAIL en la primera corrida — la skill fue engañada por la presencia superficial de un WHERE.

## Problem detected
La regla original (`SEC-01` v1) verificaba únicamente la existencia sintáctica de la cláusula
WHERE, no su selectividad real. Un `LIKE '%'` matchea el 100% de las filas.

## Modification made to the skill
Se agregó la regla `SEC-02` (WHERE tautológico) en `rules/security.md`, que detecta patrones
como `1=1`, `col = col` y `col LIKE '%'` y los trata como equivalentes a un WHERE ausente. Se
agregó también `SEC-06` para marcar como CRITICAL cualquier cambio sobre columnas de
rol/permiso con condición insuficientemente selectiva. Tras el fix:

```
Statement #1: UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%'
- [CRITICAL] SEC-02 — El WHERE existe pero es equivalente a no tener WHERE: afecta todas las filas.
- [CRITICAL] SEC-06 — Cambio de rol/permiso con condición insuficientemente selectiva.

Resumen general:
- Severidad máxima encontrada: CRITICAL
```
PASS tras la corrección.
