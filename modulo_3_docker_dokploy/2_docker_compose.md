# Módulo 2: Docker y Dokploy (La Orquestación)

## 2. Docker Compose

### Objetivos de Aprendizaje

- Comprender la sintaxis YAML para Docker Compose
- Orquestar múltiples servicios (DB + App) con un solo comando
- Manejar redes, volúmenes y variables de entorno
- Implementar desarrollo local con Docker Compose

---

## 2.1 ¿Qué es Docker Compose?

### Concepto

Docker Compose es una herramienta para definir y ejecutar aplicaciones multi-contenedor. Con un solo archivo `docker-compose.yml`, puedes configurar todos los servicios de tu aplicación.

### Beneficios

- **Declarativo**: Defines el estado deseado, Docker lo ejecuta
- **Reproducible**: Mismo setup en cualquier máquina
- **Simple**: Un comando para levantar toda la aplicación
- **Persistente**: Configuración versionable

---

## 2.2 Sintaxis YAML para Docker Compose

### Estructura Básica

```yaml
version: '3.8'  # Versión de Docker Compose

services:       # Definición de servicios
  nombre_servicio:
    image: imagen:version    # o build:
    container_name: mi_contenedor
    ports:
      - "host:contenedor"
    environment:
      - VARIABLE=valor
    volumes:
      - volumen:directorio
    networks:
      - red_nombre
    depends_on:
      - otro_servicio
    restart: unless-stopped

volumes:         # Definición de volúmenes
  nombre_volumen:

networks:        # Definición de redes
  nombre_red:
    driver: bridge
```

### Tipos de Datos en YAML

```yaml
# Strings (comillas opcionales para espacios)
service_name: mi_servicio
version: "3.8"

# Números
port: 8080

# Booleanos
enabled: true

# Listas (con guión)
ports:
  - "8080:8080"
  - "5432:5432"

# Diccionarios (clave: valor)
environment:
  DATABASE_URL: postgres://user:pass@db:5432/mydb
  API_KEY: "${API_KEY}"  # variável de entorno

# Anidación
services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
```

---

## 2.3 Ejemplo Completo: Serverpod

### docker-compose.yml para Serverpod

```yaml
version: '3.8'

services:
  serverpod:
    image: serverpod/serverpod:latest
    container_name: serverpod
    ports:
      - "8080:8080"
      - "8081:8081"
    environment:
      - SERVERPOD_KEY=mi_key_secreta_de_desarrollo
      - DATABASE_HOST=postgres
      - DATABASE_PORT=5432
      - DATABASE_USER=postgres
      - DATABASE_PASSWORD=secreto123
      - DATABASE_NAME=serverpod
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    volumes:
      - ./packages:/packages
      - serverpod_data:/app/data
    depends_on:
      - postgres
      - redis
    networks:
      - app_network
    restart: unless-stopped

  postgres:
    image: postgres:15-alpine
    container_name: postgres
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=secreto123
      - POSTGRES_DB=serverpod
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app_network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    networks:
      - app_network
    restart: unless-stopped

volumes:
  serverpod_data:
  postgres_data:
  redis_data:

networks:
  app_network:
    driver: bridge
```

### Variables de Entorno con .env

```bash
# Crear archivo .env
cat > .env << 'EOF'
# Serverpod
SERVERPOD_KEY=mi_key_secreta_de_desarrollo

# PostgreSQL
POSTGRES_PASSWORD=secreto123

# Redis (opcional)
# REDIS_PASSWORD=redis_pass
EOF
```

```yaml
# docker-compose.yml actualizado
services:
  serverpod:
    environment:
      - SERVERPOD_KEY=${SERVERPOD_KEY}
      - DATABASE_PASSWORD=${POSTGRES_PASSWORD}
```

---

## 2.4 Comandos de Docker Compose

### Comandos Esenciales

