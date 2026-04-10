# Módulo 3: Automatización (n8n + OpenClaw)

## 3. Scraping y APIs

### Objetivos de Aprendizaje

- Extraer datos de sitios web con OpenClaw
- Configurar webhooks para notificaciones en tiempo real
- Integrar datos extraídos con Serverpod
- Automatizar la búsqueda de ofertas de empleo

---

## 3.1 ¿Qué es OpenClaw?

### Concepto

OpenClaw es una herramienta de web scraping de código abierto que permite extraer datos de sitios web de manera programable. Es ideal para monitorear precios, ofertas de empleo, competencia, y cualquier dato públicamente disponible en la web.

### Casos de Uso para Desarrolladores Flutter

```
┌─────────────────────────────────────────────────────────────┐
│              CASOS DE USO DE OPENCLAW                       │
│                                                             │
│  1. Ofertas de Empleo:                                     │
│     - Extraer ofertas de LinkedIn, InfoJobs, Indeed       │
│     - Notificar cuando aparece nueva oferta               │
│     - Guardar en base de datos                             │
│                                                             │
│  2. Monitoreo de Precios:                                  │
│     - Competidores                                         │
│     - Productos específicos                                │
│                                                             │
│  3. Investigación:                                         │
│     - Recopilar datos para análisis                       │
│     - Seguimiento de noticias                              │
│                                                             │
│  4. Generación de Leads:                                   │
│     - Extraer contactos de directorios                    │
│     - Información de empresas                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3.2 Instalación de OpenClaw

### Requisitos

```
- Node.js 18+
- Docker (opcional)
- Git
```

### Instalación con Docker

```bash
# Clonar repositorio
git clone https://github.com/openclaw/openclaw.git
cd openclaw

# Configuración
cat > .env << 'EOF'
# Configuración básica
NODE_ENV=development
PORT=3000

# Base de datos (opcional)
DATABASE_URL=postgres://user:pass@localhost:5432/openclaw
EOF

# Ejecutar con Docker
docker compose up -d

# Acceder a la UI
# http://localhost:3000
```

### Instalación Manual

```bash
# Clonar y configurar
git clone https://github.com/openclaw/openclaw.git
cd openclaw
npm install

# Copiar configuración de ejemplo
cp config.example.json config.json

# Editar config.json con tu configuración
npm start

# La UI estará en http://localhost:3000
```

---

## 3.3 Configuración de Scrapers

### Estructura de un Scraper

```javascript
// Ejemplo de configuración de scaper
{
  "name": "buscar_ofertas_empleo",
  "url": "https://example.com/jobs",
  "method": "GET",
  "selectors": {
    "jobs": ".job-listing .job-item",
    "title": ".job-title",
    "company": ".company-name",
    "location": ".location",
    "salary": ".salary",
    "url": ".job-title a@href"
  },
  "pagination": {
    "type": "next-button",
    "selector": ".pagination .next",
    "maxPages": 5
  }
}
```

### Tipos de Extracción

```markdown
# HTML Parsing
- Seleccionar elementos con CSS selectors
- Extraer texto, atributos, HTML
- Anidar búsquedas

# AJAX/Dynamic Content
- esperar JavaScript
- scroll infinito
- clicks para cargar más

# API REST
- Extraer desde endpoints JSON
- Más rápido y estable
```

### Selectores CSS para n8n

```
//Selecciones comunes
{{$json.title}}              → texto del elemento
{{$json.url}}                 → atributo href
{{$json.image@src}}          → atributo src de imagen
{{$json.elements.html}}      → HTML completo
{{$json.elements.text()}}    → texto limpio
```

---

## 3.4 Integración con n8n

### Workflow: Extraer y Guardar

```
┌─────────────────────────────────────────────────────────────┐
│ WORKFLOW: Extraer Ofertas de Empleo                        │
│                                                             │
│  Trigger: Cron (cada 6 horas)                              │
│     │                                                       │
│     ▼                                                       │
│  1. OpenClaw Scraper                                       │
│     - Config: JSON del scraper                            │
│     - Output: Array de ofertas                             │
│     ▼                                                       │
│  2. Loop Over Items                                       │
│     - Para cada oferta:                                   │
│     ▼                                                       │
│  3. HTTP Request (Serverpod)                              │
│     - POST /api/offers                                    │
│     - Body: datos de la oferta                            │
│     ▼                                                       │
│  4. Telegram (si es nueva)                                │
│     - Notificar: "Nueva oferta: Título"                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Configurar Nodo OpenClaw en n8n

