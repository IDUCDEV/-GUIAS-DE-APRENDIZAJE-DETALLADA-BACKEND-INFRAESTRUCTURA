# Módulo 3: Automatización con n8n
## 3.8 Transformación Avanzada: Agregación, Deduplicación y Formatos

### Objetivos de Aprendizaje
- Agrupar y resumir datos con **Summarize** (SUM, COUNT, AVG).
- Combinar múltiples items en uno solo con **Aggregate**.
- Explotar arrays en items individuales con **Split Out**.
- Eliminar duplicados con **Remove Duplicates**.
- Convertir datos a CSV, ICS y otros formatos con **Convert to File**.

---

## 1. Summarize: El "Excel" de n8n

El nodo **Summarize** es tu mejor amigo cuando necesitas hacer cálculos sobre grupos de datos. Es como una tabla dinámica de Excel pero dentro de tu flujo.

### Operaciones disponibles:

| Operación | Descripción | Ejemplo de uso |
|-----------|-------------|----------------|
| `Count` | Cuenta cuántos items hay | "¿Cuántos pedidos tengo?" |
| `Count Unique` | Cuenta valores distintos | "¿Cuántos clientes diferentes compraron?" |
| `Sum` | Suma todos los valores de un campo | "¿Cuál es el total de ventas?" |
| `Average` | Promedio de un campo numérico | "¿Cuál es el ticket promedio?" |
| `Min` | Valor mínimo de un campo | "¿Cuál es el precio más bajo?" |
| `Max` | Valor máximo de un campo | "¿Cuál es el precio más alto?" |

### Ejemplo: Reporte de Ventas

```plaintext
Input: [
  { "vendedor": "Ana", "monto": 100 },
  { "vendedor": "Luis", "monto": 200 },
  { "vendedor": "Ana", "monto": 150 }
]

Nodo Summarize:
  - Group By: vendedor
  - Values → Operation: Sum → Field: monto → Alias: total_vendido
  - Values → Operation: Count → Field: vendedor → Alias: cantidad_ventas

Output: [
  { "vendedor": "Ana", "total_vendido": 250, "cantidad_ventas": 2 },
  { "vendedor": "Luis", "total_vendido": 200, "cantidad_ventas": 1 }
]
```

**Configuración:**
| Campo | Valor |
|-------|-------|
| `Group By` | `vendedor` (el campo por el que agrupar) |
| `Values → Operation` | `Sum` |
| `Values → Field` | `monto` |
| `Values → Alias` | `total_vendido` |

### ¿Cuándo NO usar Summarize?
- Si solo quieres filtrar datos (usa **Filter**).
- Si solo quieres ordenar (usa **Sort**).

---

## 2. Aggregate: De Muchos a Uno

El nodo **Aggregate** hace lo opuesto a Split In Batches: toma múltiples items y los combina en uno solo.

### Modos de agregación:

| Modo | Descripción |
|------|-------------|
| `Append` | Concatena todos los items en un array |
| `Append (Fixed Length)` | Agrupa en lotes de tamaño fijo |
| `Enrich` | Añade datos de un item a otro (por campo común) |
| `Separate` | Divide en múltiples salidas |

### Ejemplo: Agrupar correos para envío masivo

```plaintext
Input: [
  { "email": "a@x.com", "nombre": "Ana" },
  { "email": "b@x.com", "nombre": "Luis" }
]

Nodo Aggregate → Mode: Append
Output: {
  "items": [
    { "email": "a@x.com", "nombre": "Ana" },
    { "email": "b@x.com", "nombre": "Luis" }
  ]
}
```

**Truco:** Aggregate + Summarize = Pipeline de reporting completo. Primero agrupas, luego resúmes.

---

## 3. Split Out: De Uno a Muchos

**Split Out** es el hermano de Split In Batches. Mientras que Split In Batches divide listas grandes en lotes más pequeños, **Split Out explota un array dentro de un item en múltiples items**.

```plaintext
Input: { "orden_id": 101, "productos": ["Laptop", "Mouse", "Teclado"] }

Nodo Split Out → Field: productos

Output: [
  { "orden_id": 101, "productos": "Laptop" },
  { "orden_id": 101, "productos": "Mouse" },
  { "orden_id": 101, "productos": "Teclado" }
]
```

