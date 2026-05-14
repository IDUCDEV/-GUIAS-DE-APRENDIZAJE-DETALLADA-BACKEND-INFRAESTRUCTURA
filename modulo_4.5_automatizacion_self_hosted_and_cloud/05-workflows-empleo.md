# 05 — Workflows de Búsqueda de Empleo (1-5)

---

## Workflow 1: Job Aggregator

**ID:** `01-job-aggregator`
**Propósito:** Escanear múltiples fuentes en busca de ofertas tech, deduplicar y guardar en Supabase.
**Trigger:** Schedule — cada 4 horas (o cada 2h si estás en búsqueda activa)

### Nodos

```
Schedule Trigger
    │
    ├── LinkedIn Jobs Scraper
    ├── Indeed RSS Feed
    ├── We Work Remotely RSS
    ├── Remote OK RSS
    └── Upwork RSS Feed
            │
            └── Merge (juntar resultados)
                    │
                    └── Item Lists (deduplicar por URL)
                            │
                            └── HTTP Request → INSERT a Supabase (jobs)
                                    │
                                    └── Telegram → "Nuevas ofertas: X encontradas"
```

### Configuración por fuente

#### 1.1 LinkedIn Jobs (vía RSS / Google Search)

```
Node: HTTP Request
URL: https://www.google.com/alerts/feeds/... (Google Alert configurado)
  O usa: RSS feed de LinkedIn Jobs (búsqueda específica)

Query params de búsqueda:
  site:linkedin.com/jobs Flutter OR Dart OR "Mobile Developer" Remote
```

#### 1.2 Indeed RSS

```
Node: HTTP Request
URL: https://www.indeed.com/rss
Method: GET
Query Parameters:
  q: Flutter OR Dart OR "Mobile Developer" OR n8n OR automation
  l: remote
  sort: date
```

#### 1.3 We Work Remotely

```
Node: HTTP Request
URL: https://weworkremotely.com/remote-jobs/search
Method: GET
Query Parameters:
  term: Flutter Dart Mobile automation
```

#### 1.4 Remote OK

```
Node: HTTP Request
URL: https://remoteok.com/api
Note: Esta API devuelve JSON directamente
```

#### 1.5 Upwork (RSS)

```
Node: HTTP Request
URL: https://www.upwork.com/ab/feed/jobs/rss
Query Parameters:
  q: Flutter OR Dart OR "Mobile Developer" OR n8n
 sort: recency
```

### Deduplicación

```
Node: Item Lists
Settings:
  - Field to deduplicate: url
  - Keep: first occurrence
```

### Guardado en Supabase

```
Node: PostgreSQL
Operation: INSERT
Table: jobs
Columns:
  title:     {{ $json.title }}
  company:   {{ $json.company }}
  location:  {{ $json.location }}
  url:       {{ $json.url }}
  source:    {{ $json.source }}
  description: {{ $json.description }}
  remote:   true
  status:   'active'
```

### Notificación

```
Node: Telegram
Message: |
  🔍 *Nuevas ofertas encontradas*
  📊 {{ $("Item Lists").item.length }} ofertas nuevas
  
  Revisa y clasifica: [Workflow 02 - Job Classifier]
```

---

## Workflow 2: Job Classifier

**ID:** `02-job-classifier`
**Propósito:** Clasificar automáticamente cada oferta usando IA para determinar relevancia.
**Trigger:** Webhook (llamado desde Workflow 1 al final, o Schedule procesando `jobs` con `relevance_label = 'pending'`)

### Nodos

```
Webhook (recibe job desde W1) / Schedule Trigger
    │
    └── HTTP Request → Obtener jobs pendientes de Supabase
            │
            └── Loop sobre cada job (Split In Batches)
                    │
                    └── AI (OpenAI / Anthropic / Ollama)
                            │
                            └── HTTP Request → UPDATE en Supabase
                                    │
                                    └── NoOp (fin del loop)
```

### Prompt para IA

