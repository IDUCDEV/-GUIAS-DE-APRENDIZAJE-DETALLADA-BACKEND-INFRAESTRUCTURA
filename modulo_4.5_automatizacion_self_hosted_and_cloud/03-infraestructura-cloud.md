# 03 — Track B: Infraestructura n8n Cloud

Si prefieres arrancar rápido sin preocuparte por servidores.

---

## 3.1 — Setup Inicial

1. Regístrate en [n8n.cloud](https://n8n.cloud)
2. Elige plan **Starter** ($20/mes) o **Pro** ($50/mes)
3. Tras crear la instancia, recibirás una URL como `https://tunombre.app.n8n.cloud`

### Post-instalación Cloud

```bash
# 1. Accede a tu instancia
# 2. Settings → Credentials → Agrega:
```

Credenciales a configurar (mismas que en self-hosted):
- Supabase URL + API Key (Service Role)
- OpenAI / Anthropic API Key
- Gmail SMTP
- Telegram Bot
- WhatsApp API
- LinkedIn API (si aplica)

---

## 3.2 — Conexión a Supabase Externa

n8n Cloud usa SQLite por defecto. Para nuestros workflows necesitas PostgreSQL externa:

### Opciones:
- **Supabase** (gratis — 500MB) — Recomendado
- **Neon.tech** (gratis — 1GB)
- **Railway** ($5/mes)

### Configurar Supabase:

```sql
-- En Supabase SQL Editor, ejecuta el schema
-- Ver archivo supabase-schema.sql
```

### Conectar desde n8n Cloud:

1. **Credentials → New → PostgreSQL**
2. Configura:

```
Host: db.xaejoxxxxx.supabase.co
Port: 5432
Database: postgres
User: postgres
Password: <tu-password>
SSL: true
```

3. **Test Connection** → verde = listo

---

## 3.3 — Limitaciones y Workarounds

| Limitación | Problema | Workaround |
|---|---|---|
| **Community Nodes** | No disponibles en Cloud | Usar HTTP Request nodes para APIs custom |
| **Timeout ejecución** | 10 min máximo | Dividir workflows largos en sub-workflows |
| **Memoria** | 2.5GB RAM (Starter) | Optimizar llamadas IA (modelos pequeños) |
| **Almacenamiento** | 1GB (Starter) | Almacenar archivos en Supabase Storage |
| **Ejecuciones/mes** | 5k (Starter) | Priorizar workflows clave |

### Si superas límites:

```bash
# Opción 1: Subir a plan Pro ($50/mes)
#   - 10GB RAM
#   - 20k ejecuciones
#   - Timeout 15 min

# Opción 2: Migrar a self-hosted (docker-compose.yml)
#   - Sin límites de ejecución
#   - Community nodes disponibles
#   - Ollama gratis para IA
```
