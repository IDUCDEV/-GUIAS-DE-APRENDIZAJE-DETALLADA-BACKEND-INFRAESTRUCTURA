# Docker y Despliegue a Producción

> Aprende a contenedorizar tu servidor Serverpod y a desplegarlo en producción de forma profesional.

---

## Tabla de Contenidos

1. [Docker en Serverpod](#1-docker-en-serverpod)
2. [Entornos: Dev vs Prod](#2-entornos-dev-vs-prod)
3. [Despliegue con Serverpod Cloud](#3-despliegue-con-serverpod-cloud)
4. [Despliegue Manual (VPS/AWS/GCP)](#4-despliegue-manual)
5. [Consideraciones de Seguridad](#5-consideraciones-de-seguridad)

---

## 1. Docker en Serverpod

### ¿Por qué Docker?

Serverpod viene con Docker configurado por defecto porque garantiza que tu servidor, la base de datos (PostgreSQL) y el caché (Redis) funcionen exactamente igual en tu computadora que en el servidor de producción.

```
    TU APP SERVERPOD
    ═════════════════
    
    ┌──────────────────────────────────────────┐
    │              DOCKER COMPOSE              │
    ├──────────────────┬───────────────────────┤
    │  Server Container │  PostgreSQL Container │
    │    (Dart/Pod)    │     (Base Datos)      │
    ├──────────────────┴───────────────────────┤
    │             Redis Container              │
    │                (Caché)                   │
    └──────────────────────────────────────────┘
```

### Comandos de Docker

| Comando | Uso |
|---------|-----|
| `docker compose up -d` | Levanta DB y Redis en segundo plano |
| `docker compose down` | Detiene y elimina los contenedores |
| `docker compose ps` | Lista los contenedores activos |
| `docker logs -f` | Muestra los logs en tiempo real |

---

## 2. Entornos: Dev vs Prod

### Archivos de Configuración

En `config/` verás varios archivos YAML:
- `development.yaml`: Configuración para tu PC local.
- `staging.yaml`: Configuración para pruebas finales (opcional).
- `production.yaml`: **Configuración real para usuarios finales.**

### Cambiando de Entorno

Para arrancar el servidor en producción:
```bash
serverpod run --mode production
```

### Variables Sensibles (Passwords)

**¡NUNCA subas tus contraseñas reales a Git!** Usa el archivo `config/passwords.yaml` y asegúrate de que esté en tu `.gitignore`.

```yaml
# config/passwords.yaml
database: 'tu_password_segura'
redis: 'tu_password_redis'
jwt: 'tu_secreto_super_seguro'
```

---

## 3. Despliegue con Serverpod Cloud (Recomendado)

Serverpod Cloud es la opción más sencilla para desarrolladores mobile:

1.  **Crea una cuenta** en [serverpod.cloud](https://serverpod.cloud).
2.  **Conecta tu repositorio** de GitHub.
3.  **Configura las variables** de entorno.
4.  **¡Listo!** Serverpod se desplegará automáticamente con cada `git push`.

---

## 4. Despliegue Manual (VPS / AWS / GCP)

Si prefieres tener control total en un VPS (ej. DigitalOcean, Linode):

### Paso 1: Dockerizar el servidor

Serverpod genera un `Dockerfile` por defecto. Úsalo para crear tu imagen:
```bash
docker build -t mi-app-server .
```

### Paso 2: Configurar un Proxy Inverso (Nginx)

Necesitarás Nginx para manejar el tráfico HTTPS y los certificados SSL:
```nginx
server {
    listen 443 ssl;
    server_name api.mi-app.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### Paso 3: Usar CI/CD (GitHub Actions)

Automatiza el despliegue con un script de GitHub Actions que:
1. Haga el build de la imagen Docker.
2. La suba a un registro (Docker Hub/GHCR).
3. Notifique a tu VPS para que actualice el contenedor.

---

## 5. Consideraciones de Seguridad

1.  **SSL/HTTPS**: Obligatorio. Usa Let's Encrypt o Cloudflare.
2.  **Firewall**: Cierra todos los puertos en tu servidor excepto el 80, 443 y el puerto de tu API (si no usas proxy).
3.  **Backups**: Configura backups automáticos de tu base de datos PostgreSQL.
4.  **Logs**: Monitoriza `serverpod_insights` para detectar ataques de fuerza bruta o errores masivos.
5.  **Actualizaciones**: Mantén Docker y las imágenes base de Dart siempre actualizadas.

---

## 🏁 ¡Felicidades!

Has completado el ciclo completo:
- [x] Conceptos de Backend
- [x] Clean Architecture
- [x] Modelos y Base de Datos
- [x] Endpoints y Servicios
- [x] Autenticación y Tiempo Real
- [x] Inyección de Dependencias
- [x] Testing y Calidad
- [x] Tareas Programadas y Archivos
- [x] Despliegue Profesional

**Ahora tienes todas las herramientas para construir backends escalables, seguros y potentes para tus apps Flutter.**