```
Node: OpenAI (o Anthropic)
Model: gpt-4o-mini (económico) / claude-sonnet-4

Messages:
  System: >
    Eres un clasificador de ofertas de empleo tech.
    Tu tarea es analizar la descripción de una oferta y determinar
    qué tan relevante es para un desarrollador mobile Flutter senior
    con las siguientes características:
    - Stack principal: Flutter, Dart, Clean Architecture, BLoC, FPdart
    - Backend: Supabase, PostgreSQL, REST APIs
    - DevOps: Docker, Dokploy, n8n, Bash, Makefiles
    - Busca trabajo remoto global (UTC-4, disponible para EST/PST)
    - También hace automatizaciones con n8n

    Responde SOLO con un JSON válido sin formato adicional.

  User: |
    Título: {{ $json.title }}
    Empresa: {{ $json.company }}
    Descripción: {{ $json.description }}

Response (JSON Schema):
{
  "score": "número del 0 al 100",
  "label": "high | medium | low",
  "reason": "breve explicación de 1 línea",
  "skills_detected": ["Flutter", "Dart", ...],
  "is_remote": true/false
}
```

### Guardado en Supabase

```
Node: PostgreSQL
Operation: UPDATE
Table: jobs
Update Key: id = {{ $json.id }}
Columns:
  relevance_score: {{ $json.score }}
  relevance_label: {{ $json.label }}
  skills_detected: {{ $json.skills_detected }}
```

### Criterios de clasificación

| Score | Label | Significado |
|---|---|---|
| 80-100 | **high** | Match perfecto. Aplica YA. |
| 50-79 | **medium** | Posible. Revisa manualmente. |
| 0-49 | **low** | No relevante. Ignorar. |

---

## Workflow 3: Cover Letter Generator

**ID:** `03-cover-letter-generator`
**Propósito:** Generar cover letters personalizadas usando IA, basadas en tu CV real y la descripción del puesto.
**Trigger:** Webhook (llamado manualmente desde un botón en Telegram o desde el Workflow 2 cuando `label = high`)

### Nodos

```
Webhook (recibe job_id)
    │
    └── PostgreSQL → Obtener datos del job
    │       SELECT * FROM jobs WHERE id = {{ $json.job_id }}
    │
    └── AI (OpenAI / Anthropic) → Generar cover letter
    │
    └── HTTP Request → INSERT en Supabase (cover_letters)
    │
    └── Telegram → "Cover letter generada para [empresa]"
```

### Prompt para IA

```
System: >
  Eres Isaac Urdaneta, un ingeniero mobile senior especializado en Flutter
  y automatizaciones con n8n. Vas a escribir una cover letter en español
  (o inglés si la oferta está en inglés) para postularte a un trabajo.

  Tu tono es profesional pero cercano, destacando resultados concretos.

  Datos de tu perfil (USA ESTOS DATOS REALES):
  - Nombre: Isaac Urdaneta
  - Especialidad: Flutter, Dart, Clean Architecture, FPdart, BLoC
  - Backend: Supabase, PostgreSQL
  - DevOps: Docker, Dokploy, n8n, Bash, GitHub Actions
  - Logros clave:
    * Arquitectura modular desacoplada que permite intercambio de backend
    * Motor de mapeo emocional con 94% de precisión (SereniFlu)
    * Reducción del 50% en setup de entornos con automatización Docker/Makefile
    * 98% Lighthouse accesibilidad
    * Reducción del 35% en tiempos de respuesta de API
  - Portafolio: https://www.iducdev.com
  - LinkedIn: linkedin.com/in/isaac-urdaneta

  La cover letter debe:
  1. Mencionar 1-2 logros relevantes al puesto
  2. Ser específica (no genérica)
  3. Explicar por qué te interesa ESA empresa
  4. Incluir un CTA (llamado a la acción)
  5. NO más de 300 palabras
  6. Incluir asunto para el email

  Responde SOLO con un JSON.

User: |
  Puesto: {{ $json.title }}
  Empresa: {{ $json.company }}
  Descripción del puesto: {{ $json.description }}

Response (JSON Schema):
{
  "subject": "asunto del email",
  "body": "cover letter en texto plano",
  "tone": "professional | casual | passionate"
}
```

