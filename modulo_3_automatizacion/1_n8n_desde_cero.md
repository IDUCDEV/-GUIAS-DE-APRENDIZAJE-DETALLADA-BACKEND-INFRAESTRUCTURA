# Módulo 3: Automatización con n8n
## 3.1 n8n desde Cero: El Lienzo y la Lógica de Datos

### Objetivos de Aprendizaje
- Comprender la arquitectura de n8n (Node-based workflow).
- Diferenciar entre datos JSON y Datos Binarios.
- Entender el concepto de "Items" y cómo n8n procesa listas.
- Instalar n8n localmente para pruebas rápidas.

---

## 1. ¿Qué es n8n realmente?
A diferencia de Zapier (que es lineal), n8n es un **motor de flujos basado en nodos**. Imagina que es como armar un set de LEGO donde cada pieza (nodo) hace una tarea específica: uno recibe un correo, otro traduce el texto y otro lo guarda en una base de datos.

### El concepto de "Items" (La regla de oro)
Este es el concepto más importante: **n8n procesa items de forma individual.**
- Si un nodo recibe una lista de 10 usuarios, el siguiente nodo se ejecutará **10 veces** automáticamente (una por cada usuario), a menos que uses un nodo especial para agruparlos.

---

## 2. Anatomía de la Interfaz
Cuando abras n8n, verás tres áreas críticas:
1. **El Canvas (Lienzo):** Donde arrastras y conectas nodos.
2. **Input Data (Entrada):** Lo que el nodo recibe del paso anterior.
3. **Output Data (Salida):** Lo que el nodo entrega después de procesar.

### JSON vs Binary Data
- **JSON:** Datos de texto estructurados (Nombres, fechas, precios). Es lo que ves el 90% del tiempo.
- **Binary:** Archivos reales (Imágenes, PDFs, audios). n8n los maneja por separado para no saturar la memoria.

---

## 3. Instalación para Pruebas (Local)
Antes de ir al VPS (Módulo 2), lo mejor es practicar en tu propia máquina.

**Opción recomendada (Desktop):**
Descarga n8n Desktop desde [n8n.io](https://n8n.io/get-started/). Es un ejecutable que no requiere configuración.

**Opción Pro (Terminal):**
Si tienes Node.js instalado:
```bash
npx n8n
```
Esto abrirá n8n en `http://localhost:5678`.

---

## 4. Aprender Haciendo: Tu primer flujo lógico

### El Reto: "El Generador de Saludos Inteligente"
Vamos a crear un flujo que reciba un nombre y decida si saludarte formal o informalmente.

#### Paso A: El Trigger (Manual)
1. Haz clic en el `+` y busca el nodo **Manual Trigger**. Este será tu botón de "Play".

#### Paso B: Crear Datos Artificiales
1. Conecta un nodo **Edit Fields (Set)**.
2. Configúralo así:
   - **Mode:** Manual.
   - **Fields to Add:**
     - Name: `nombre`, Value: `Tu Nombre`.
     - Name: `hora`, Value: `20` (un número que represente las 8 PM).

#### Paso C: La Lógica (IF)
1. Conecta un nodo **If**.
2. Configura la condición:
   - **Check:** `{{ $json.hora }}` (Arrastra el dato desde la izquierda).
   - **Operation:** `Is greater than`.
   - **Value:** `18`.

#### Paso D: Las Salidas (Sticky Notes + Telegram/Log)
1. En la rama **True** (Es de noche): Conecta un nodo **Edit Fields** y crea un mensaje: `"Buenas noches, {{ $json.nombre }}"`.
2. En la rama **False** (Es de día): Conecta otro y crea: `"¡Hola, {{ $json.nombre }}! Que tengas buen día"`.

---

## 5. Visualización de Datos (Debug)
Después de ejecutar (clic en "Execute Workflow"):
- Haz clic en cualquier nodo para ver los datos.
- Cambia entre la vista **Table** (como Excel) y **JSON** (código).
- **Truco:** Observa cómo el dato que creaste en el paso B viaja a través de las flechas hasta el final.

---

## 6. Glosario para Principiantes
- **Workflow:** El conjunto de todos tus nodos conectados.
- **Node:** Una unidad de acción (un paso).
- **Expression:** Código corto entre `{{ }}` para usar datos dinámicos.
- **Execution:** El historial de una vez que el flujo corrió.

---

## Ejercicio Práctico del Capítulo
1. Modifica el flujo anterior para que el valor de `hora` sea dinámico usando la expresión `{{ $now.hour }}`.
2. Observa cómo cambia la respuesta según la hora real de tu computadora.

**Siguiente Guía:** 3.2 Transformación de Datos - Domina las expresiones y el nodo Code.