```json
{
  "node": "OpenClaw",
  "config": {
    "operation": "runScraper",
    "scraperId": "id-del-scraper",
    "waitFor": 2000,
    "maxResults": 50
  }
}
```

### Verificar Resultados

```json
{
  "jobs": [
    {
      "title": "Desarrollador Flutter",
      "company": "Tech Corp",
      "location": "Madrid",
      "salary": "30.000 - 45.000 €",
      "url": "https://example.com/job/123",
      "scrapedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

## 3.5 Webhooks - Notificaciones en Tiempo Real

### Concepto de Webhook

Un webhook es una URL especial que recibe datos cuando ocurre un evento. A diferencia de hacer polling (preguntar constantemente), el webhook "empuja" los datos cuando están disponibles.

```
┌─────────────────────────────────────────────────────────────┐
│                    POLLING vs WEBHOOK                      │
│                                                             │
│  POLLING (consulta constante):                              │
│  ┌──────┐    cada 5 min    ┌──────┐                       │
│  │ n8n  │ ───────────────►│ API  │                       │
│  └──────┘                  └──────┘                       │
│  - Puede perderse datos entre consultas                    │
│  - Gasta recursos constantemente                          │
│                                                             │
│  WEBHOOK (instantáneo):                                    │
│  ┌──────┐    evento      ┌──────┐                         │
│  │ API  │ ──────────────►│ n8n  │                         │
│  └──────┘                └──────┘                         │
│  - Datos recibidos inmediatamente                         │
│  - Solo usa recursos cuando hay datos                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Recibir Webhooks en n8n

```markdown
# 1. Crear Workflow en n8n
# 2. Trigger: Webhook
# 3. Copiar URL del webhook

# La URL será algo como:
# https://tu-n8n.com/webhook/abc123
```

### Enviar Webhook a Telegram

```json
{
  "node": "Telegram",
  "config": {
    "operation": "sendMessage",
    "chatId": "TU_CHAT_ID",
    "text": "🎯 *Nueva Oferta de Empleo*\n\n" +
           "📍 *Título*: {{$json.title}}\n" +
           "🏢 *Empresa*: {{$json.company}}\n" +
           "📍 *Ubicación*: {{$json.location}}\n" +
           "💰 *Salario*: {{$json.salary}}\n" +
           "🔗 [Ver oferta]({{$json.url}})",
    "parse_mode": "Markdown"
  }
}
```

---

## 3.6 Ejemplo Completo: Monitor de Ofertas de Empleo

### Paso 1: Configurar Scraper

```json
{
  "name": "infojobs_scraper",
  "url": "https://www.infojobs.com/jobsearch/searchcriteria=desarrollador+flutter",
  "selectors": {
    "offers": ".offer-container",
    "title": ".job-title .title",
    "company": ".company-name",
    "location": ".location",
    "salary": ".salary-range",
    "url": ".job-title a@href",
    "date": ".publication-date"
  },
  "pagination": {
    "type": "scroll",
    "maxPages": 3
  }
}
```

### Paso 2: Crear Workflow en n8n

```markdown
# Workflow: Monitor de Ofertas Flutter

## Trigger
- Type: Cron
- Schedule: */6 * * * * (cada 6 horas)

## Nodos

### 1. OpenClaw (Ejecutar Scraper)
- Scraper: infojobs_scraper
- Output: {{$json.offers}}

### 2. Function (Filtrar duplicates)
```javascript
const previousOffers = $json.previousIds || [];
const newOffers = [];

for (const offer of $json.offers) {
  if (!previousOffers.includes(offer.url)) {
    newOffers.push(offer);
  }
}

return { newOffers, allOffers: $json.offers.map(o => o.url) };
```

### 3. IF (Hay nuevas ofertas?)
- Condition: {{$json.newOffers.length}} > 0

### 4. Loop Over Items
- Para cada oferta nueva

### 5. HTTP (Guardar en Serverpod)
- POST http://192.168.1.100:8080/api/job-offers
- Body: {{$json}}

### 6. Telegram (Notificar)
- Chat ID: TU_ID
- Message: Nueva oferta detectada

### 7. Set (Guardar IDs para evitar duplicates)
- Actualizar lista de IDs procesados
```

