# 06 — Workflows de Prospección de Clientes (6-10)

---

## Workflow 6: Lead Scout

**ID:** `06-lead-scout`
**Propósito:** Escanear múltiples fuentes para encontrar potenciales clientes que necesiten desarrollo móvil o automatizaciones n8n.
**Trigger:** Schedule — cada 6 horas (o diario si estás empezando)

### Fuentes de leads

| Fuente | Método | Qué buscar |
|---|---|---|
| **Upwork RSS** | HTTP Request | Proyectos "Flutter", "Mobile App", "n8n", "automation" |
| **Product Hunt** | HTTP Request API | Productos nuevos que podrían necesitar app móvil |
| **LinkedIn (búsqueda)** | Google Alerts RSS | "buscamos desarrollador Flutter", "mobile app startup" |
| **Clutch.co** | HTTP Request | Empresas tech en crecimiento |
| **AngelList / Wellfound** | HTTP Request | Startups levantando ronda |
| **Crunchbase** | HTTP Request (si tienes API) | Empresas que contrataron mobile devs |

### Estructura del Workflow

```
Schedule Trigger (0 */6 * * *)
    │
    ├── Upwork RSS Scanner
    ├── Product Hunt New Products
    ├── LinkedIn Google Alert
    ├── Clutch.co Leaders
    └── Wellfound Startups
            │
            └── Merge
                    │
                    └── HTTP Request → Verificar si existe en Supabase
                    │       SELECT id FROM leads WHERE company_name = X
                    │
                    └── IF (no existe)
                            │
                            └── HTTP Request → INSERT en leads
                            │       status: 'new'
                            │       source: 'upwork' | 'producthunt' | etc.
                            │
                            └── Telegram → "Nuevo lead detectado: [empresa]"
```

### Configuración de cada fuente

#### 6.1 Upwork RSS

```
Node: HTTP Request
URL: https://www.upwork.com/ab/feed/jobs/rss
Parameters:
  q: Flutter OR "mobile app" OR "app development" OR n8n OR automation
  sort: recency
  paging: 0%3B10

Parse: XML → JSON
Mapear: title → lead name / company, description → notas
```

#### 6.2 Product Hunt (nuevos productos)

```
Node: HTTP Request
URL: https://api.producthunt.com/v2/api/graphql
Headers:
  Authorization: Bearer {{ $credentials.productHuntToken }}
  Content-Type: application/json

GraphQL Query:
  { posts(first: 10, order: NEWEST) {
      edges { node {
        name
        tagline
        description
        website
        url
      }}
    }
  }

Filtro post-request:
  - Si el producto podría necesitar app móvil → guardar como lead
  - Si usa "no-code" podría necesitar automatización → guardar
```

#### 6.3 LinkedIn (Google Alert)

Crea una Google Alert para:
```
site:linkedin.com "buscamos desarrollador" Flutter
site:linkedin.com Flutter developer remote
site:linkedin.com n8n automation
site:linkedin.com "mobile app" startup
```

```
Node: HTTP Request
URL: Feed RSS de la Google Alert
```

#### 6.4 Filtro Inteligente Post-Scanner

Después de mergear, aplica un filtro para detectar si el lead es relevante para **tus servicios**:

```
Node: Code (JavaScript)

const text = ($json.title + ' ' + $json.description).toLowerCase();

const mobileKeywords = ['flutter', 'mobile app', 'android', 'ios', 'app development', 'cross-platform', 'dart'];
const automationKeywords = ['n8n', 'automation', 'workflow', 'zapier alternative', 'no-code', 'business process', 'integrations'];

const hasMobileNeed = mobileKeywords.some(k => text.includes(k));
const hasAutomationNeed = automationKeywords.some(k => text.includes(k));

let serviceMatch = [];
if (hasMobileNeed) serviceMatch.push('flutter_app');
if (hasAutomationNeed) serviceMatch.push('n8n_automation');

return {
  ...$json,
  service_match: serviceMatch,
  has_mobile: hasMobileNeed,
  has_automation: hasAutomationNeed
};
```

---

## Workflow 7: Lead Enricher

