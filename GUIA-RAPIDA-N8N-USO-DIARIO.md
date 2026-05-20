# 📋 Guía de Uso Diario: n8n Autoalojado

> **Para servidor que no siempre está encendido.**  
> Todo está configurado para arrancar solo. Tu rutina: prender → esperar 1 min → usar.

---

## Filosofía de Operación

Tu servidor Ubuntu tiene estas capas que arrancan automáticamente:

```
 PRENDES EL PC
       │
       ▼
┌──────────────────┐
│   SYSTEMD        │  ← Arranca automáticamente al bootear
│                   │
│  ● docker.service │  → Arranca todos los contenedores
│  ● dokploy.service│  → Arranca el panel de control
└──────────────────┘
       │
       ▼
┌──────────────────┐
│   DOCKER          │  ← restart: unless-stopped
│                   │
│  ● n8n            │  → Se inicia solo
│  ● n8n-postgres   │  → Se inicia solo
└──────────────────┘
       │
       ▼
   ┌──────────┐
   │  LISTO   │  ← ~1 min después de prender
   └──────────┘
```

> Si configuraste Cloudflare Tunnel (Paso 4 de la guía de instalación), se agrega `cloudflared.service` como tercera capa.

**No necesitas hacer nada manual.** Todo arranca, todo se conecta.

---

## Encender el Servidor

### Rutina completa (30 segundos)

```bash
# 1. Prende el PC
# 2. Inicia sesión (o espera a que arranque si es headless)
# 3. Verifica que todo está bien:
```

### Verificación rápida

```bash
# Un solo comando para ver el estado general
docker ps

# Lo que DEBES ver:
# CONTAINER ID   IMAGE                STATUS          PORTS
# xxxxxxxx       n8nio/n8n:latest     Up 1 minute     0.0.0.0:5678->5678/tcp
# xxxxxxxx       postgres:15-alpine   Up 1 minute     5432/tcp
# xxxxxxxx       dokploy/dokploy      Up 1 minute     0.0.0.0:3000->3000/tcp
```

### Verificación más detallada

```bash
# Estado de Dokploy
sudo systemctl status dokploy --no-pager -l

# Estado del stack n8n (con Docker Swarm)
docker service ls

# Si tienes Cloudflare Tunnel:
sudo systemctl status cloudflared --no-pager -l
```

### Probar acceso

```bash
# Desde el servidor mismo
curl -I http://localhost:5678

# Desde cualquier navegador
# http://192.168.0.100:5678   ← n8n (red local)
# http://192.168.0.100:3000   ← Dokploy (red local)
# https://n8n.iducdev.org     ← n8n (internet, si tienes Cloudflare Tunnel)
```

> ✅ Si ves la pantalla de login de n8n, ya está todo listo.

---

## Apagar el Servidor

### Apagado limpio (recomendado)

```bash
# 1. (Opcional) Haz un backup rápido (ver sección Backups)
# 2. Apagar el sistema
sudo shutdown -h now
```

Systemd se encarga de:
- Docker detiene los contenedores con grace period (10s)
- Apagar el PC
- (Si tienes Cloudflare Tunnel, también lo detiene ordenadamente)

> ⚠️ **No cortes la corriente directamente.** Aunque Docker y PostgreSQL son resistentes a cortes, un apagado limpio evita corrupción de datos.

### Reinicio

```bash
sudo reboot
```

Mismo proceso: al volver, todo arranca solo.

---

## Comandos Rápidos (Los que Más Usarás)

### Estado y Logs

| Acción | Comando |
|--------|---------|
| Ver contenedores activos | `docker ps` |
| Ver todos los contenedores | `docker ps -a` |
| Logs de n8n en tiempo real | `docker logs n8n -f --tail 50` |
| Logs de PostgreSQL | `docker logs n8n-postgres -f --tail 50` |

### Gestión de Contenedores

| Acción | Comando |
|--------|---------|
| Reiniciar n8n | `docker restart n8n` |
| Detener n8n (sin apagar PC) | `docker stop n8n` |
| Iniciar n8n (si estaba detenido) | `docker start n8n` |
| Ver recursos usados | `docker stats --no-stream` |

### Dokploy

| Acción | Comando |
|--------|---------|
| Estado de Dokploy | `sudo systemctl status dokploy` |
| Logs de Dokploy | `docker service logs dokploy --tail 50` |
| Ver servicios de Dokploy | `docker service ls` |
| Acceso web | `http://192.168.0.100:3000` |

### Cloudflare Tunnel (solo si lo configuraste)

| Acción | Comando |
|--------|---------|
| Iniciar tunnel | `sudo systemctl start cloudflared` |
| Detener tunnel | `sudo systemctl stop cloudflared` |
| Estado del tunnel | `sudo systemctl status cloudflared --no-pager` |
| Logs del tunnel | `sudo journalctl -u cloudflared -n 30 --no-pager` |
| Verificar conexión | `curl -I https://n8n.iducdev.org` |

---

## Backups Exprés (Antes de Apagar)

### 1. Backup de la base de datos

```bash
# Exportar toda la BD de n8n a un archivo
docker exec n8n-postgres pg_dump -U n8nuser n8n > ~/backup-n8n-$(date +%Y%m%d).sql

# Comprimir (pasa de ~50MB a ~2MB)
gzip ~/backup-n8n-*.sql

# Ejemplo de archivo generado: backup-n8n-20260517.sql.gz
```

