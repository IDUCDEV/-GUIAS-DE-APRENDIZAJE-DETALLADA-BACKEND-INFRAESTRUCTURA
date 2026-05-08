# Módulo 2: Docker y Dokploy (La Orquestación)

## 1. Fundamentos de Docker

### Objetivos de Aprendizaje

- Comprender qué es Docker y cómo funciona
- Manejar imágenes y contenedores
- Usar volúmenes para persistencia de datos
- Configurar redes entre contenedores

---

## 1.1 ¿Qué es Docker?

### Conceptos Fundamentales

Docker es una plataforma para desarrollar, enviar y ejecutar aplicaciones en contenedores. Un contenedor es como una máquina virtual ligera que incluye todo lo necesario para ejecutar una aplicación: código, runtime, librerías y configuraciones.

### Diferencia con Máquinas Virtuales

```
┌─────────────────────────────────────────────────────────────┐
│                    MÁQUINA VIRTUAL                          │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐                        │
│ │  App 1  │ │  App 2  │ │  App 3  │                        │
│ ├─────────┤ ├─────────┤ ├─────────┤                        │
│ │   OS    │ │   OS    │ │   OS    │  ← Cada VM tiene su  │
│ ├─────────┤ ├─────────┤ ├─────────┤    propio sistema      │
│ │ Hypervisor (VMware, VirtualBox) │    operativo          │
│ └──────────────────────────────────┘                       │
│              Hardware Físico                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      DOCKER                                  │
│ ┌─────────┐ ┌─────────┐ ┌─────────┐                        │
│ │  App 1  │ │  App 2  │ │  App 3  │                        │
│ ├─────────┤ ├─────────┤ ├─────────┤                        │
│ │  Libs   │ │  Libs   │ │  Libs   │  ← Comparten el      │
│ └─────────┘ └─────────┘ └─────────┘    mismo kernel       │
│          ┌────────────────────┐                             │
│          │   Docker Engine    │                             │
│          └────────────────────┘                             │
│              Hardware Físico                                │
└─────────────────────────────────────────────────────────────┘
```

### Instalación de Docker

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependencias
sudo apt install -y ca-certificates curl gnupg lsb-release

# Añadir clave GPG de Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Añadir repositorio
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verificar instalación
docker --version
docker compose version

# Añadir usuario al grupo docker (evitar sudo cada vez)
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar
```

---

## 1.2 Imágenes de Docker

### ¿Qué es una Imagen?

Una imagen es una plantilla inmutable que contiene el sistema de archivos y las instrucciones para crear un contenedor. Es como un "snapshot" de una máquina lista para usar.

### Comandos Básicos con Imágenes

```bash
# Buscar imágenes en Docker Hub
docker search postgres
docker search redis

# Descargar una imagen
docker pull postgres:15
docker pull redis:7-alpine

# Ver imágenes descargadas
docker images
docker image ls

# Etiquetas (tags) de imágenes
# postgres:15         → versión específica
# postgres:latest    → última versión
# postgres:15-alpine → imagen ligera

# Ver detalles de una imagen
docker image inspect postgres:15

# Eliminar imagen
docker rmi postgres:15
docker image prune -a  # eliminar todas sin usar
```

### Dockerfile - Crear Imágenes Personalizadas

```dockerfile
# Ejemplo: Dockerfile para Serverpod
# Usar imagen base de Dart
FROM dart:stable AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY pubspec.yaml ./
RUN dart pub get

# Copiar código fuente
COPY . .

# Compilar el proyecto
RUN dart compile kernel bin/main.dart

# Imagen final (más pequeña)
FROM dart:stable-runtime

WORKDIR /app

# Copiar archivos compilados
COPY --from=builder /app/bin/main.dart /app/
COPY --from=builder /app/.packages /app/
COPY --from=builder /app/.dart_tool /app/

# Exponer puerto
EXPOSE 8080

# Comando de inicio
CMD ["dart", "/app/main.dart"]
```

```bash
# Construir imagen desde Dockerfile
docker build -t mi_servidor:1.0 .

# Construir con cache optimizado
docker build -t mi_servidor:1.0 --build-arg BUILDKIT_INLINE_CACHE=1 .
```

### Capas de Imágenes

```bash
# Ver historial de capas
docker history mi_servidor:1.0
```

---

## 1.3 Contenedores

### Ciclo de Vida de un Contenedor

```
┌─────────────┐
│   CREAR     │  docker create
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   INICIAR   │  docker start
└──────┬──────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│  EJECUTANDO │────►│  DETENER    │  docker stop
└─────────────┘     └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │  ELIMINAR   │  docker rm
                    └─────────────┘
```

### Comandos de Contenedores

```bash
# Crear y ejecutar un contenedor
docker run -d --name mi_postgres postgres:15

