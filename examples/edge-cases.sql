-- Casos límite: pasan superficialmente una revisión ingenua, pero tienen problemas reales.

-- Parece seguro (tiene WHERE) pero es tautológico -> SEC-02, equivalente a no tener WHERE
DELETE FROM TA_USERS WHERE 1 = 1;

-- Parece seguro (tiene LIMIT) pero el LIMIT no protege nada -> PERF-03
SELECT * FROM TA_USERS LIMIT 1000000000;

-- Parece selectivo (tiene WHERE con LIKE) pero el patrón matchea todo -> SEC-02 / SEC-06
UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%';

-- Parece tener condición de JOIN, pero falta el predicado entre ambas tablas -> PERF-06
SELECT o.id, u.email
FROM orders o, users u
WHERE o.status = 'pending';

-- Tiene WHERE selectivo en apariencia, pero envuelve la columna indexada en una función -> PERF-08
SELECT * FROM orders WHERE YEAR(created_at) = 2026;

-- Tiene LIMIT y WHERE, pero el WHERE filtra sobre un cálculo, no sobre datos reales de la fila
SELECT * FROM users WHERE 1 < 2 LIMIT 50;