### Paso 3: Probar y Monitorear

```bash
# Ver logs en n8n
docker logs n8n -f

# Ver ofertas guardadas en Serverpod
# Consultar tabla job_offers
curl http://192.168.1.100:8080/api/job-offers
```

---

## 3.7 APIs Externas Comunes

### APIs Públicas Útiles

```markdown
1. Clima:
   - OpenWeatherMap (gratis hasta cierto límite)
   - wttr.in (sin API key)

2. Finanzas:
   - ExchangeRate-API
   - CoinGecko (criptomonedas)

3. Geolocalización:
   - ip-api.com (gratis)
   - OpenStreetMap Nominatim

4. Noticias:
   - NewsAPI
   - Hacker News API

5. Datos de empleo:
   - Jooble API
   - Adzuna API
```

### Ejemplo: API de Clima

```json
{
  "node": "HTTP Request",
  "config": {
    "method": "GET",
    "url": "https://api.openweathermap.org/data/2.5/weather",
    "query": {
      "q": "Madrid",
      "appid": "{{$env.OPENWEATHER_API_KEY}}",
      "units": "metric"
    }
  }
}

// Resultado:
{
  "main": {
    "temp": 22,
    "humidity": 65
  },
  "weather": [
    {
      "description": "clear sky",
      "icon": "01d"
    }
  ]
}
```

---

## 3.8 Consideraciones Éticas y Legales

### Web Scraping Responsble

```markdown
✅ HACER:
- Respetar robots.txt
- No sobrecargar servidores
- Identificarse cuando sea apropiado
- Usar APIs oficiales cuando existan

❌ NO HACER:
- Scraping de datos personales sensibles
- Extraer contenido con copyright
- Automatizar a alta velocidad
- Evadir medidas de seguridad
```

### Alternativas Éticas

```
1. Usar APIs oficiales:
   - La mayoría de servicios ofrecen API
   - Más estable y seguro
   - Soporte oficial

2. Servicios de datos:
   - Data.com, Clearbit
   - APIs comerciales de calidad

3. Contactar directamente:
   - Partnerships
   - Acuerdos de uso de datos
```

---

## 3.9 Ejercicios Prácticos

### Ejercicio 1: Scraping Básico

```markdown
# Crear scraper simple con OpenClaw

1. Acceder a UI de OpenClaw
2. Crear nuevo scraper
3. URL: https://example.com
4. Selector: title, description
5. Ejecutar manualmente
6. Ver resultado JSON
```

### Ejercicio 2: Integrar con n8n

```markdown
# Workflow: Escraper → Notificación

1. Trigger: Manual
2. OpenClaw: Ejecutar scraper
3. Telegram: Enviar resultado

# Probar ejecutando el workflow
```

### Ejercicio 3: Guardar en Serverpod

```markdown
# Workflow completo

1. Trigger: Cron (daily)
2. OpenClaw: Extraer ofertas
3. Loop: Para cada oferta
4. HTTP: POST a Serverpod
5. Telegram: Notificar nuevas

# Esto se ejecutará automáticamente
```

---

## 3.10 Recursos Adicionales

### Herramientas de Scraping

| Herramienta | Tipo | Mejor Para |
|-------------|------|-------------|
| OpenClaw | Open source | Flexibilidad |
| Puppeteer | Code | JS dinámico |
| Scrapy | Python | Grande escala |
| Cheerio | Node.js | Rápido |

### CSS Selectors de Referencia

```
/* Elementos */
div, .class, #id, [attribute]

/* Jerarquía */
parent > child
parent child
element + next
element ~ siblings

/* Pseudo-clases */
:first-child, :last-child
:nth-child(2)
:hover, :focus
```

---

## Resumen

En esta guía has aprendido:

- ✅ Instalar y configurar OpenClaw
- ✅ Crear scrapers para extraer datos
- ✅ Integrar OpenClaw con n8n
- ✅ Configurar webhooks para notificaciones
- ✅ Guardar datos en Serverpod
- ✅ Consideraciones éticas del scraping

**Fin del Módulo 3** - Ahora puedes automatizar tareas y extraer datos de la web.

**Siguiente:** Módulo 4: Backend con Serverpod - El Cerebro de tu aplicación.