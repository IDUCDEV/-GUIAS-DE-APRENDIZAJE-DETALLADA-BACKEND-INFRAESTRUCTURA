# Guía Completa de Automatización n8n

## Búsqueda de Empleo Tech + Prospección de Clientes

**Perfil:** Isaac Urdaneta — Flutter Engineer & n8n Automation Specialist
**Web:** [iducdev.com](https://www.iducdev.com)
**Versión:** 1.0 — Mayo 2026

---

## Estructura de la Guía

### Fundamentos
| Archivo | Contenido |
|---|---|
| `01-introduccion.md` | Visión general, stack tecnológico, arquitectura |
| `02-infraestructura-selfhosted.md` | Track A: n8n local + VPS con Dokploy |
| `03-infraestructura-cloud.md` | Track B: n8n Cloud |
| `04-base-de-datos.md` | Esquema Supabase PostgreSQL + RLS |

### Workflows
| Archivo | Workflows | Área |
|---|---|---|
| `05-workflows-empleo.md` | 1-5: Job Aggregator, Classifier, Cover Letter, Tracker, Alert | Búsqueda de empleo |
| `06-workflows-clientes.md` | 6-10: Lead Scout, Enricher, Outreach, Proposal Builder, Pipeline CRM | Prospección de clientes |

### Recursos
| Archivo | Contenido |
|---|---|
| `07-prompt-templates.md` | Templates para OpenAI/Anthropic/Ollama |
| `08-apendice.md` | Troubleshooting, referencias, roadmap |
| `docker-compose.yml` | Infraestructura self-hosted local |
| `.env.example` | Variables de entorno documentadas |
| `supabase-schema.sql` | Migración SQL completa |

---

## Flujo General

```
                  ┌──────────────────────┐
                  │   n8n Instance        │
                  │ (Cloud o Self-hosted) │
                  └──────┬───────┬───────┘
                         │       │
              ┌──────────┘       └──────────┐
              ▼                              ▼
    ┌─────────────────┐           ┌──────────────────┐
    │  FASE 1         │           │  FASE 2          │
    │  Búsqueda       │           │  Prospección     │
    │  de Empleo      │           │  de Clientes     │
    │                 │           │                  │
    │  W1 JobAggregator│           │  W6 LeadScout    │
    │  W2 JobClassifier│           │  W7 LeadEnricher │
    │  W3 CoverLetter  │           │  W8 OutreachSeq  │
    │  W4 AppTracker   │           │  W9 ProposalBldr │
    │  W5 JobAlert     │           │  W10 PipelineCRM │
    └────────┬────────┘           └────────┬─────────┘
             │                             │
             └──────────┬──────────────────┘
                        ▼
              ┌──────────────────┐
              │   Supabase DB    │
              │  (PostgreSQL)    │
              │                  │
              │  jobs | leads    │
              │  applications    │
              │  outreach_log    │
              │  cover_letters   │
              │  crm_pipeline    │
              └──────────────────┘
```
