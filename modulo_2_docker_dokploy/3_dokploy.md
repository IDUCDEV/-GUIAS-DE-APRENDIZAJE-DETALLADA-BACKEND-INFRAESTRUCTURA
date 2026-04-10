# Módulo 2: Docker y Dokploy (La Orquestación)

## 3. Dokploy - Tu Panel de Control

### Objetivos de Aprendizaje

- Instalar Dokploy en Ubuntu Server
- Gestionar aplicaciones desde el dashboard
- Configurar bases de datos con un clic
- Configurar certificados SSL con Let's Encrypt

---

## 3.1 ¿Qué es Dokploy?

### Concepto

Dokploy es un panel de administración autoalojado para Docker. Inspirado en Coolify y Portainer, te permite gestionar aplicaciones, bases de datos y certificados SSL desde una interfaz web intuitiva.

### Características Principales

- ✅ Desplegar aplicaciones desde GitHub/GitLab
- ✅ Gestión de bases de datos (PostgreSQL, MySQL, Redis, MongoDB)
- ✅ Certificados SSL automáticos con Let's Encrypt
- ✅ Backups automáticos
- ✅ Monitorización de recursos
- ✅ Despliegue con un clic

---

## 3.2 Instalación de Dokploy

### Requisitos del Sistema

```
- Ubuntu 22.04 LTS o 24.04 LTS
- 4 GB RAM mínimo (8 GB recomendado)
- 2 CPUs
- 20 GB almacenamiento
- Docker instalado
- Dominio (opcional para desarrollo local)
```

### Instalación Automática

```bash
# Conectar a tu servidor
ssh ubuntu@192.168.1.100

# Ejecutar script de instalación
curl -sSL https://dokploy.com/install.sh | sh

# Durante la instalación, te preguntará:
# - Dominio (puedes usar tu IP temporalmente)
# - Email para certificados
# - Contraseña de admin

# Output esperado:
# 🎉 Dokploy instalado exitosamente!
# Dashboard: http://tu-ip-o-dominio:3000
```

### Configuración Post-Instalación

```bash
# Ver estado del servicio
sudo systemctl status dokploy

# Ver logs
sudo docker logs dokploy -f

# Reiniciar
sudo systemctl restart dokploy
```

### Acceso al Dashboard

```
URL: http://192.168.100:3000  (o tu dominio)
Usuario: admin
Contraseña: La que configuraste durante instalación
```

---

## 3.3 Interfaz de Dokploy

### Estructura del Dashboard

```
┌─────────────────────────────────────────────────────────────┐
│  DOKPLOY                    [Admin] [Settings] [Logout]    │
├─────────────┬───────────────────────────────────────────────┤
│             │                                               │
│ Dashboard   │   Contenido Principal                        │
│ ──────────  │                                               │
│ Projects    │   [Cards de proyectos/recursos]               │
│ ──────────  │                                               │
│ Servers     │                                               │
│ ──────────  │                                               │
│ Databases   │                                               │
│ ──────────  │                                               │
│ SSL Certs   │                                               │
│ ──────────  │                                               │
│ Backups     │                                               │
│             │                                               │
└─────────────┴───────────────────────────────────────────────┘
```

### Primeros Pasos

1. **Crear un Proyecto**: Organiza tus aplicaciones
2. **Agregar Aplicación**: Desde Git o imagen Docker
3. **Configurar Base de Datos**: PostgreSQL, Redis, etc.
4. **Configurar Dominio**: Asignar subdomain y SSL

---

## 3.4 Gestión de Aplicaciones

### Crear Aplicación desde Git

```markdown
Pasos en el Dashboard:

1. Projects → Create Project
   - Name: Mi App Flutter
   - Description: Backend para mi app

2. Applications → Create Application
   - Name: serverpod-backend
   - Type: Serverpod (o Docker)
   - Git Provider: GitHub/GitLab
   - Repository: tu-usuario/tu-repo
   - Branch: main
   - Build Command: (dejar por defecto o custom)
   - Start Command: (dejar por defecto)

3. Environment Variables
   - SERVERPOD_KEY: tu-key
   - DATABASE_URL: postgres://...
```

### Configuración de Builds

