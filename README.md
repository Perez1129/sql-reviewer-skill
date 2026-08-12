# sql-reviewer-skill

Esta skill sirve para revisar código SQL y encontrar posibles errores, problemas de seguridad, rendimiento y malas prácticas.

La skill analiza las consultas SQL y muestra los problemas que encuentra, indicando qué tan grave es cada uno:

* `CRITICAL`
* `HIGH`
* `MEDIUM`
* `LOW`
* `INFO`

La forma en que se realiza la revisión y las reglas que utiliza están explicadas en [`SKILL.md`](https://github.com/Perez1129/sql-reviewer-skill/blob/main/SKILL.md).

## ¿Qué revisa?

Entre otras cosas, la skill busca:

* Uso de `SELECT *`.
* `DELETE` o `UPDATE` sin un `WHERE` seguro.
* Consultas que puedan borrar o modificar muchos datos.
* Posibles problemas de SQL Injection.
* Nombres poco claros en tablas o columnas.
* Consultas que podrían traer demasiados registros.
* Uso incorrecto de `NULL`.
* Tipos de datos que podrían no ser adecuados.
* Índices que podrían hacer falta.
* Problemas que puedan afectar el rendimiento.

También se agregaron algunas reglas propias para complementar la revisión.

## ¿Cómo se usa?

1. Se coloca una sentencia o script SQL.
2. Si se conoce, se puede indicar el motor de base de datos, por ejemplo MySQL o PostgreSQL.
3. También se puede proporcionar información sobre las tablas, columnas o índices.
4. La skill analiza el SQL siguiendo las reglas definidas.
5. Finalmente muestra los problemas encontrados y su nivel de gravedad.

Si no hay suficiente información para asegurar que algo es un problema, la skill no inventa información. En esos casos lo indica como `INFO` o menciona que hace falta información para comprobarlo.

## Ejemplo

```sql
DELETE FROM usuarios;
```

La skill debería detectar que el `DELETE` no tiene `WHERE` y clasificarlo como:

```text
[CRITICAL] DELETE sin WHERE
```

Además, no recomienda ejecutar la sentencia porque podría eliminar todos los registros de la tabla.

## Estructura del proyecto

```text
sql-reviewer-skill/
│
├── SKILL.md
├── README.md
│
├── rules/
│   ├── security.md
│   ├── performance.md
│   └── conventions.md
│
├── examples/
│   ├── valid.sql
│   ├── invalid.sql
│   └── edge-cases.sql
│
└── tests/
    ├── test-01.md
    ├── test-02.md
    ├── test-03.md
    ├── test-04.md
    └── test-05.md
```

## Pruebas

Se realizaron pruebas para comprobar que la skill pueda manejar diferentes situaciones:

* SQL correcto.
* SQL con varios errores.
* Casos que parecen correctos pero tienen algún problema.
* Casos donde falta información.
* Casos creados para intentar evadir las reglas.

Las pruebas y los resultados se encuentran en la carpeta `tests/`.
