# Módulo 3: Automatización con n8n
## 3.6 Scraping Nativo: Extracción de Datos sin Herramientas Externas

### Objetivos de Aprendizaje
- Aprender el flujo de scraping nativo en n8n.
- Usar el nodo **HTTP Request** para obtener el código fuente.
- Dominar el nodo **HTML** para extraer datos con selectores CSS.
- Automatizar la búsqueda de información web.

---

## 1. El Flujo de Scraping en n8n
A diferencia de herramientas externas, n8n permite hacer scraping usando solo dos nodos principales:
1. **HTTP Request:** Descarga el HTML (código fuente) de la página.
2. **HTML:** Analiza ese código y extrae los datos que te interesan.

---

## 2. Paso 1: Obtener el código fuente
Para hacer scraping, primero necesitamos "traer" la página a n8n.

### Configuración del nodo HTTP Request:
- **Method:** GET.
- **URL:** La dirección de la web que quieres analizar.
- **Response Format:** Text (HTML).

---

## 3. Paso 2: Extraer datos con el nodo HTML
Una vez tienes el texto de la página, el nodo **HTML** hace la magia usando **Selectores CSS**.

### Cómo configurar el nodo HTML:
1. **Source Data:** Selecciona la salida del nodo anterior (el HTML).
2. **Extraction Values:** Aquí defines qué quieres sacar.
   - **Key:** El nombre que le darás al dato (ej: `titulo`).
   - **CSS Selector:** El camino hacia el dato (ej: `h1`, `.product-price`, `#main-content`).
   - **Return Value:** Generalmente `Text Content` o `Attribute` (ej: `href` para enlaces).

---

## 4. Aprender Haciendo: Monitor de Precios de Cripto (Sin API)

### El Reto
Extraer el precio de una criptomoneda directamente desde una página web de noticias o precios sin usar una API oficial.

#### Paso A: El Trigger
1. Añade un **Manual Trigger**.

#### Paso B: HTTP Request
1. URL: `https://coinmarketcap.com/currencies/bitcoin/`
2. Asegúrate de que n8n reciba el código HTML de la página.

#### Paso C: Nodo HTML (La extracción)
1. **Key:** `precio`.
2. **CSS Selector:** `.priceValue` (o el selector actual que tenga el precio en la web).
3. **Return Value:** `Text Content`.

#### Paso D: Limpieza
1. Conecta un nodo **Edit Fields**.
2. Limpia el texto: `{{ $json.precio.replace('$', '').trim() }}`.

---

## 5. Manejo de Paginación y Listas
Si la web tiene una lista (ej: 20 productos), el nodo HTML creará **20 items** automáticamente. n8n procesará cada uno por separado en los siguientes nodos del flujo.

---

## 6. Consideraciones Éticas y Técnicas
1. **User-Agent:** Algunas webs bloquean n8n. Puedes solucionarlo añadiendo el Header `User-Agent` en el nodo HTTP Request, simulando ser un navegador Chrome.
2. **Robots.txt:** Revisa siempre si la web permite el scraping.
3. **Frecuencia:** No hagas peticiones cada segundo. Usa el nodo **Wait** o programa el flujo para que corra una vez al día o cada pocas horas.

---

## Ejercicio Práctico del Capítulo
1. Elige un blog de tecnología.
2. Crea un flujo que extraiga los títulos de los últimos 5 artículos.
3. Envía esos títulos a un nodo de log o a tu Telegram.

**Fin del Módulo 3:** ¡Ahora eres un experto en n8n! Estás listo para integrar todo con tu backend en el **Módulo 4 (Serverpod)**.