# Comandos comunes:
# -d    → detach (en segundo plano)
# -it   → interactivo (terminal)
# --name → nombre personalizado
# -p    → mapear puertos
# -e    → variables de entorno
# -v    → volúmenes
# --rm  → eliminar al terminar

# Ejemplos prácticos
docker run -d --name mi_redis redis:7-alpine
docker run -d --name mi_postgres -e POSTGRES_PASSWORD=secreto -p 5432:5432 postgres:15

# Ver contenedores en ejecución
docker ps

# Ver todos los contenedores (incluidos detenidos)
docker ps -a

# Iniciar/Detener contenedor
docker start mi_postgres
docker stop mi_postgres

# Reiniciar contenedor
docker restart mi_postgres

# Ver logs
docker logs mi_postgres
docker logs -f mi_postgres  # seguimiento en vivo
docker logs --tail 100 mi_postgres

# Ejecutar comando en contenedor activo
docker exec -it mi_postgres bash
docker exec mi_postgres psql -U postgres

# Eliminar contenedor
docker rm mi_postgres
docker rm -f mi_postgres  # forzar eliminación

# Ver información del contenedor
docker inspect mi_postgres
docker stats mi_postgres  # recursos en tiempo real
```

### Variables de Entorno

```bash
# Pasar variables de entorno
docker run -d \
  --name mi_servidor \
  -e DATABASE_URL=postgres://user:pass@host:5432/db \
  -e API_KEY=secreto123 \
  mi_servidor:1.0

# Ver variables de un contenedor
docker inspect mi_servidor | grep -A 20 Env
```

### Puertos y MapEO

```bash
# Mapear puertos
# Formato: host:contenedor
docker run -d -p 8080:8080 -p 8081:8081 mi_servidor:1.0

# Ver puertos mapeados
docker port mi_servidor
```

---

## 1.4 Volúmenes - Persistencia de Datos

### Tipos de Volúmenes

```
┌─────────────────────────────────────────────────────────────┐
│                    VOLÚMENES DE DOCKER                     │
│                                                             │
│  ┌────────────────┐    ┌────────────────┐                 │
│  │ Named Volumes │    │ Bind Mounts    │                 │
│  │ (Docker gère)  │    │ (Host locale)  │                 │
│  └───────┬────────┘    └───────┬────────┘                 │
│          │                      │                          │
│          ▼                      ▼                          │
│   /var/lib/docker/        /home/ubuntu/data               │
│   (persisten solos)       (directorio específico)        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Named Volumes (Recomendado para Bases de Datos)

```bash
# Crear volumen
docker volume create mi_postgres_data

# Ver volúmenes
docker volume ls
docker volume ls -f name=postgres

# Información del volumen
docker volume inspect mi_postgres_data

# Usar volumen en contenedor
docker run -d \
  --name mi_postgres \
  -e POSTGRES_PASSWORD=secreto \
  -v mi_postgres_data:/var/lib/postgresql/data \
  postgres:15

# Eliminar volumen (contenedor detenido primero)
docker rm mi_postgres
docker volume rm mi_postgres_data

# Limpiar volúmenes sin usar
docker volume prune
```

### Bind Mounts (Para Archivos de Configuración)

```bash
# Montar directorio del host
docker run -d \
  --name mi_servidor \
  -v /home/ubuntu/config:/app/config \
  -v /home/ubuntu/logs:/app/logs \
  mi_servidor:1.0

# Bind mount de solo lectura
docker run -d \
  --name mi_servidor \
  -v /home/ubuntu/config:/app/config:ro \
  mi_servidor:1.0
```

### Volúmenes con Serverpod

```bash
# Ejemplo: Serverpod con volúmenes
docker run -d \
  --name serverpod \
  -p 8080:8080 \
  -p 8081:8081 \
  -v serverpod_data:/app/data \
  -v /home/ubuntu/serverpod/packages:/app/packages \
  -e SERVERPOD_KEY=mi_key_secreta \
  serverpod:latest
```

---

## 1.5 Redes de Docker

### Tipos de Redes

| Driver | Descripción | Uso |
|--------|-------------|-----|
| bridge | Red por defecto | Contenedores aislados |
| host | Mismo espacio de red que el host | Desarrollo |
| overlay | Múltiples servidores Docker | Swarm |
| none | Sin red | Tareas específicas |

### Redes Personalizadas

```bash
# Crear red
docker network create mi_red

# Ver redes
docker network ls

# Información de red
docker network inspect mi_red

# Conectar contenedor a red
docker network connect mi_red mi_postgres

# Desconectar
docker network disconnect mi_red mi_postgres

# Eliminar red
docker network rm mi_red
```

### Comunicación entre Contenedores

