-- Ejemplos que NO deben generar hallazgos (o solo INFO por falta de esquema).
-- Sirven para validar que la skill no "inventa" problemas en SQL correcto.

-- Columnas explícitas, WHERE selectivo, LIMIT razonable
SELECT id, email, created_at
FROM users
WHERE status = 'active'
LIMIT 100;

-- DELETE con condición selectiva sobre PK
DELETE FROM sessions
WHERE session_id = 'a1b2c3d4-e5f6-7890';

-- UPDATE con condición selectiva y específica
UPDATE orders
SET status = 'shipped'
WHERE order_id = 48213;

-- JOIN con condición explícita, alias descriptivos
SELECT u.id, u.email, o.total_amount
FROM users AS u
JOIN orders AS o ON o.user_id = u.id
WHERE o.created_at >= '2026-01-01'
LIMIT 500;

-- Uso correcto de IS NULL
SELECT id, email
FROM users
WHERE deleted_at IS NULL
LIMIT 200;

-- Agregación que colapsa a una fila (no necesita LIMIT)
SELECT COUNT(*) AS total_active_users
FROM users
WHERE status = 'active';
