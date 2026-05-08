# Módulo 6: Despliegue en VPS Remoto (Producción)

## 4. Monitoreo

### Objetivos de Aprendizaje

- Monitorear recursos del servidor
- Ver logs de aplicaciones
- Configurar alertas
- Usar herramientas de monitoreo

---

## 4.1 Importancia del Monitoreo

### ¿Por qué monitorear?

```
┌─────────────────────────────────────────────────────────────┐
│                 RAZONES PARA MONITOREAR                    │
│                                                             │
│  1. Detectar problemas antes de que afecten usuarios       │
│  2. Optimizar rendimiento                                   │
│  3. Planear capacidad (cuándo hacer upgrade)              │
│  4. Security (detectar actividad sospechosa)              │
│  5. Debugging (cuando algo falla)                         │
│  6. Cumplimiento (auditorías)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Métricas Clave

```
CPU: ¿Cuánta capacidad usas?
Memoria: ¿Cuánta RAM disponible?
Disco: ¿Espacio suficiente?
Red: ¿Ancho de banda usado?
Uptime: ¿Tiempo disponible?
Errores: ¿Hay errores en logs?
```

---

## 4.2 Monitoreo de Recursos

### htop - Monitor de Procesos

```bash
# Instalar si no está
sudo apt install htop

# Ejecutar
htop

# Teclas útiles:
# - q: salir
# - k: matar proceso
# - t: tree view
# - c: ordenar por CPU
# - m: ordenar por memoria
```

### Ver Recursos del Sistema

```bash
# CPU
top
# o
htop

# Memoria
free -h

# Disco
df -h

# Procesos
ps aux | head -20

# Información general
neofetch
```

### Ver Uso de Red

```bash
# Ver conexiones
ss -tuln

# Ver uso de red por proceso
sudo nethogs

# Ancho de banda
sudo iftop

# Estadísticas de red
netstat -s
```

---

## 4.3 Logs del Sistema

### Ver Logs de Sistema

```bash
# Ver logs del sistema
journalctl

# Ver últimos mensajes
journalctl -n 100

# Ver logs de un servicio específico
journalctl -u docker
journalctl -u nginx

# Ver errores
journalctl -p err

# Seguir logs en tiempo real
journalctl -f
```

### Ver Logs de Docker

```bash
# Ver logs de un contenedor
docker logs nombre_contenedor
docker logs -f nombre_contenedor  # seguir

# Ver logs de todos los contenedores
docker compose logs

# Logs con timestamps
docker logs -t nombre_contenedor

# Últimas líneas
docker logs --tail 100 nombre_contenedor
```

### Ver Logs de Aplicación

```bash
# Logs de Serverpod
docker logs serverpod --tail 100 -f

# Logs de PostgreSQL
docker logs postgres --tail 100

# Logs de Nginx (si tienes)
docker logs nginx --tail 100 -f
```

---

## 4.4 Monitoreo con Prometheus + Grafana

### Instalar con Docker Compose

```yaml
# docker-compose.monitoring.yml

version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin123
    restart: unless-stopped

volumes:
  prometheus_data:
  grafana_data:
```

```yaml
# prometheus.yml

global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node'
    static_configs:
      - targets: ['exporter:9100']

  - job_name: 'docker'
    static_configs:
      - targets: ['cadvisor:8080']
```

### Acceder a Herramientas

```
Prometheus: http://tu-servidor:9090
Grafana: http://tu-servidor:3001
```

---

## 4.5 Monitoreo de Aplicación

### Logs de Serverpod

```bash
# Ver todos los logs
docker compose logs serverpod

# Filtrar errores
docker compose logs serverpod | grep ERROR

# Ver requests recientes
docker logs serverpod --tail 200 | grep "POST\|GET"
```

### Ver Estado de Endpoints

```bash
# Probar endpoint
curl http://localhost:8080/api/status

# Ver respuesta JSON
curl -v http://localhost:8080/api/status | jq