**Configuración:**
| Campo | Valor |
|-------|-------|
| `Field to Split Out` | `productos` |
| `Options → Keep` | `orden_id` (campos adicionales a mantener) |

### ¿Cuándo usar Split Out vs Split In Batches?
| Split Out | Split In Batches |
|-----------|------------------|
| Explota un campo array en items | Divide una lista de items en grupos |
| Un item → Muchos items | Muchos items → Grupos de items |
| Útil para normalizar datos | Útil para rate limiting |

---

## 4. Remove Duplicates: Datos Limpios

Cuando trabajas con fuentes de datos externas, los duplicados son inevitables. El nodo **Remove Duplicates** los elimina.

### Modos de operación:

| Modo | Descripción |
|------|-------------|
| `Remove Duplicates` | Elimina items duplicados basado en campos específicos |
| `Remove Duplicates (Advanced)` | Permite comparar transformando los valores primero |

### Ejemplo: Clientes únicos por email

```plaintext
Input: [
  { "email": "juan@gmail.com", "nombre": "Juan" },
  { "email": "maria@hotmail.com", "nombre": "Maria" },
  { "email": "juan@gmail.com", "nombre": "Juan Pérez" }
]

Nodo Remove Duplicates:
  - Operation: Remove Duplicates
  - Fields to Compare: email
  - Options: Keep First

Output: [
  { "email": "juan@gmail.com", "nombre": "Juan" },
  { "email": "maria@hotmail.com", "nombre": "Maria" }
]
```

---

## 5. Convert to File: JSON a CSV, ICS y más

El nodo **Convert to File** transforma datos estructurados en archivos descargables.

### Formatos soportados:

| Formato | Extensión | Uso típico |
|---------|-----------|------------|
| CSV | `.csv` | Exportar a Excel/Google Sheets |
| ICS | `.ics` | Archivos de calendario (recordatorios) |
| HTML | `.html` | Generar páginas web |
| JSON | `.json` | Exportar datos crudos |
| ODS | `.ods` | OpenDocument Spreadsheet |
| RTF | `.rtf` | Documentos enriquecidos |
| Text | `.txt` | Archivos de texto plano |
| XML | `.xml` | Datos en formato XML |
| YAML | `.yaml` | Configuraciones |

### Ejemplo: Exportar a CSV

```plaintext
Input: [
  { "nombre": "Juan", "email": "juan@x.com" },
  { "nombre": "Ana", "email": "ana@x.com" }
]

Nodo Convert to File:
  - Operation: Convert to File
  - Format: CSV
  - Options → Fields to Include: nombre, email

Output: Binary file (CSV) listo para enviar por email o guardar en Drive
```

**Truco:** Combínalo con **Send Email** para enviar reportes automáticos:
```plaintext
Schedule → Postgres (ventas del día) → Summarize → Convert to File (CSV) → Send Email
```

---

## 6. Combinación Poderosa: Pipeline de Reporting

### El Reto: Reporte semanal de ventas por vendedor

```
[Schedule (cada lunes)]
       ↓
[Postgres: SELECT * FROM ventas WHERE fecha > $1]
       ↓
[Summarize: Group By vendedor, Sum(monto), Count(ventas)]
       ↓
[Sort: By total DESC]
       ↓
[Convert to File: CSV]
       ↓
[Send Email: "Reporte semanal adjunto"]
```

Este flujo reemplaza horas de trabajo manual cada semana.

---

## Ejercicio Práctico del Capítulo

1. Crea un flujo con datos de prueba (10 items con `{ ciudad, producto, monto }`).
2. Usa **Summarize** para agrupar por ciudad y calcular: cantidad de ventas, suma total, y promedio por ciudad.
3. Usa **Sort** para ordenar de mayor a menor suma total.
4. Conecta **Remove Duplicates** por ciudad (para dejar solo la mejor ciudad).
5. Convierte el resultado a CSV con **Convert to File**.

**Siguiente Guía:** 3.9 Automatización de Infraestructura - Execute Command, SSH, FTP, Compression y Email.