```bash
# Levantar todos los servicios
docker compose up
docker compose up -d           # detach (segundo plano)

# Ver servicios en ejecución
docker compose ps
docker compose ps -a           # incluyendo detenidos

# Detener servicios
docker compose stop
docker compose down            # stop + elimina contenedores

# Ver logs
docker compose logs
docker compose logs -f         # seguimiento en vivo
docker compose logs app        # solo un servicio
docker compose logs --tail 50 # últimas 50 líneas

# Ejecutar comando en servicio
docker compose exec serverpod bash
docker compose exec postgres psql -U postgres

# Reconstruir servicios (sin cache)
docker compose build --no-cache
docker compose up -d --build

# Escalar servicios (solo con swarm)
docker compose up -d --scale app=3
```

### Comandos de Mantenimiento

```bash
# Ver recursos
docker compose top

# Ver configuración (sin ejecutar)
docker compose config

# Listar imágenes usadas
docker compose images

# Pausar servicios
docker compose pause

# Reanudar servicios
docker compose unpause

# Reiniciar servicios
docker compose restart
docker compose restart serverpod
```

---

## 2.5 Desarrollo Local con Docker Compose

### Flujo de Trabajo Completo

```bash
# 1. Crear directorio del proyecto
mkdir ~/mi_serverpod && cd ~/mi_serverpod

# 2. Crear archivos necesarios
touch docker-compose.yml .env

# 3. Editar docker-compose.yml (ver ejemplo anterior)

# 4. Editar .env con tus valores

# 5. Levantar servicios
docker compose up -d

# 6. Ver estado
docker compose ps

# 7. Ver logs
docker compose logs -f serverpod

# 8. Probar endpoint
curl http://localhost:8080/api/status

# 9. Detener todo
docker compose down
```

### Acceso a Servicios desde Flutter

```dart
// tu_app/lib/main.dart
import 'package:serverpod_client/serverpod_client.dart';

void main() {
  final client = ServerpodClient(
    // En desarrollo: IP de tu servidor Docker
    // En producción: tu dominio
    uri: Uri.parse('http://192.168.1.100:8080'),
    authenticationKey: 'mi_key_secreta_de_desarrollo',
  );
}
```

### Hot Reload con Volúmenes

```yaml
# docker-compose.yml para desarrollo
services:
  serverpod:
    volumes:
      - ./packages:/packages  # Código fuente
      - serverpod_data:/app/data
    environment:
      - SERVERPOD_MODE=development

# Cambios en ./packages se reflejan automáticamente
# No necesitas reconstruir la imagen
```

---

## 2.6 Redes en Docker Compose

### Red Por Defecto

```yaml
# Todos los servicios en la misma red se comunican por nombre
services:
  app:
    image: mi_app
    # automáticamente en red default

  postgres:
    image: postgres:15
    # puede ser alcanzado como "postgres" desde "app"
```

### Redes Personalizadas

```yaml
version: '3.8'

services:
  app:
    networks:
      - frontend
      - backend

  postgres:
    networks:
      - backend

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
```

### Acceso a Red del Host

```yaml
# Para desarrollo, acceder a servicios del host
services:
  app:
    network_mode: "host"
    # Accede a localhost:5432 de tu máquina
```

---

## 2.7 Volúmenes en Docker Compose

### Volúmenes Named

```yaml
volumes:
  postgres_data:    # Se crea automáticamente
  redis_data:

services:
  postgres:
    volumes:
      - postgres_data:/var/lib/postgresql/data
```

### Bind Mounts

```yaml
services:
  app:
    volumes:
      - ./config:/app/config       # relativo al directorio
      - /home/ubuntu/data:/app/data  # absoluto

  # Solo lectura
  config:
    volumes:
      - ./config:/app/config:ro
```

### Volúmenes para Datos Sensibles

```yaml
# No incluir secretos en docker-compose.yml
services:
  app:
    env_file:
      - .env.secrets  # fuera del control de versiones
```

---

## 2.8 Override para Desarrollo

### docker-compose.override.yml

