# 04 — Base de Datos: Supabase (PostgreSQL)

Toda la persistencia de los workflows se apoya en **una sola base de datos PostgreSQL** en Supabase.

---

## 4.1 — Conexión desde n8n

### Opción A: Nodo PostgreSQL Directo

```
Credential Type: PostgreSQL
Host: db.[tu-proyecto].supabase.co
Port: 5432
Database: postgres
User: postgres
Password: [tu-password]
SSL: ✅ (marcado)
```

### Opción B: Nodo HTTP Request a Supabase REST API

```
Credential Type: HTTP Request
URL Base: https://[tu-proyecto].supabase.co/rest/v1/
Headers:
  apikey: [SUPABASE_SERVICE_KEY]
  Authorization: Bearer [SUPABASE_SERVICE_KEY]
  Content-Type: application/json
  Prefer: return=representation
```

**Recomendación:** Usa **Opción A** (PostgreSQL) para operaciones directas y **Opción B** (REST) para prototipos rápidos. La guía usa PostgreSQL por ser más flexible.

---

## 4.2 — Diagrama de Tablas y Relaciones

```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│     jobs     │────▶│   applications   │────▶│  cover_letters  │
│              │     │                  │     │                 │
│ id UUID      │     │ id UUID          │     │ id UUID         │
│ title        │     │ job_id FK        │     │ job_id FK       │
│ company      │     │ status           │     │ content         │
│ url (UNIQUE) │     │ applied_at       │     │ subject         │
│ source       │     │ interview_date   │     │ tone            │
│ relevance    │     │ follow_up_date   │     │ model_used      │
│ skills       │     │ notes            │     │ generated_at    │
└──────────────┘     └──────────────────┘     └─────────────────┘

┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│    leads     │────▶│  outreach_log    │     │  crm_pipeline   │
│              │     │                  │     │                 │
│ id UUID      │     │ id UUID          │     │ id UUID         │
│ company_name │     │ lead_id FK       │     │ lead_id FK (UQ) │
│ contact_info │     │ channel          │     │ stage           │
│ service_match│     │ direction        │     │ probability     │
│ score        │     │ content          │     │ estimated_value │
│ status       │     │ sequence_step    │     │ proposal_url    │
│ source       │     │ status           │     │ closed_at       │
└──────────────┘     │ sent_at          │     │ lost_reason     │
                     │ replied_at       │     └─────────────────┘
                     └──────────────────┘
```

---

## 4.3 — Comandos SQL Útiles

### Query de Pipeline Completo

```sql
SELECT
  l.company_name,
  l.score,
  l.score_label,
  l.service_match,
  p.stage,
  p.probability,
  p.estimated_value,
  p.updated_at AS last_activity
FROM leads l
LEFT JOIN crm_pipeline p ON l.id = p.lead_id
WHERE l.status != 'lost'
ORDER BY p.probability DESC, l.score DESC;
```

### Stats Semanales (para el reporte)

```sql
SELECT
  COUNT(*) FILTER (WHERE source = 'upwork') AS upwork_leads,
  COUNT(*) FILTER (WHERE source = 'linkedin') AS linkedin_leads,
  COUNT(*) FILTER (WHERE status = 'contacted') AS contacted,
  COUNT(*) FILTER (WHERE status = 'proposal_sent') AS proposals,
  COUNT(*) FILTER (WHERE status = 'won') AS won
FROM leads
WHERE created_at > NOW() - INTERVAL '7 days';
```

### Postulaciones Activas para Follow-up

```sql
SELECT j.title, j.company, a.status, a.updated_at
FROM applications a
JOIN jobs j ON a.job_id = j.id
WHERE a.status IN ('applied', 'interview')
  AND a.updated_at < NOW() - INTERVAL '5 days'
ORDER BY a.updated_at ASC;
```

### Leads Fíos para Re-engagement

```sql
SELECT l.id, l.company_name, l.score, l.updated_at
FROM leads l
WHERE l.status IN ('contacted', 'proposal_sent')
  AND l.updated_at < NOW() - INTERVAL '30 days'
  AND l.status NOT IN ('won', 'lost');
```

---

## 4.4 — Configurar Supabase desde Cero

```bash
# 1. Crear proyecto en supabase.com
# 2. Ir a SQL Editor
# 3. Pegar contenido de supabase-schema.sql
# 4. Ejecutar (Cmd+Enter)
# 5. Ir a Project Settings → API → copiar URL y keys

# Variables resultantes:
SUPABASE_URL=https://xaejoxxxxx.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIs...
SUPABASE_DB_HOST=db.xaejoxxxxx.supabase.co
SUPABASE_DB_PASSWORD=tu-password-aqui
```
