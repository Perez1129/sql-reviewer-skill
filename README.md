 sql-reviewer-skill

Skill de revisión técnica de SQL para IA. Analiza sentencias/scripts SQL y produce un reporte de
hallazgos clasificados por severidad (`CRITICAL`, `HIGH`, `MEDIUM`, `LOW`, `INFO`), siguiendo un
procedimiento determinista definido en [`SKILL.md`](./SKILL.md), no un prompt genérico tipo
"eres experto en SQL, revisa esto".

 Estructura

sql-reviewer-skill/
├── SKILL.md              # Especificación completa de la skill
├── README.md
├── rules/
│   ├── security.md        # SEC-01 a SEC-06
│   ├── performance.md      # PERF-01 a PERF-08
│   └── conventions.md      # CONV-01 a CONV-06
├── examples/
│   ├── valid.sql           # Happy path — no debe generar hallazgos
│   ├── invalid.sql         # Violaciones evidentes
│   └── edge-cases.sql      # Parecen correctos, no lo son
└── tests/
    ├── test-01.md           # Happy path
    ├── test-02.md           # Error evidente
    ├── test-03.md           # Edge case
    ├── test-04.md           # Información insuficiente
    └── test-05.md           # Adversarial (Red Team)
```

## Cómo usar la skill

1. Pegar el SQL a revisar (una o más sentencias separadas por `;`).
2. Opcionalmente indicar el motor de base de datos objetivo y/o el esquema (tablas, columnas,
   índices). Sin esto, algunas reglas se reportan como `INFO` en vez de asumir contexto.
3. La skill devuelve un reporte por sentencia con hallazgos `[SEVERIDAD] RULE-ID — mensaje`, y un
   resumen general con la severidad máxima encontrada.