**ID:** `07-lead-enricher`
**Propósito:** Enriquece cada lead con información adicional usando IA: score, pain points, tech stack, prioridad.
**Trigger:** Webhook (llamado desde W6) + Schedule procesando leads con `score = 0`

### Nodos

```
Webhook / Schedule Trigger
    │
    └── PostgreSQL → SELECT leads WHERE score = 0 OR score_label = 'cold'
    │
    └── Loop (Split In Batches)
    │
    └── HTTP Request → Buscar info adicional (opcional)
    │       - Scrapeo web del sitio de la empresa
    │       - Búsqueda en Google de la empresa
    │
    └── AI (OpenAI / Anthropic)
    │
    └── PostgreSQL → UPDATE en leads
    │
    └── IF (score >= 70) → Telegram: "Lead caliente: [empresa]"
```

### Prompt para IA

```
Node: OpenAI (o Anthropic)
Model: gpt-4o-mini

System: >
  Eres un asistente de prospección comercial para un desarrollador freelance
  llamado Isaac Urdaneta (IDUCDEV). Ofrece estos servicios:
  
  1. Desarrollo móvil con Flutter (iOS + Android cross-platform)
  2. Automatizaciones inteligentes con n8n
  3. Diseño UI/UX mobile
  4. Consultoría técnica backend (Supabase, PostgreSQL)
  
  Tu tarea: analizar un lead potencial y determinar:
  - ¿Qué tan probable es que necesite estos servicios? (score 0-100)
  - ¿Qué servicios específicos necesita?
  - ¿Cuáles son sus posibles pain points?
  - ¿Qué tecnologías usa actualmente?
  
  Responde SOLO con un JSON.

User: |
  Empresa: {{ $json.company_name }}
  Website: {{ $json.website }}
  Industria: {{ $json.industry }}
  Descripción/notas: {{ $json.notes }}

Response (JSON Schema):
{
  "score": "0-100",
  "score_label": "hot | warm | cold",
  "service_match": ["flutter_app", "n8n_automation", "both"],
  "pain_points": ["punto1", "punto2"],
  "tech_stack_detected": ["tecnología1", "tecnología2"],
  "recommended_approach": "email | linkedin | whatsapp",
  "personalized_icebreaker": "frase personalizada para romper el hielo",
  "estimated_budget_range": "$1000-$5000 | $5000-$15000 | $15000+",
  "reasoning": "breve explicación del scoring"
}
```

### Criterios de Scoring

| Score | Label | Acción recomendada |
|---|---|---|
| 80-100 | **hot** | Contactar inmediatamente. Necesitan tus servicios AHORA. |
| 60-79 | **warm** | Potencial. Iniciar secuencia de outreach. |
| 0-59 | **cold** | Monitorear. No contactar aún. |

---

## Workflow 8: Outreach Sequencer

**ID:** `08-outreach-sequencer`
**Propósito:** Ejecutar secuencias de outreach multicanal para leads calientes y tibios.
**Trigger:** Webhook + Schedule

### Estrategia Multicanal

```
Día 0:  Email frío personalizado
Día 3:  LinkedIn DM (si no respondió email)
Día 7:  WhatsApp / Telegram (si no respondió)
Día 14: Follow-up email (último intento)
Día 21: Marcar como "cold" si no hay respuesta
```

### Nodos — Iniciar Secuencia

```
Webhook (recibe lead_id desde W7 o manual)
    │
    └── PostgreSQL → SELECT lead completo
    │
    └── AI (OpenAI) → Generar email personalizado
    │
    └── SMTP → Enviar email
    │
    └── PostgreSQL → INSERT en outreach_log
    │       channel: 'email', sequence_step: 1
    │       status: 'sent'
    │
    └── PostgreSQL → UPDATE leads SET status = 'contacted'
    │
    └── Telegram → "📧 Outreach iniciado con {{ company_name }}"
    │
    └── Schedule → Programar siguiente paso (+3 días)
```

### Prompt para Email Frío

