# 01 — Introducción

## Visión General

Esta guía te enseña a construir **dos sistemas de automatización completos** con n8n:

1. **Buscador automático de empleo tech** — Agrega ofertas de múltiples fuentes, las clasifica con IA, genera cover letters personalizadas y te notifica.
2. **Prospector automático de clientes** — Encuentra leads potenciales para tus servicios de desarrollo móvil y automatización n8n, los enriquece con IA y ejecuta secuencias de outreach multicanal.

## Stack Tecnológico

| Componente | Tecnología | Propósito |
|---|---|---|
| **Orquestador** | n8n (Cloud o Self-hosted) | Workflow automation |
| **BD principal** | Supabase (PostgreSQL) | Almacenamiento de datos |
| **IA** | OpenAI GPT-4 / Anthropic Claude / Ollama (local) | Clasificación, generación de texto |
| **Notificaciones** | Telegram Bot / WhatsApp API | Alertas en tiempo real |
| **Outreach** | Gmail SMTP + LinkedIn API | Contacto con leads |
| **Infraestructura** | Docker + Dokploy (VPS) | Self-hosted deployment |

## Arquitectura de Datos

```
n8n ──HTTP──▶ Supabase (PostgreSQL)
  │              │
  │              ├── jobs: ofertas de empleo scrapeadas
  │              ├── applications: postulaciones enviadas
  │              ├── cover_letters: cartas generadas
  │              ├── leads: prospectos de clientes
  │              ├── outreach_log: historial de contacto
  │              └── crm_pipeline: pipeline de ventas
  │
  ├──▶ OpenAI / Anthropic / Ollama (IA)
  ├──▶ Telegram / WhatsApp (notificaciones)
  └──▶ Gmail / LinkedIn (outreach)
```

## Convenciones

### Nombrado de Workflows
```
[ID]-[nombre-corto]
```
Ejemplos: `01-job-aggregator`, `06-lead-scout`

### Variables de Entorno
```
n8n_ prefijo para variables de n8n
DB_ prefijo para base de datos
IA_ prefijo para APIs de IA
OUTREACH_ prefijo para outreach
```

### Estados Compartidos

**Application status:** `pending` → `applied` → `interview` → `offer` | `rejected`

**Lead status:** `new` → `contacted` → `proposal_sent` → `negotiation` → `won` | `lost`

**Lead score:** `hot` (90-100), `warm` (60-89), `cold` (0-59)
