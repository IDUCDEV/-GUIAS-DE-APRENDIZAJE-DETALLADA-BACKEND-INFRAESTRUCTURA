# Módulo 3: Automatización con n8n
## 3.4 Estructuras Avanzadas: Modularidad, Errores y Archivos

### Objetivos de Aprendizaje
- Crear y usar **Sub-workflows** para reutilizar lógica.
- Implementar un sistema de **Manejo de Errores** global.
- Trabajar con **Datos Binarios** (Imágenes, documentos).
- Entender el concepto de **Looping** avanzado.

---

## 1. Sub-workflows: Divide y Vencerás
A medida que tus flujos crecen, se vuelven difíciles de mantener. La solución es el nodo **Execute Workflow**.

### ¿Cuándo usarlo?
- Si tienes una lógica que se repite en varios flujos (ej: enviar un log a una base de datos).
- Para limpiar visualmente un flujo principal gigante.

### Cómo funciona:
1. Creas un flujo independiente que empieza con un **Execute Workflow Trigger**.
2. En tu flujo principal, usas el nodo **Execute Workflow** para llamar al flujo secundario.
3. Puedes pasarle datos y recibir la respuesta.

---

## 2. Manejo de Errores (Error Workflow)
¿Qué pasa si una API falla a las 3 AM? No quieres enterarte cuando un cliente se queje.

### Implementación Global:
1. Crea un nuevo flujo llamado "Manejador de Errores".
2. Empieza con el nodo **Error Trigger**. Este se activará automáticamente cuando CUALQUIER flujo falle.
3. Conecta un nodo de **Telegram** o **Email** que te envíe los detalles del error:
   - Nombre del flujo que falló.
   - Mensaje del error.
   - Hora del fallo.
4. En la configuración de tus flujos principales, selecciona este flujo en la sección "Error Workflow".

---

## 3. Datos Binarios: Más allá del texto
n8n no solo mueve JSON, también mueve archivos.

### Nodos clave para archivos:
- **HTTP Request:** Para descargar una imagen o PDF (selecciona "Response Format: File").
- **Read/Write Binary File:** Para leer archivos de tu servidor o guardarlos.
- **Move Binary Data:** Para convertir un archivo en un campo JSON (Base64) o viceversa.

### Ejemplo de flujo binario:
`Descargar Imagen` -> `Cambiar nombre del archivo` -> `Subir a Google Drive`.

---

## 4. Aprender Haciendo: El Sistema de Logs Centralizado

### El Reto
Crear un sub-workflow que cualquier otro flujo pueda llamar para registrar una actividad en un archivo local o base de datos.

#### Paso A: Crear el Sub-workflow (El receptor)
1. Crea un flujo nuevo.
2. Añade un **Execute Workflow Trigger**.
3. Añade un nodo **Edit Fields** para formatear el log: `{{ $now }} - {{ $json.accion }} - {{ $json.usuario }}`.
4. Añade un nodo **Wait** (opcional, solo para simular proceso).
5. Termina con un nodo **Log** (o guarda en un archivo).

#### Paso B: Llamar desde el flujo principal
1. En cualquier otro flujo, añade el nodo **Execute Workflow**.
2. Selecciona el flujo creado en el Paso A.
3. Pásale los campos `accion` y `usuario`.

---

## 5. Bucles y Loops (Wait for All vs Split)
n8n hace loops automáticamente, pero a veces necesitas control:
- **Loop Over Items:** Permite procesar una lista de items uno por uno en bloques (ej: procesar 100 correos de 10 en 10 para no saturar el servidor).
- **Split In Batches:** Útil cuando la API externa tiene límites de velocidad (Rate Limiting).

---

## 6. Tips de Rendimiento
1. **Borra datos binarios:** Si ya subiste un archivo, bórralo del flujo lo antes posible para liberar RAM.
2. **Evita loops infinitos:** Asegúrate de que tus condiciones de salida en los bucles sean claras.
3. **Usa nombres de variables cortos:** Ayuda a que las expresiones sean legibles.

---

## 7. Stop And Error: Control de Errores Manual