```bash
# Ambos contenedores en la misma red se comunican por nombre
docker network create mi_app_network

# Contenedor 1: Base de datos
docker run -d \
  --name postgres_db \
  --network mi_app_network \
  -e POSTGRES_PASSWORD=secreto \
  postgres:15

# Contenedor 2: Aplicación
docker run -d \
  --name mi_app \
  --network mi_app_network \
  -e DATABASE_URL=postgres://postgres:secreto@postgres_db:5432/mi_db \
  mi_app:1.0

# Desde mi_app, puedo acceder a postgres_db por su nombre
# La URL de conexión es: postgres_db:5432
```

### DNS Automático

```bash
# Docker proporciona DNS automático
# Todos los contenedores en la misma red pueden resolverse por nombre
ping postgres_db  # funciona desde cualquier contenedor
```

---

## 1.6 Ejercicios Prácticos

### Ejercicio 1: Tu Primer Contenedor

```bash
# Ejecutar un contenedor nginx
docker run -d --name mi_nginx -p 8080:80 nginx:alpine

# Verificar que está corriendo
docker ps

# Probar en navegador
# http://localhost:8080

# Ver logs
docker logs mi_nginx

# Detener y eliminar
docker stop mi_nginx
docker rm mi_nginx
```

### Ejercicio 2: Contenedor con Volumen

```bash
# Crear volumen para datos persistentes
docker volume create mis_datos

# Ejecutar contenedor con volumen
docker run -d --name redis_persistente \
  -v mis_datos:/data \
  redis:alpine

# Escribir datos
docker exec -it redis_persistente redis-cli SET clave "valor"

# Eliminar contenedor
docker rm -f redis_persistente

# Crear nuevo contenedor con el mismo volumen
docker run -d --name redis_persistente2 \
  -v mis_datos:/data \
  redis:alpine

# Verificar que los datos persisten
docker exec -it redis_persistente2 redis-cli GET clave
```

### Ejercicio 3: Red Personalizada

```bash
# Crear red
docker network create app_network

# Crear servicios
docker run -d --name db --network app_network \
  -e POSTGRES_PASSWORD=pass postgres:15

docker run -d --name app --network app_network \
  -e DB_HOST=db mi_app:1.0

# Ver comunicación
docker exec -it app ping -c 3 db

# Ver red
docker network inspect app_network
```

---

## 1.7 Aplicación con Flutter + Serverpod

### Estructura de Contenedores

```
┌─────────────────────────────────────────────────────────────┐
│                    DOCKER EN SERVIDOR                        │
│                                                             │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   Serverpod     │  │   PostgreSQL    │                 │
│  │   Puerto: 8080  │◄─►│   Puerto: 5432  │                 │
│  │   Red: app_net  │  │   Red: app_net  │                 │
│  └─────────────────┘  └─────────────────┘                 │
│           │                    │                            │
│           │     ┌──────────────┘                           │
│           ▼     ▼                                           │
│  ┌─────────────────┐  ┌─────────────────┐                 │
│  │   Redis         │  │   Watchtower    │                 │
│  │   Puerto: 6379  │  │   (actualizac.) │                 │
│  │   Red: app_net  │  │                 │                 │
│  └─────────────────┘  └─────────────────┘                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Comandos para Serverpod

```bash
# Ver todos los servicios de Serverpod
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Ver recursos
docker stats --no-stream

# Ver logs de todos los servicios
docker compose logs -f

# Reiniciar solo un servicio
docker compose restart serverpod
docker compose restart postgres
```

---

## 1.8 Recursos Adicionales

### Comandos Docker Esenciales

```bash
# Imágenes
docker pull, images, rmi, build

# Contenedores
docker run, ps, start, stop, rm, logs, exec, inspect

# Volúmenes
docker volume create, ls, inspect, rm, prune

# Redes
docker network create, ls, inspect, rm, connect

# Sistema
docker system df, system prune, system info
```

### Recomendaciones de Seguridad

```bash
# 1. No usar imágenes latest en producción
# 2. No exponer puertos sensibles al exterior
# 3. Usar usuarios no-root dentro del contenedor
# 4. Escanear imágenes en busca de vulnerabilidades
# 5. Mantener Docker actualizado
```

### Docker para Flutter Developers

```
┌─────────────────────────────────────────────────────────┐
│              FLUTTER + SERVERPOD EN DOCKER               │
│                                                         │
│  Tu Laptop              Servidor Ubuntu                 │
│  ┌─────────┐           ┌─────────────────────────┐     │
│  │ Flutter │───HTTP───►│ Docker                  │     │
│  │   App   │           │ ├─ Serverpod (8080)    │     │
│  └─────────┘           │ ├─ Postgres (5432)     │     │
│                        │ └─ Redis (6379)        │     │
│                        └─────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué es Docker y cómo funciona
- ✅ Manejar imágenes (pull, build, ls, inspect)
- ✅ Ciclo de vida de contenedores (run, start, stop, rm)
- ✅ Usar volúmenes para persistencia de datos
- ✅ Configurar redes entre contenedores

**Siguiente guía:** Docker Compose - Orquestación de múltiples servicios.