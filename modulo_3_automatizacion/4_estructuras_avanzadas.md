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

## Ejercicio Práctico del Capítulo
1. Crea un flujo que falle a propósito (usa un nodo **Code** que lance un error: `throw new Error("Fallo de prueba");`).
2. Crea un **Error Workflow** que te envíe un mensaje a un nodo de log o Telegram cuando este error ocurra.
3. Asegúrate de que el flujo principal tenga seleccionado el Error Workflow en su configuración.

**Siguiente Guía:** 3.5 Preparación para Producción - VPS, Seguridad y Variables de Entorno.
