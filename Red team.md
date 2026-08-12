# Red Team - SQL Reviewer Skill (equipo Vanessa)

Encontramos casos donde su skill SI o NO detecta cosas peligrosas aunque "parezcan" tener WHERE o LIMIT.

## Los 3 casos que nos dieron

**1)** `DELETE FROM TA_USERS WHERE 1 = 1;`
- Borra TODO porque 1=1 siempre es verdad
- Su skill SI lo detecta (tienen la regla SEC-003/004 que menciona justo "1=1")
- Está bien

**2)** `SELECT * FROM TA_USERS LIMIT 1000000000;`
- El LIMIT es tan grande que no limita nada, y encima usa SELECT * (expone todo)
- Su skill dice en el procedimiento que "sabe" que un LIMIT enorme no sirve, pero NO tienen una regla real (con ID y severidad) que lo capture. O sea lo dicen pero no lo implementan
- Este caso se les escapa

**3)** `UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '%';`
- LIKE '%' hace match con cualquier cosa, entonces vuelve ADMIN a todos los usuarios
- Su skill SI lo detecta (está literal en su regla SEC-003/004)
- Está bien

## Otros casos que le metimos para romperla

**4) Tautología escondida en subconsulta**
```sql
DELETE FROM TA_ORDERS WHERE FCID IN (SELECT FCID FROM TA_ORDERS);
```
La subconsulta trae todos los IDs de la misma tabla, o sea borra todo. Su regla solo busca patrones tipo "1=1" o "LIKE %" escritos literalmente, esto no lo agarra.

**5) No tienen regla para DROP ni TRUNCATE**
```sql
TRUNCATE TABLE TA_USERS_TEMP;
```
```sql
SELECT * FROM TA_USERS WHERE FCID = 1; DROP TABLE TA_AUDIT_LOG;
```
En todo el documento no aparece ninguna regla con ID para DROP, TRUNCATE, GRANT o REVOKE. Son de las sentencias más peligrosas que hay y ni las mencionan.

**6) Autocomparación con función**
```sql
UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE UPPER(FCEMAIL) = UPPER(FCEMAIL);
```
Es lo mismo que columna=columna pero envuelto en una función, capaz que su regla no lo pesca porque busca el patrón exacto "col=col".

**7) Solo cubren "1=1", ¿y "2=2"?**
```sql
DELETE FROM TA_USERS WHERE 2 = 2;
```
Si su regla busca literalmente el texto "1=1" en vez de entender "cualquier literal=literal que siempre da verdadero", esto se les cuela.

**8) LIKE universal que no es '%'**
```sql
UPDATE TA_USERS SET FCROLE = 'ADMIN' WHERE FCEMAIL LIKE '_%';
```
`_%` pide mínimo 1 caracter, o sea prácticamente cualquier email hace match igual, y esto no está en su lista (solo tienen '%' y '%%').

## Resumen

| Caso | Qué pasa | Su skill lo agarra? |
|---|---|---|
| 1 - DELETE 1=1 | Borra todo | Sí |
| 2 - LIMIT gigante | No limita nada + expone datos | No, falta regla |
| 3 - UPDATE LIKE '%' | Da admin a todos | Sí |
| 4 - Subquery tautológica | Borra todo | No |
| 5 - DROP/TRUNCATE | Borra tabla completa | No, no existe regla |
| 6 - UPPER(x)=UPPER(x) | Mismo problema que col=col disfrazado | Probablemente no |
| 7 - 2=2 en vez de 1=1 | Mismo problema, otro número | Depende si generalizaron la regla o no |
| 8 - LIKE '_%' | Casi siempre hace match | No, solo cubren '%' |

## Onda general

Lo que tienen está bien pensado (sí razonan el WHERE, no solo si existe o no), pero las reglas que escribieron son una lista cerrada de ejemplos puntuales (1=1, TRUE, col=col, LIKE '%'). Cualquier cosa que diga lo mismo pero con otra forma se les escapa. Y les falta totalmente cubrir DROP, TRUNCATE, GRANT/REVOKE que ni aparecen mencionados.

Si nos pasan los archivos rules/security.md, rules/performance.md y rules/conventions.md que mencionan en el SKILL.md pero no compartieron, podemos confirmar si ahí sí cubren algunos de estos casos.