# Monitorear respuesta
watch -n 5 'curl -s http://localhost:8080/api/status'
```

### Ver Base de Datos

```bash
# Conectar a PostgreSQL
docker exec -it postgres psql -U postgres

# Ver conexiones activas
SELECT count(*) FROM pg_stat_activity;

# Ver consultas lentas
SELECT query, calls, mean_time 
FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

# Ver tamaño de tablas
SELECT relname, pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

---

## 4.6 Alertas

### Configurar Alertas en Prometheus

```yaml
# prometheus.yml - agregar alerting

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

rule_files:
  - 'alerts.yml'
```

```yaml
# alerts.yml

groups:
  - name: alertas_servidor
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "CPU usage is above 80%"
          
      - alert: HighMemoryUsage
        expr: (node_memory_MemAvailable / node_memory_MemTotal) * 100 < 20
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Memory usage is above 80%"
          
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"}) * 100 < 10
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Disk space is below 10%"
```

### Notificaciones (Slack/Discord)

```yaml
# alertmanager.yml

route:
  receiver: 'slack-notifications'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: 'TU_WEBHOOK_SLACK'
        channel: '#alerts'
        send_resolved: true
```

---

## 4.7 Dokploy - Monitoreo Integrado

### Ver Recursos en Dokploy

```
Dokploy Dashboard → Server → Resources

Muestra:
- CPU Usage (gráfico)
- Memory Usage (gráfico)
- Disk Usage
- Network I/O
```

### Ver Logs en Dokploy

```
Dokploy Dashboard → Aplicación → Logs

- Logs en tiempo real
- Filtrar por nivel (info, warn, error)
- Buscar en logs
- Descargar logs
```

### Ver Deployments

```
Dokploy Dashboard → Aplicación → Deployments

- Historial de despliegues
- Estado de cada deploy
- Tiempo de deploy
- Rollback disponible
```

---

## 4.8 Alertas con Uptime Robot

### Configurar Monitoreo Externo

```
1. Registrarse en https://uptimerobot.com/
2. Agregar monitor:
   - Type: HTTP(s)
   - URL: https://tu-dominio.com
   - Interval: cada 5 minutos
3. Configurar alertas:
   - Email
   - SMS
   - Slack webhook
```

---

## 4.9 Panel de Monitoreo Completo

### Dashboard de Ejemplo

```
╔═══════════════════════════════════════════════════════════════╗
║                     MONITOREO DASHBOARD                         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                ║
║  CPU: ████████░░░░░░░░░░░░  78%     RAM: ████████░░░░  82%   ║
║                                                                ║
║  DISCO: ██████░░░░░░░░░░░░░░  62%     RED: 125 MB/s           ║
║                                                                ║
╠═══════════════════════════════════════════════════════════════╣
║  SERVICIOS                                                     ║
║  ├─ ✓ Serverpod (8080)   Running  Uptime: 15d 2h             ║
║  ├─ ✓ PostgreSQL (5432)  Running  Uptime: 15d 2h             ║
║  ├─ ✓ Redis (6379)       Running  Uptime: 15d 2h             ║
║  └─ ✓ n8n (5678)         Running  Uptime: 15d 2h             ║
║                                                                ║
╠═══════════════════════════════════════════════════════════════╣
║  ÚLTIMOS ERRORES (últimas 24h)                                ║
║  └─ 15:32 - API: Timeout en /api/consulta_lenta               ║
║  └─ 09:15 - Auth: Intento de login fallido (user: admin)      ║
║                                                                ║
╠═══════════════════════════════════════════════════════════════╣
║  ALERTAS ACTIVAS                                               ║
║  └─ ⚠️ Alta utilización de CPU (>80%)                         ║
║                                                                ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 4.10 Ejercicios Prácticos

### Ejercicio 1: Ver Recursos

```bash
# Desde tu servidor
htop
# Ver CPU y memoria

df -h
# Ver disco