```
System: >
  Eres Isaac Urdaneta, fundador de IDUCDEV, una agencia de desarrollo
  móvil y automatización. Vas a escribir un email de prospección fría
  para ofrecer tus servicios.

  Reglas:
  - Personalizado (menciona algo específico de la empresa)
  - Corto (máximo 150 palabras)
  - Propuesta de valor clara
  - Un solo CTA (agendar llamada de 15min)
  - NO parecer spam
  - Adjuntar portfolio relevante según necesidad

User: |
  Empresa: {{ $json.company_name }}
  Servicio que necesita: {{ $json.service_match }}
  Pain points: {{ $json.pain_points }}
  Icebreaker: {{ $json.personalized_icebreaker }}
  Recommended approach: {{ $json.recommended_approach }}

Response: |
  Subject: [personalizado]
  Body: [email en texto plano]
```

### Nodos — Follow-up Automático

```
Schedule Trigger (cada hora, revisa outreach_log)
    │
    └── PostgreSQL → SELECT 
    │       FROM outreach_log
    │       WHERE status = 'sent'
    │         AND replied_at IS NULL
    │         AND sent_at < NOW() - INTERVAL '3 days'
    │         AND sequence_step < 4
    │
    └── Loop sobre cada uno
    │
    └── AI → Generar follow-up según step
    │
    └── SMTP / LinkedIn / WhatsApp → Enviar
    │
    └── PostgreSQL → INSERT nuevo outreach_log
    │
    └── Telegram → "📬 Follow-up #{{ step }} enviado a {{ company }}"
```

---

## Workflow 9: Proposal Builder

**ID:** `09-proposal-builder`
**Propósito:** Generar propuestas técnicas y comerciales personalizadas usando IA.
**Trigger:** Webhook manual (cuando un lead está listo para recibir propuesta)

### Nodos

```
Telegram Trigger (envías /proposal_[lead_id])
    │
    └── PostgreSQL → SELECT lead completo
    │
    └── AI (OpenAI / Anthropic) → Generar propuesta
    │
    └── HTML to PDF → Renderizar propuesta como PDF
    │       (usando nodo HTML + PDF, o API externa)
    │
    └── HTTP Request → Guardar en Supabase Storage
    │
    └── SMTP → Enviar propuesta por email
    │
    └── PostgreSQL → UPDATE crm_pipeline
    │       stage: 'proposal', proposal_url: '...'
    │
    └── Telegram → "📄 Propuesta enviada a {{ company_name }}"
```

### Prompt para Propuesta

```
System: >
  Eres Isaac Urdaneta, fundador de IDUCDEV.
  Vas a generar una propuesta técnica y comercial para un cliente potencial.

  Datos de tus servicios con precios de referencia:
  
  SERVICIO 1: Desarrollo Mobile (Flutter)
  - App con autenticación + 3 pantallas principales: $1,000 - $3,000
  - App completa (5-8 pantallas + backend): $3,000 - $8,000
  - App compleja (10+ pantallas + tiempo real): $8,000 - $15,000+
  - Tiempo estimado: 1-2 meses
  
  SERVICIO 2: Automatización n8n
  - Workflow simple (2-3 integraciones): $300 - $800
  - Workflow complejo (5+ integraciones + lógica): $800 - $2,500
  - Sistema completo multi-workflow: $2,500 - $5,000
  - Tiempo estimado: 1-3 semanas
  
  SERVICIO 3: Diseño UI/UX Mobile
  - Research + wireframes + prototipo: $500 - $1,500
  - Design system completo: $1,000 - $3,000
  - Tiempo estimado: 2-4 semanas
  
  SERVICIO 4: Consultoría Técnica
  - Auditoría de código + reporte: $300 - $800
  - Setup de infraestructura + CI/CD: $500 - $1,500
  - Sesión de consultoría (1h): $80

  Incluye siempre en la propuesta:
  - Resumen ejecutivo
  - Entendimiento del problema
  - Solución propuesta (con tecnologías)
  - Plan de trabajo y entregables
  - Inversión estimada (si preguntan, dar rango no precio fijo)
  - Timeline
  - Próximos pasos

User: |
  Empresa: {{ $json.company_name }}
  Servicio requerido: {{ $json.service_match }}
  Pain points: {{ $json.pain_points }}
  Notas previas: {{ $json.notes }}
  Presupuesto estimado: {{ $json.estimated_budget_range }}
```