```yaml
# Este archivo se combina automáticamente con docker-compose.yml
# Útil para desarrollo local sin modificar el archivo principal

services:
  serverpod:
    environment:
      - DEBUG=true
    ports:
      - "8080:8080"
      - "8081:8081"
    volumes:
      - ./packages:/packages
    command: dart run bin/main.dart --mode development
```

```bash
# Docker Compose combina automáticamente:
# docker-compose.yml + docker-compose.override.yml

# Para usar solo el archivo base
docker compose -f docker-compose.yml up
```

---

## 2.9 Ejercicios Prácticos

### Ejercicio 1: Levantar Stack Completo

```bash
# Crear archivo docker-compose.yml para desarrollo
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=dev
      - POSTGRES_PASSWORD=dev123
      - POSTGRES_DB=app_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_dev:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_dev:/data

volumes:
  postgres_dev:
  redis_dev:
EOF

# Levantar
docker compose up -d

# Probar conectividad
docker compose exec postgres pg_isready
docker compose exec redis redis-cli ping

# Detener
docker compose down
```

### Ejercicio 2: Completar con Serverpod

```bash
# Ampliar el docker-compose.yml anterior
# Agregar servicio serverpod con depends_on

# Probar acceso desde Flutter
# curl http://localhost:8080/api/status
```

### Ejercicio 3: Desarrollar con Hot Reload

```yaml
# Agregar volumen de código fuente
services:
  serverpod:
    volumes:
      - ./packages:/packages
    environment:
      - SERVERPOD_MODE=development
```

```bash
# Al hacer cambios en ./packages:
# Se reflejan automáticamente sin reconstruir

# Forzar recarga
docker compose restart serverpod
```

---

## 2.10 Configuración para Flutter + Serverpod

### Estructura de Proyecto

```
mi_proyecto/
├── docker-compose.yml      # Configuración de servicios
├── .env                    # Variables sensibles
├── packages/
│   ├── server/
│   │   ├── lib/
│   │   └── docker/
│   │       └── Dockerfile
│   └── client/             # Cliente generado
└── flutter_app/            # Tu app Flutter
```

### Scripts de Utilidad

```bash
#!/bin/bash
# start_dev.sh

# Cargar variables
export $(cat .env | grep -v '^#' | xargs)

# Levantar servicios
docker compose up -d

# Esperar a que postgres esté listo
echo "Esperando a PostgreSQL..."
sleep 5

# Verificar estado
docker compose ps
echo "Servicios iniciados:"
echo " - Serverpod: http://localhost:8080"
echo " - PostgreSQL: localhost:5432"
echo " - Redis: localhost:6379"
```

```bash
#!/bin/bash
# stop_dev.sh

docker compose down
echo "Servicios detenidos"
```

---

## 2.11 Recursos Adicionales

### Comandos Docker Compose Resumen

```bash
# Inicio/Detención
up, down, start, stop, restart

# Logs y Ejecución
logs, exec, top

# Construcción
build, pull, push

# Estado
ps, images, config
```

### Ejemplo Avanzado: Stack Completo con UI

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: app
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data

  serverpod:
    image: serverpod/serverpod:latest
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_started
    environment:
      - SERVERPOD_KEY=${SERVERPOD_KEY}
      - DATABASE_HOST=postgres
    volumes:
      - ./packages:/packages

  watchtower:
    image: containrrr/watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - WATCHTOWER_SCHEDULE=0 0 4 * * *
      - WATCHTOWER_INCLUDE_STOPPED=true

volumes:
  postgres_data:
  redis_data:
```

---

## Resumen

En esta guía has aprendido:

- ✅ Sintaxis básica de YAML para Docker Compose
- ✅ Estructurar servicios, volúmenes y redes
- ✅ Comandos esenciales (up, down, logs, exec)
- ✅ Configurar desarrollo local con hot reload
- ✅ Manejar variables de entorno con .env

**Siguiente guía:** Dokploy - Tu Panel de Control para gestión de contenedores.