### Guardado

```
Node: PostgreSQL → INSERT en cover_letters
  job_id: {{ $json.job_id }}
  content: {{ $json.body }}
  subject: {{ $json.subject }}
  tone: {{ $json.tone }}
  model_used: gpt-4

Node: PostgreSQL → UPDATE en applications (si ya existe)
  O INSERT en applications:
    job_id: {{ $json.job_id }}
    company: {{ $json.company }}
    position: {{ $json.title }}
    cover_letter_id: {{ $json.cover_letter_id }}
    status: 'pending'
```

---

## Workflow 4: Application Tracker

**ID:** `04-application-tracker`
**Propósito:** Registrar y hacer seguimiento de todas las postulaciones. Actualizar estados mediante comandos.
**Trigger:** Webhook + Schedule.

### Nodos — Registro de postulación

```
Webhook (llamado desde W3 al generar cover letter)
    │
    └── PostgreSQL → INSERT en applications
    │       status: 'applied'
    │       applied_at: NOW()
    │
    └── Telegram
    │       "✅ Postulación enviada a {{ company }} como {{ position }}"
    │
    └── NoOp
```

### Nodos — Seguimiento (Schedule semanal)

```
Schedule Trigger (cada domingo 10:00)
    │
    └── PostgreSQL → SELECT aplicaciones activas
    │       WHERE status IN ('applied', 'interview')
    │         AND updated_at < NOW() - INTERVAL '5 days'
    │
    └── Loop sobre cada una
    │
    └── Telegram
            "⏰ Follow-up pendiente: {{ company }} - {{ position }}
             Estado actual: {{ status }}
             Última actualización: {{ updated_at }}
             
             Comandos:
             /status_{{ id }} interview  → Marcar entrevista
             /status_{{ id }} offer      → Marcar oferta
             /status_{{ id }} rejected   → Marcar rechazo
             /status_{{ id }} ghosted    → Marcar ghosted"
```

### Nodos — Actualización por comando

```
Telegram Trigger (cuando envías /status_xxx nuevo_estado)
    │
    └── PostgreSQL → UPDATE applications
    │       SET status = 'nuevo_estado',
    │           updated_at = NOW()
    │       WHERE id = 'xxx'
    │
    └── Telegram
            "✅ {{ company }} actualizado a: {{ nuevo_estado }}"
```

---

## Workflow 5: Job Alert

**ID:** `05-job-alert`
**Propósito:** Enviar un resumen diario de las mejores ofertas detectadas.
**Trigger:** Schedule — cada día a las 8:00 AM (hora local).

### Nodos

```
Schedule Trigger (0 8 * * *)
    │
    └── PostgreSQL → SELECT ofertas TOP del día
    │       SELECT * FROM jobs
    │       WHERE relevance_label = 'high'
    │         AND created_at > NOW() - INTERVAL '24 hours'
    │       ORDER BY relevance_score DESC
    │       LIMIT 10
    │
    └── Telegram
    │       "📱 *Resumen diario de ofertas* ({{ date }})
    │        
    │        🔥 *High Priority:*
    │        {{#each items}}
    │        {{ $index + 1 }}. *{{ title }}* en {{ company }}
    │          📍 {{ location }} | ⭐ {{ relevance_score }}/100
    │          🔗 {{ url }}
    │
    │        {{/each}}
    │        
    │        📊 Total: {{ items.length }} ofertas relevantes hoy"
    │
    └── (Opcional) Enviar también por email
    │
    └── NoOp
```

### Configuración del Schedule

```
Expression cron: 0 8 * * *  (todos los días a las 8 AM)
Zona horaria: America/Caracas (UTC-4)

Si quieres también a las 8 PM:
Expression cron: 0 20 * * *
```
