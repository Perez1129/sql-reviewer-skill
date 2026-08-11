-- Ejemplos con múltiples violaciones claras (para test de "error evidente").

-- SEC-01: DELETE sin WHERE
DELETE FROM orders;

-- PERF-01 + PERF-02: SELECT * sin LIMIT ni WHERE selectivo
SELECT * FROM users;

-- CONV-01: comparación incorrecta con NULL
SELECT id FROM users WHERE deleted_at = NULL;

-- SEC-04: DROP irreversible
DROP TABLE audit_log;

-- CONV-04: nombres no descriptivos + CONV-03: fecha como texto
CREATE TABLE tmp (
    x VARCHAR(50),
    dt VARCHAR(20)
);

-- SEC-03: concatenación directa (riesgo de SQL Injection)
-- (ejemplo representado como comentario de la app que arma el SQL)
-- query = "SELECT * FROM users WHERE email = '" + userInput + "'"
SELECT * FROM users WHERE email = '' + userInput + '';