```yaml
# Dokploy detectará automáticamente:
# - Dockerfile
# - docker-compose.yml
# - Buildpacks (Heroku-style)

# Puedes personalizar:
# - Build Command
# - Start Command
# - Port (default: 3000)
```

### Variables de Entorno en Dokploy

```
En el dashboard:
Application → Environment Variables

DATABASE_URL=postgres://user:pass@host:5432/db
REDIS_HOST=redis
SERVERPOD_KEY=${SERVERPOD_KEY}

# Secretos sensibles
# Dokploy los almacena de forma segura
```

---

## 3.5 Gestión de Bases de Datos

### Crear Base de Datos

```
Dashboard → Databases → Create Database

Opciones:
- Type: PostgreSQL, MySQL, MariaDB, Redis, MongoDB
- Name: mi_app_db
- Version: 15 (para PostgreSQL)
- Root User: postgres
- Root Password: (generado automáticamente)

# Dokploy crea el contenedor y configura:
# - Usuario de la base
# - Base de datos
# - Volumen persistente
```

### Conectar Serverpod a PostgreSQL

```bash
# En Dokploy, ver la configuración de conexión:
# Database → Connection Details

# typically:
# Host: postgres
# Port: 5432
# User: app_user
# Password: (ver en Dokploy)
# Database: app_db
```

### PostgreSQL en Dokploy

```yaml
# Dokploy crea automáticamente:
services:
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=app_user
      - POSTGRES_PASSWORD=generated_pass
      - POSTGRES_DB=app_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Redis en Dokploy

```
Dashboard → Databases → Create
- Type: Redis
- Version: 7-alpine

# Para Serverpod, configurar:
REDIS_HOST=redis
REDIS_PORT=6379
```

---

## 3.6 Configuración de Dominios y SSL

### Agregar Dominio

```
Application → Domains → Add Domain