---

## Workflow 10: Pipeline CRM

**ID:** `10-pipeline-crm`
**Propósito:** Mantener un pipeline visual de ventas, tracking de conversiones y re-engagement automático.
**Trigger:** Schedule + Webhook

### Nodos — Dashboard de Pipeline

```
Schedule Trigger (diario 9:00 AM)
    │
    └── PostgreSQL → SELECT pipeline completo
    │       SELECT l.company_name, l.score, l.score_label,
    │              p.stage, p.probability, p.estimated_value,
    │              p.updated_at
    │       FROM crm_pipeline p
    │       JOIN leads l ON p.lead_id = l.id
    │       ORDER BY p.probability DESC
    │
    └── Telegram → Resumen del pipeline:
```

**Mensaje de pipeline:**
```
📊 *Pipeline de Ventas — {{ date }}*
─────────────────────

🔥 *Hot Leads (score > 80)*
{{#each items}}
  {{#if (gte score 80)}}
  • {{ company_name }} — {{ stage }} ({{ probability }}%)
  {{/if}}
{{/each}}

💡 *Warm Leads (score 60-79)*
{{#each items}}
  {{#if (and (gte score 60) (lt score 80))}}
  • {{ company_name }} — {{ stage }}
  {{/if}}
{{/each}}

📊 *Métricas*
• Leads totales: {{ items.length }}
• Propuestas activas: {{ filter stage 'proposal' }}
• Tasa conversión: {{ conversion_rate }}%
• Valor estimado pipeline: ${{ total_value }}
```

### Nodos — Actualización de Estado

```
Telegram Trigger (comandos):
  /won_[lead_id]      → Cerrar como ganado
  /lost_[lead_id]     → Cerrar como perdido (+ pedir razón)
  /meeting_[lead_id]  → Marcar reunión realizada
  /proposal_[lead_id] → Marcar propuesta enviada

Acción:
  UPDATE crm_pipeline SET stage = 'nuevo_estado' WHERE lead_id = X
  UPDATE leads SET status = 'nuevo_estado' WHERE id = X
  Telegram → "✅ {{ empresa }} movido a: {{ nuevo_estado }}"
```

### Nodos — Re-engagement Automático

```
Schedule Trigger
    │
    └── PostgreSQL → SELECT leads fríos
    │       FROM leads l
    │       JOIN crm_pipeline p ON l.id = p.lead_id
    │       WHERE l.status IN ('contacted', 'proposal_sent')
    │         AND l.updated_at < NOW() - INTERVAL '30 days'
    │         AND p.stage NOT IN ('closed_won', 'closed_lost')
    │
    └── Loop
    │
    └── AI → Generar mensaje de re-engagement
    │
    └── SMTP / WhatsApp → Enviar
    │
    └── PostgreSQL → INSERT outreach_log
    │
    └── Telegram → "🔄 Re-engagement con {{ company_name }} después de 30 días"
```

### Prompt de Re-engagement

```
System: >
  Eres Isaac Urdaneta. Vas a escribir un mensaje corto de re-engagement
  para un cliente que no respondió después de 30 días.
  - Tono amigable, no insistente
  - Ofrecer algo de valor nuevo (novedad, caso de éxito, artículo relevante)
  - Una sola pregunta al final
  - Máximo 100 palabras

User: |
  Empresa: {{ company_name }}
  Último contacto: {{ updated_at }}
  Servicio ofrecido: {{ service_match }}
  Último mensaje enviado: (último outreach_log content)
```

---

## Resumen de Comandos Telegram

| Comando | Workflow | Acción |
|---|---|---|
| `/status_[id] [estado]` | W4 | Actualizar estado postulación |
| `/proposal_[lead_id]` | W9 | Generar y enviar propuesta |
| `/won_[lead_id]` | W10 | Cerrar lead como ganado |
| `/lost_[lead_id]` | W10 | Cerrar lead como perdido |
| `/meeting_[lead_id]` | W10 | Registrar reunión realizada |
| `/pipeline` | W10 | Ver pipeline de ventas |
| `/report` | — | Generar reporte semanal |
