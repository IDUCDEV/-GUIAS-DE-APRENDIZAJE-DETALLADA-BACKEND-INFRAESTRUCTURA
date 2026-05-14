# 02 — Track A: Infraestructura Self-hosted (Local + VPS)

Este track es para **aprender infraestructura** mientras montas tu propio n8n. Ideal para tu objetivo de dominar Docker, Dokploy y administración de servidores.

---

## 2.1 — Local: Docker Compose

Crea un archivo `docker-compose.yml` en tu máquina local (ver archivo adjunto `docker-compose.yml`).

```bash
# Arrancar todo
docker compose up -d

# Ver logs
docker compose logs -f n8n

# Detener
docker compose down
```

Esto levanta:
- **n8n** en `http://localhost:5678`
- **PostgreSQL** como base de datos interna de n8n (puerto 5432)
- **Ollama** para IA local gratuita (puerto 11434)
- **pgAdmin** para gestionar BD en `http://localhost:5050`

### Post-instalación local

```bash
# 1. Configurar owner de n8n
docker compose exec n8n chown -R 1000:1000 /home/node/.n8n

# 2. Verificar que Ollama funciona
curl http://localhost:11434/api/tags

# 3. Descargar modelo para IA local (opcional, gratis)
docker compose exec ollama ollama pull llama3.2
docker compose exec ollama ollama pull mistral
```

### Acceso local
1. Abre `http://localhost:5678`
2. Crea tu cuenta de owner
3. Ve a **Settings → Credentials** y configura:
   - OpenAI / Anthropic API Key
   - Gmail / SMTP
   - Telegram Bot Token
   - Supabase URL + Service Key

---

## 2.2 — Producción: VPS + Dokploy

### Requisitos VPS
- **Proveedor:** Hetzner, DigitalOcean, Vultr ($5-10/mes)
- **SO:** Ubuntu 22.04+
- **RAM:** Mínimo 2GB (recomendado 4GB)
- **Disco:** 20GB+
- **Dominio:** `n8n.tudominio.com` (opcional)

### Paso 1: Instalar Dokploy en el VPS

```bash
# SSH al VPS
ssh root@tu-vps-ip

# Instalar Dokploy
curl -sSL https://dokploy.com/install.sh | sh

# Acceder a Dokploy
# Abre http://tu-vps-ip:3000 y crea tu cuenta
```

### Paso 2: Desplegar n8n con Dokploy

Desde la interfaz de Dokploy:

1. **Nuevo proyecto** → `n8n-automation`
2. **Nuevo servicio** → `n8n`
3. **Configuración:**

```
Container Image: n8nio/n8n:latest
Port: 5678
Network: bridge

Variables de Entorno:
  N8N_HOST=https://n8n.tudominio.com
  N8N_PORT=5678
  N8N_PROTOCOL=https
  DB_TYPE=postgresdb
  DB_POSTGRESDB_HOST=postgres  # o Supabase host
  DB_POSTGRESDB_PORT=5432
  DB_POSTGRESDB_DATABASE=n8n
  DB_POSTGRESDB_USER=n8nuser
  DB_POSTGRESDB_PASSWORD=<password_segura>
  N8N_ENCRYPTION_KEY=<generar_con_comando>

Volumes:
  /home/node/.n8n:/data
```

4. **Agregar PostgreSQL** como servicio adjunto en Dokploy, o conectar directamente a Supabase externa.
5. **Configurar dominio y SSL** desde Dokploy (Traefik automático).

### Paso 3: Backup Automático

```bash
# Backup de PostgreSQL
docker exec <postgres_container> pg_dump -U n8nuser n8n > backup-$(date +%Y%m%d).sql

# Backup de workflows (desde UI de n8n)
# Settings → Export → All Workflows
```

---

## 2.3 — Credenciales Compartidas

Configura estas credenciales tanto en local como en VPS:

| Nombre | Tipo | Servicio |
|---|---|---|
| `supabase_api` | HTTP Request | Supabase REST API |
| `supabase_db` | PostgreSQL | Conexión directa a BD |
| `openai_api` | OpenAI | GPT-4 para clasificación/generación |
| `anthropic_api` | Anthropic | Claude como alternativa |
| `ollama_local` | OpenAI compatible | IA local (solo en local) |
| `telegram_bot` | Telegram | Notificaciones |
| `gmail_smtp` | SMTP | Envío de emails |
| `whatsapp_api` | HTTP Request | WhatsApp Business API |
| `linkedin_api` | HTTP Request | LinkedIn (si aplica) |

---

## 2.4 — Migración Local → VPS

```bash
# 1. En local: exportar workflows
# n8n UI → Settings → Export Workflows → Download All

# 2. En VPS: importar workflows
# n8n UI → Settings → Import Workflows → Upload JSON

# 3. Actualizar credenciales en VPS
# Las credenciales NO se exportan/importan
# Debes crearlas manualmente en el VPS

# 4. Verificar conexiones
# Ejecuta manualmente cada workflow en el VPS
```

### Diferencia clave: IA en local vs VPS

| Entorno | IA recomendada | Coste |
|---|---|---|
| **Local** | Ollama (llama3.2, mistral) | Gratis |
| **VPS** | OpenAI / Anthropic | ~$5-20/mes según uso |

Para producción usa OpenAI/Anthropic. Para aprendizaje usa Ollama gratis.