ss -tuln
# Ver puertos activos
```

### Ejercicio 2: Ver Logs

```bash
# Logs de Docker
docker compose logs --tail 50

# Ver errores
docker compose logs | grep -i error

# Ver requests específicos
docker compose logs | grep "POST /api"
```

### Ejercicio 3: Configurar Alerta

```bash
# Crear script de alertas básico
cat > ~/check_resources.sh << 'EOF'
#!/bin/bash

# Verificar CPU
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
if (( $(echo "$CPU > 80" | bc -l) )); then
  echo "ALERTA: CPU al $CPU%"
  # Aquí enviar notificación
fi

# Verificar disco
DISK=$(df -h / | tail -1 | awk '{print $5}' | cut -d'%' -f1)
if [ "$DISK" -gt 80 ]; then
  echo "ALERTA: Disco al $DISK%"
fi
EOF

chmod +x ~/check_resources.sh
```

---

## 4.11 Checklist de Monitoreo

```
✓ Ver recursos (CPU, RAM, disco) diario
✓ Revisar logs de errores
✓ Verificar servicios activos
✓ Monitorear uptime (externo)
✓ Configurar alertas
✓ Revisar rendimiento de DB
✓ Verificar certificados SSL
✓ Backups funcionando
```

---

## 4.12 Recursos Adicionales

### Herramientas de Monitoreo

```
- htop: Monitor de procesos
- Glances: Monitor todo-en-uno
- Netdata: Tiempo real
- Prometheus + Grafana: Enterprise
- UptimeRobot: Monitoreo externo
- Datadog: Cloud (de pago)
```

### Links Útiles

```
- https://htop.dev/
- https://grafana.com/
- https://prometheus.io/
- https://uptimerobot.com/
```

---

## Resumen

En esta guía has aprendido:

- ✅ Monitorear recursos del servidor (CPU, RAM, disco)
- ✅ Ver logs de aplicaciones
- ✅ Configurar Prometheus + Grafana
- ✅ Configurar alertas
- ✅ Usar herramientas de Dokploy
- ✅ Configurar monitoreo externo

**Fin del Módulo 6** - ¡Completaste toda la ruta de aprendizaje!

---

## 🎉 Felicitaciones

Has completado el programa completo de Backend e Infraestructura. Ahora tienes:

```
╔══════════════════════════════════════════════════════════════════╗
║                    TU STACK COMPLETO                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  🎯 FRONTEND:          Tu App Flutter                           ║
║  ↕                                                                 ║
║  🔄 BACKEND:           Serverpod (Dart RPC)                      ║
║  ↕                                                                 ║
║  💾 DATABASE:          PostgreSQL                                ║
║  ⚡ CACHE:             Redis                                      ║
║  📦 STORAGE:           Supabase/S3                               ║
║  🔔 REALTIME:          Supabase                                  ║
║  ⚙️ ORQUESTACIÓN:      Docker + Dokploy                           ║
║  🔒 AUTENTICACIÓN:     Serverpod Auth                            ║
║  📊 ERP:               Odoo                                      ║
║  ⚡ AUTOMATIZACIÓN:    n8n                                       ║
║  🚀 CI/CD:             GitHub Actions + Dokploy                  ║
║  🌐 DNS:               Pi-hole/DNSMasq                           ║
║  🔍 MONITOREO:         htop, Grafana                             ║
║  ☁️ VPS:               Hetzner                                   ║
║  🔒 SEGURIDAD:         UFW, Fail2Ban, SSH keys                  ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                    ¡LISTO PARA PRODUCCIÓN!                       ║
╚══════════════════════════════════════════════════════════════════╝
```

### Próximos Pasos

1. **Practica**: Implementa tu propio proyecto
2. **Experimenta**: Prueba características avanzadas
3. **Comparte**: Ayuda a otros desarrolladores
4. **Aprende**: Mantente actualizado con nuevas versiones

¡Mucho éxito en tu camino como desarrollador full-stack!