1. Domain: api.tudominio.com (o sub.dominio.com)
2. HTTPS: Enable (Let's Encrypt)
3. SSL Certificate: Auto-generate

# Dokploy configurará automáticamente:
# - Nginx reverse proxy
# - Certbot para SSL
# - Renovación automática
```

### Configuración para Desarrollo Local

```bash
# Sin dominio, usar IP directamente:

# Application → Domains
# Agregar: 192.168.1.100 (sin HTTPS)

# O usar nip.io para DNS dinámico:
# api.192.168.1.100.nip.io

# Acceso: http://api.192.168.1.100.nip.io:8080
```

### Certificados SSL

```
Dokploy maneja automáticamente:
- Generación con Let's Encrypt
- Renovación antes de vencer
- Redirect HTTP → HTTPS

Ver certificados:
Dashboard → SSL Certificates

# Ver detalles:
- Proveedor: Let's Encrypt
- Expira: 2025-03-15 (90 días)
- Renovación: Automática
```

---

## 3.7 Despliegue Continuo (CI/CD)

### Configurar Webhook

```
Application → Deployments

Dokploy crea automáticamente:
- Webhook URL: https://dokploy.com/api/webhook/xxx

# En GitHub:
# Settings → Webhooks → Add webhook
# URL: La proporcionada por Dokploy
# Events: Push, Branch created
```

### Desplegar desde Git

```
1. Haz push a tu repositorio
2. Dokploy detecta el cambio (vía webhook)
3. Build automática:
   - Pull del código
   - Build de la imagen
   - Reemplazo del contenedor
4. Health check
5. Listo!

# Tiempo típico: 1-3 minutos
```

### Rollback

```
Application → Deployments → Previous deployments

Puedes revertir a cualquier despliegue anterior
con un clic
```

---

## 3.8 Backups Automáticos

### Configurar Backups

```
Dashboard → Backups → Create Backup

Opciones:
- Source: Database o Volume
- Frequency: Daily / Weekly / Monthly
- Retention: 7 / 14 / 30 días
- Destination: Local / S3 / Google Cloud / Backblaze

# Recomendado:
# - Frecuencia: Daily
# - Retención: 7 días
# - Destino: S3 (min.io) o Backblaze
```

### Restaurar Backup

```
Dashboard → Backups → Select backup → Restore

# Importante:
# - Detener aplicación antes de restaurar
# - Verificar integridad del backup
```

---

## 3.9 Monitorización

### Ver Recursos

```
Dashboard → Servers → tu-servidor

Muestra:
- CPU Usage
- Memory Usage
- Disk Usage
- Network I/O
```

### Logs de Aplicación

```
Application → Logs

# Ver logs en tiempo real
# Filtrar por nivel: Info, Warning, Error
# Descargar logs
```

### Health Checks

```
Application → Health Check

Dokploy verifica que:
- El contenedor esté corriendo
- El puerto respondan
- (Opcional) Endpoint de salud

# Si falla, reinicia automáticamente
```

---

## 3.10 Ejercicios Prácticos

### Ejercicio 1: Instalar Dokploy

```bash
# En tu servidor Ubuntu
ssh ubuntu@192.168.1.100

# Instalar
curl -sSL https://dokploy.com/install.sh | sh

# Acceder al dashboard
# http://tu-ip:3000
```

### Ejercicio 2: Crear Aplicación Serverpod

```bash
# En el dashboard:
1. Project → Create "Mi Proyecto"
2. Application → Create
   - Type: Docker Compose
   - Repository: (tu repo de Serverpod)
3. Environment:
   - SERVERPOD_KEY=desarrollo123
4. Deploy
```

### Ejercicio 3: Base de Datos

```bash
# Dashboard → Databases → Create
- Type: PostgreSQL
- Name: mi_app_db
- Version: 15

# Ver conexión
# Usar en tu aplicación:
# Host: postgres
# Port: 5432
```

---

## 3.11 Configuración para Flutter + Serverpod

### Arquitectura Completa con Dokploy

```
┌─────────────────────────────────────────────────────────────┐
│                     DOKPLOY DASHBOARD                       │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │ Aplicación  │  │  PostgreSQL │  │    Redis    │        │
│  │ Serverpod   │  │    (5432)   │  │   (6379)    │        │
│  │  (8080)     │  │             │  │             │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │
│  ┌──────┴────────────────┴────────────────┴──────┐        │
│  │            Dominio + SSL (Let's Encrypt)      │        │
│  │            api.tudominio.com                  │        │
│  └───────────────────────────────────────────────┘        │
│                           │                                │
│                           ▼                                │
│  ┌─────────────────────────────────────────────────┐      │
│  │           FLUTTER APP                           │      │
│  │           Uri: https://api.tudominio.com        │      │
│  └─────────────────────────────────────────────────┘      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Configuración en Flutter

```dart
// lib/main.dart
import 'package:serverpod_client/serverpod_client.dart';

class Config {
  // Desarrollo local
  static const String devUrl = 'http://192.168.1.100:8080';
  
  // Producción (Dokploy con dominio)
  static const String prodUrl = 'https://api.tudominio.com';
  
  static const String devKey = 'desarrollo123';
  static const String prodKey = 'produccion_key';
}

void main() {
  final client = ServerpodClient(
    uri: Uri.parse(Config.prodUrl),
    authenticationKey: Config.prodKey,
  );
}
```

---

## 3.12 Recursos Adicionales

### Comandos de Dokploy (vía terminal)

```bash
# Ver logs de Dokploy
sudo docker logs dokploy

# Reiniciar Dokploy
sudo systemctl restart dokploy

# Ver aplicaciones
docker ps | grep dokploy

# Actualizar Dokploy
curl -sSL https://dokploy.com/update.sh | sh
```

### Solución de Problemas

```bash
# Si el dashboard no responde
sudo systemctl restart dokploy

# Ver logs de aplicación
docker logs nombre_app -f

# Ver recursos
docker stats

# Redes
docker network ls
```

---

## Resumen

En esta guía has aprendido:

- ✅ Instalar Dokploy en Ubuntu Server
- ✅ Navegar por el dashboard
- ✅ Crear aplicaciones desde Git
- ✅ Gestionar bases de datos (PostgreSQL, Redis)
- ✅ Configurar dominios y SSL automático
- ✅ Configurar CI/CD con webhooks

**Fin del Módulo 2** - Ahora puedes orquestar servicios con Docker y gestionarlos con Dokploy.

**Siguiente:** Módulo 3: Automatización con n8n + OpenClaw.