### 2. Backup de workflows (alternativa)

Desde la interfaz de n8n:
**Settings → Export → Export all workflows**

Esto descarga un JSON con todos tus workflows (sin credenciales).

### 3. Restaurar un backup

```bash
# Si necesitas restaurar la BD
cat backup-n8n-20260517.sql | docker exec -i n8n-postgres psql -U n8nuser n8n

# O desde un archivo comprimido
gunzip -c backup-n8n-20260517.sql.gz | docker exec -i n8n-postgres psql -U n8nuser n8n
```

> ⚠️ **Las credenciales de n8n (API keys) dependen de la encryption key.** Si restauras la BD pero la encryption key es diferente, las credenciales no funcionarán. Guarda la encryption key cuando cambies de PC.

---

## Troubleshooting

| Problema | Causa probable | Solución |
|----------|---------------|----------|
| `http://192.168.0.100:5678` no carga | PC apagado o n8n caído | `docker ps` y `docker logs n8n` |
| n8n no responde | Contenedor caído | `docker restart n8n` |
| PostgreSQL no conecta | BD no lista | `docker logs n8n-postgres` |
| "Invalid encryption key" al restaurar | Cambiaste la encryption key | Restaura la key original en las env vars |
| Dokploy no carga | Servicio caído | `sudo systemctl restart dokploy` |
| No recuerdo la IP del servidor | — | `hostname -I` en el servidor |
| n8n pide crear cuenta otra vez | Borraste el volumen de n8n | Si tenías workflows, restaurar desde backup |
| `https://n8n.iducdev.org` no carga | Tunnel caído | `sudo systemctl status cloudflared --no-pager` |

> 💡 **Si tienes Cloudflare Tunnel** y falla, revisa con `sudo systemctl status cloudflared --no-pager` o `sudo journalctl -u cloudflared -n 30 --no-pager`.

### n8n no arranca porque PostgreSQL no está listo

```bash
# Ver si PostgreSQL está vivo
docker exec n8n-postgres pg_isready -U n8nuser

# Si no responde, ver logs
docker logs n8n-postgres --tail 20

# Si la BD está corrupta (raro, pero posible con corte de luz)
# Borrar el volumen y recrear (pierdes datos)
docker compose -f ~/n8n-docker-compose.yml down -v
docker compose -f ~/n8n-docker-compose.yml up -d
```

---

## Referencia Rápida: Los 10 Comandos Esenciales

```bash
# 1. Estado general
docker ps

# 2. Logs de n8n
docker logs n8n -f --tail 50

# 3. Reiniciar n8n
docker restart n8n

# 4. Backup rápido de BD
docker exec n8n-postgres pg_dump -U n8nuser n8n | gzip > ~/backup-n8n-$(date +%Y%m%d).sql.gz

# 5. Ver IP del servidor
hostname -I

# 6. Estado de Dokploy
sudo systemctl status dokploy --no-pager

# 7. Ver servicios de Dokploy (Swarm)
docker service ls

# 8. Ver recursos del sistema
htop
# Si no tienes htop: sudo apt install htop

# 9. Apagar el servidor
sudo shutdown -h now

# 10. Acceso web
echo "n8n: http://$(hostname -I | awk '{print $1}'):5678"
echo "Dokploy: http://$(hostname -I | awk '{print $1}'):3000"
```

---

## Tu Rutina Diaria (Resumen)

```bash
# ── ENCENDER ──────────────────────────────────────────────────
# Prender PC → esperar 1 minuto
docker ps                                    # Verificar contenedores
curl -I http://localhost:5678                # Probar n8n local
# Abrir http://192.168.0.100:5678            # n8n (red local)
# Abrir https://n8n.iducdev.org              # n8n (internet, Cloudflare Tunnel)
# Abrir http://192.168.0.100:3000            # Dokploy (red local)

# ── USAR n8n ──────────────────────────────────────────────────
# Crea tus workflows, todo funciona igual que n8n.cloud

# ── APAGAR ────────────────────────────────────────────────────
# (Opcional) docker exec n8n-postgres pg_dump -U n8nuser n8n | gzip > ~/backup-n8n-$(date +%Y%m%d).sql.gz
sudo shutdown -h now                         # Apagar

# ── SOLUCIÓN RÁPIDA ──────────────────────────────────────────
# Si algo no funciona al prender:
docker restart n8n
# Si tienes Tunnel:
sudo systemctl restart cloudflared
```

---

## Notas para tu Contexto (Módulo 2)

Estás aprendiendo LazyVim. Todo esto que instalamos:

- **Docker** → Lo profundizarás en Módulo 3
- **Docker Compose** → El archivo YAML que usamos es un adelanto del Módulo 3.2
- **Dokploy** → Lo verás a detalle en Módulo 3.3
- **n8n** → Los workflows los construirás en Módulo 4 y 4.5
- **Cloudflare Tunnel** → Para exponer n8n a internet con dominio propio (Paso 4 de la guía de instalación)
- **PostgreSQL** → Base de datos que usarás con Serverpod (Módulo 5)

Por ahora solo úsalo. Cuando llegues a cada módulo, todo tendrá más sentido.
