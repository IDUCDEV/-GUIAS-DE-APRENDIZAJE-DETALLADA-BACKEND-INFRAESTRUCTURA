# 08 — Apéndice

---

## A.1 — Generar Clave de Encriptación para n8n

```bash
# Una vez generada, úsala en N8N_ENCRYPTION_KEY
openssl rand -hex 32
# Ejemplo output: 5e9c0d8f3a2b1c7d4e6f8a0b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c
```

---

## A.2 — Crear un Bot de Telegram

1. Abre Telegram y busca **@BotFather**
2. Envía `/newbot` y sigue las instrucciones
3. Guarda el token que te da (formato: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)
4. Busca tu bot y envíale `/start`
5. Obtén tu Chat ID:
   - Envía un mensaje a tu bot
   - Visita: `https://api.telegram.org/bot<TOKEN>/getUpdates`
   - Tu Chat ID aparece en `message.chat.id`

---

## A.3 — App Password de Gmail (para SMTP)

1. Activa 2FA en tu cuenta Google
2. Ve a: [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
3. Selecciona "Mail" y "Other" → escribe "n8n"
4. Copia el password de 16 caracteres generado
5. Úsalo en SMTP credential de n8n

---

## A.4 — Expresiones Útiles de n8n

```javascript
// Fecha actual formateada
{{ new Date().toLocaleDateString('es-ES', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}

// Hace N días
{{ new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString() }}

// Extraer dominio de URL
{{ $json.url.split('/')[2] }}

// Limpiar HTML tags
{{ $json.description.replace(/<[^>]*>/g, '') }}

// Truncar texto
{{ $json.description.substring(0, 500) }}

// Array a string separado por comas
{{ $json.skills_detected.join(', ') }}

// IF en n8n
{{ $json.score >= 80 ? 'high' : ($json.score >= 50 ? 'medium' : 'low') }}
```

---

## A.5 — Troubleshooting Común

| Problema | Causa | Solución |
|---|---|---|
| **Conexión a Supabase falla** | SSL no activado | Marca "Enable SSL" en credencial PostgreSQL |
| **OpenAI timeout** | Modelo lento | Usa `gpt-4o-mini` en lugar de `gpt-4` |
| **Deduplicación no funciona** | URLs diferentes para mismo job | Normalizar URL (quitar query params) |
| **Telegram no envía** | Bot no iniciado | Envía `/start` a tu bot primero |
| **Workflow no se activa** | Trigger deshabilitado | Click "Activate" en el workflow |
| **Email SMTP rebotado** | App password incorrecto | Regenerar en myaccount.google.com |
| **n8n local no arranca** | Puerto 5678 ocupado | Cambia en docker-compose.yml |
| **Ollama respuestas lentas** | RAM insuficiente | Usa modelo `llama3.2:1b` (1B params) |
| **Ejecuciones Cloud agotadas** | Límite del plan | Migrar a self-hosted o subir plan |

---

## A.6 — Roadmap de Expansión

Una vez tengas los 10 workflows funcionando:

### Fase Mejora (Siguiente mes)
- [ ] **Dashboard web** en Next.js sobre Supabase para ver stats visuales
- [ ] **Análisis de mercado** qué skills están más demandados
- [ ] **A/B testing** de templates de outreach (cuál funciona mejor)
- [ ] **Auto-respuesta** a leads que responden (clasificar reply con IA)

### Fase Escalabilidad (3-6 meses)
- [ ] **Multi-idioma** en outreach (inglés/español automático según lead)
- [ ] **Integración CRM** (HubSpot, Pipedrive, etc.)
- [ ] **Auto-scheduling** de llamadas (Calendly API)
- [ ] **N8n clustering** si tienes muchos workflows pesados
- [ ] **Pipeline visual** con Streamlit o Retool

---

## A.7 — Referencias y Recursos

### Documentación
- [n8n Docs](https://docs.n8n.io/)
- [n8n Community Nodes](https://docs.n8n.io/integrations/community-nodes/)
- [Supabase Docs](https://supabase.com/docs)
- [Dokploy Docs](https://dokploy.com/docs)

### APIs externas
- [OpenAI API](https://platform.openai.com/docs)
- [Anthropic API](https://docs.anthropic.com/)
- [Telegram Bot API](https://core.telegram.org/bots/api)
- [Indeed Publisher API](https://developer.indeed.com/)
- [Upwork API](https://developers.upwork.com/)
- [Product Hunt API](https://api.producthunt.com/v2/docs)

### Herramientas complementarias
- **Ollama** — Modelos locales: `ollama pull llama3.2`, `ollama pull mistral`
- **Ngrok** — Exponer webhooks locales: `ngrok http 5678`
- **PGAdmin** — Gestión de PostgreSQL (incluido en docker-compose)
- **TablePlus** — Cliente SQL para macOS/Windows

---

## A.8 — Changelog

| Versión | Fecha | Cambios |
|---|---|---|
| 1.0 | Mayo 2026 | Versión inicial completa |