A veces no quieres esperar a que un error ocurra naturalmente. El nodo **Stop And Error** te permite lanzar un error intencionalmente cuando una condición no se cumple.

### ¿Cuándo usarlo?
- Cuando validas datos y algo está mal (ej: email inválido).
- Cuando una API externa devuelve un código de error que debes propagar.
- Cuando quieres detener el flujo con un mensaje claro en los logs.

### Configuración:

| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Error Message` | `El campo email es obligatorio` | El mensaje que aparecerá en el error |
| `Stop Workflow` | `True` | Detiene toda la ejecución |

### Ejemplo: Validación de datos antes de procesar

```plaintext
[Webhook: nuevo registro]
       ↓
[If: {{ $json.email }} is empty]
       ↓ (True)
[Stop And Error: "El email es obligatorio"]
       ↓ (False)
[Postgres: INSERT INTO usuarios]
```

### Diferencia con Error Trigger:

| Stop And Error | Error Trigger |
|----------------|---------------|
| Se coloca dentro del flujo principal | Es un trigger para un workflow separado |
| Lanza el error manualmente | Captura errores automáticos |
| Detiene el flujo inmediatamente | Se ejecuta cuando otro flujo falla |

Puedes combinar ambos: un **Stop And Error** en el flujo principal activará el **Error Trigger** del workflow de errores.

---

## 8. Limit: Controla el Volumen de Datos

El nodo **Limit** hace exactamente lo que su nombre indica: limita la cantidad de items que pasan al siguiente nodo. Es útil cuando:
- Estás probando un flujo con datos reales y no quieres procesar 10,000 registros.
- Una API externa tiene un límite de peticiones.
- Solo necesitas los primeros N resultados.

### Configuración:

| Campo | Valor |
|-------|-------|
| `Max Items` | `100` (solo pasarán los primeros 100 items) |
| `Keep` | `First` o `Last` (los primeros o los últimos) |

### Ejemplo: Procesar solo los 10 pedidos más recientes

```plaintext
[Postgres: SELECT * FROM pedidos ORDER BY fecha DESC]
       ↓
[Limit: Max Items = 10, Keep = First]
       ↓
[Procesar solo esos 10 pedidos]
```

---

## 9. Data Table: Formatea Datos como Tabla

El nodo **Data Table** transforma tus datos en una tabla visual con formato Markdown o HTML. Es perfecto para:

- Enviar reportes por email con tablas bonitas.
- Mostrar datos en Telegram o Slack con formato limpio.
- Debuggear visualmente varios items a la vez.

### Configuración:

| Campo | Valor |
|-------|-------|
| `Data` | `{{ $json }}` (los items a convertir) |
| `Format` | `Markdown` o `HTML` |
| `Options → Fields to Include` | `nombre, email, monto` |

### Ejemplo: Reporte por Telegram

```plaintext
[Schedule: cada lunes]
       ↓
[Postgres: ventas de la semana]
       ↓
[Data Table: Format → Markdown, Fields → vendedor, total]
       ↓
[Telegram: "📊 Reporte semanal:\n{{ $json.data }}"]
```

### Output en Markdown:

```markdown
| Vendedor | Total  |
|----------|--------|
| Ana      | $1,200 |
| Luis     | $950   |
| Pedro    | $750   |
```

Output en Telegram/Slack será una tabla perfectamente alineada.

---

## Ejercicio Práctico del Capítulo

1. Crea un flujo que falle a propósito (usa un nodo **Code** que lance un error: `throw new Error("Fallo de prueba");`).
2. Crea un **Error Workflow** que te envíe un mensaje a un nodo de log o Telegram cuando este error ocurra.
3. Asegúrate de que el flujo principal tenga seleccionado el Error Workflow en su configuración.
4. **Bonus:** Agrega un nodo **Stop And Error** que valide que el dato `nombre` no esté vacío antes de procesar.
5. **Bonus 2:** Usa **Limit** para procesar solo los primeros 3 items y **Data Table** para mostrarlos en una tabla Markdown.

**Siguiente Guía:** 3.5 Preparación para Producción - VPS, Seguridad y Variables de Entorno.
