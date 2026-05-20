# 🚀 Guía Rápida: n8n Autoalojado con Docker + Dokploy (+ Cloudflare Tunnel opcional)

> **Contexto:** Vas por el Módulo 2 (LazyVim) pero necesitas tu servidor n8n ya.
> Esta guía es autocontenida — no necesitas los módulos anteriores.
> Cada paso explica **qué** haces y **por qué**.

---

## Arquitectura Final

### Ahora (sin dominio — solo red local)

```
                   ┌──────────────────────────────────────┐
                   │        TU RED LOCAL (CASA)            │
                   │                                      │
                   │  ┌──────────────────────────────┐    │
                   │  │     TU PC SERVIDOR            │    │
                   │  │   (Ubuntu Server local)       │    │
                   │  │                              │    │
                   │  │  ┌─────────────────────────┐ │    │
                   │  │  │      DOKPLOY (web UI)    │ │    │
                   │  │  │  http://192.168.0.100:3000│ │    │
                   │  │  └─────────────────────────┘ │    │
                   │  │                              │    │
                   │  │  ┌─────────────────────────┐ │    │
                   │  │  │  DOCKER COMPOSE STACK    │ │    │
                   │  │  │                         │ │    │
                   │  │  │  ┌──────┐  ┌─────────┐ │ │    │
                   │  │  │  │ n8n │◄─►│PostgreSQL│ │ │    │
                   │  │  │  │:5678│  │ :5432   │ │ │    │
                   │  │  │  └──────┘  └─────────┘ │ │    │
                   │  │  └─────────────────────────┘ │    │
                   │  └──────────────────────────────┘    │
                   │                                      │
                   │  Desde tu laptop abres:              │
                   │  http://192.168.0.100:5678 ← n8n     │
                   │  http://192.168.0.100:3000 ← Dokploy  │
                   └──────────────────────────────────────┘
```

### Ahora (con dominio — Cloudflare Tunnel)

Con el tunnel configurado (Paso 4), tu arquitectura completa es:

```
Internet → Cloudflare Tunnel → cloudflared → localhost:5678 → n8n
```

---

## Requisitos Previos

| Recurso | Detalle |
|---------|---------|
| PC con Ubuntu Server | 22.04 o 24.04 LTS, mínimo 2GB RAM, 10GB disco |
| Usuario con `sudo` | El que creaste al instalar Ubuntu |
| Conexión a internet | Para descargar paquetes |
| Teclado y monitor (o SSH) | Para acceder al servidor |

> 💡 **No necesitas dominio para empezar.** Hoy trabajaremos solo en red local.
> Si ya tienes dominio, el Paso 4 te guía para exponer n8n a internet con Cloudflare Tunnel.

---

## Paso 1: Docker

### ¿Por qué Docker?

Docker encapsula n8n y PostgreSQL en **contenedores** — entornos aislados que incluyen todo lo necesario para ejecutarse. Beneficios para ti ahora:

- **No ensucias tu sistema:** n8n y PostgreSQL no dejan archivos sueltos en tu Ubuntu
- **Arranque automático:** Los contenedores se inician solos al prender el PC
- **Reproducible:** Puedes borrar y recrear todo en 1 minuto
- **Es lo que usarás en producción** (lo verás en Módulo 3)

### Instalación

```bash
# 1. Actualizar paquetes del sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependencias que Docker necesita
sudo apt install -y ca-certificates curl

# 3. Añadir el repositorio oficial de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Instalar Docker + Docker Compose
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 5. Añadir tu usuario al grupo docker (para no usar sudo en cada comando)
sudo usermod -aG docker $USER

# 6. Activar el cambio sin cerrar sesión
newgrp docker
```

> ⚠️ Si cierras la terminal y vuelves a entrar, el grupo `docker` ya estará activo.

### Verificar

```bash
docker --version
docker compose version
docker run hello-world
```

Si ves "Hello from Docker!", ya está listo.

---

## Paso 2: Dokploy

### ¿Qué es Dokploy y por qué usarlo?

Dokploy es un **panel de control visual para Docker**. Piensa en él como un "escritorio" para tus contenedores:

- Ves qué servicios están corriendo
- Puedes iniciar/detener/actualizar con un clic
- Gestiona logs, volúmenes, redes
- Te da una interfaz web en lugar de solo terminal

Para alguien que empieza (tú), es mucho más amigable que manejar Docker solo por comandos.

### Instalación

```bash
# Un solo comando instala Dokploy como servicio systemd
# NOTA: Necesita sudo porque crea el usuario dokploy, registra servicio systemd
# y configura redes Docker. A diferencia de Docker, no puedes omitir sudo aquí.
# Usamos bash explícitamente (no sh) porque el script usa sintaxis [[ ]] de bash.
curl -sSL https://dokploy.com/install.sh | sudo bash
```

Durante la instalación te preguntará:

| Pregunta | Qué responder |
|----------|---------------|
| **Domain** | Déjalo vacío (Enter). Usaremos la IP local. |
| **Email** | Tu email (para certificados, aunque no los usaremos ahora) |
| **Password** | Una contraseña segura para el dashboard |

### Verificar instalación

```bash
# Dokploy se instaló como servicio systemd → arranca solo al bootear
sudo systemctl status dokploy

# Ver el contenedor de Dokploy
docker ps | grep dokploy
```

### Acceder al dashboard

1. Abre un navegador en **otra PC de tu red local**
2. Ve a `http://<IP-DE-TU-SERVIDOR>:3000`
3. Inicia sesión con el email y password que configuraste

> 💡 **Para saber la IP de tu servidor:** ejecuta `ip a` o `hostname -I` en el servidor.

### Crear el proyecto

Desde el dashboard (en tu navegador):

1. **Projects → New Project**
   - Name: `n8n-server`
   - Description: `n8n + PostgreSQL`

2. **Dentro del proyecto → Add Application**
   - Type: **Docker Compose**

   Te aparecerá una pantalla que dice "Provider — Select the source of your code" con varias opciones (GitHub, GitLab, Raw...). **Selecciona Raw.**

   Al hacer clic en Raw, se abrirá un editor de texto. **No escribas nada aún** — primero vamos a entender qué vamos a pegar ahí.

---

## Paso 3: Montar n8n + PostgreSQL

En este paso vas a crear el archivo que define los servicios (n8n y su base de datos), y lo vas a desplegar en Dokploy.

### 3.1 ¿Qué es ese archivo (docker-compose.yml)?

Es un archivo de texto que le dice a Docker: "estos programas quiero ejecutar, con esta configuración". Es como una **lista de ingredientes y pasos** para montar tu servidor.

Este archivo define **dos servicios** que trabajarán juntos:

```
┌────────────────────────────────────────────────┐
│              docker-compose.yml                 │
│                                                  │
│  services:  ← lista de programas a ejecutar     │
│  ├── postgres  ← servicio #1: base de datos     │
│  │   image: postgres:15-alpine  ← receta a usar  │
│  │   environment:  ← configuración interna       │
│  │      POSTGRES_USER: n8nuser  ← usuario de BD  │
│  │      POSTGRES_PASSWORD: ...   ← contraseña     │
│  │   volumes:  ← dónde guarda los datos          │
│  │      postgres_data → /var/lib/postgresql/data │
│  │                                                 │
│  └── n8n  ← servicio #2: el servidor n8n         │
│      image: n8nio/n8n:latest  ← receta oficial   │
│      ports: 5678:5678  ← puerta de entrada        │
│      environment:  ← configuración de n8n         │
│      depends_on: postgres  ← espera a que la BD  │
│                               esté lista          │
└────────────────────────────────────────────────┘
```

### 3.2 Generar claves seguras (en la terminal)

Los valores `mi_password_seguro` y `cambio-esta-clave-por-una-segura` son marcadores. Los vas a reemplazar por claves reales.

En la terminal de tu servidor, ejecuta:

```bash
# Generar N8N_ENCRYPTION_KEY (la llave maestra de n8n)
openssl rand -base64 32

# Generar contraseña para PostgreSQL
openssl rand -base64 16
```

Cada comando te dará una cadena como `aB3x...==`. **Copia esos dos valores y pégalos en un bloc de notas**, los usarás en el siguiente paso.

> ⚠️ **REGLAS IMPORTANTES:**
> 1. La contraseña de PostgreSQL (`openssl rand -base64 16`) debe ser el **MISMO valor exacto** en los dos lugares del YAML: donde configura PostgreSQL y donde n8n se conecta. Si pones uno diferente en cada lado, n8n fallará al arrancar.
> 2. La encryption key (`openssl rand -base64 32`) solo va en un lugar.
> 3. **Guarda ambas claves en un gestor de contraseñas.** Sin la encryption key, si reinstalas, perderás todas las credenciales guardadas en n8n (API keys de OpenAI, Telegram, etc.)

### 3.3 El YAML completo (explicado línea por línea)

| Línea | Traducción |
|-------|------------|
| `services:` | "Estos son los programas que voy a instalar" |
| `postgres:` | "El primer programa se llama postgres" |
| `image: postgres:15-alpine` | "Usa esta receta oficial de PostgreSQL versión 15" |
| `restart: unless-stopped` | "Si el PC se reinicia, arranca solo" |
| `volumes:` → `postgres_data:/...` | "Guarda los datos en un disco persistente" |
| `environment:` → `POSTGRES_PASSWORD` | "La contraseña de la base de datos" |
| `healthcheck:` | "Cada 10s verifica que PostgreSQL esté vivo" |
| `n8n:` | "El segundo programa se llama n8n" |
| `image: n8nio/n8n:latest` | "Usa la receta oficial de n8n" |
| `ports: "5678:5678"` | "Abre la puerta 5678 para entrar a n8n desde el navegador" |
| `N8N_HOST=192.168.0.100` | "n8n, tu dirección local es esta" (la IP de tu servidor) |
| `N8N_PROTOCOL=http` | "Usa http (sin HTTPS, porque estamos en red local)" |
| `N8N_SECURE_COOKIE=false` | "Permite usar n8n por HTTP en red local. Cuando tengas dominio y HTTPS (Paso 4), quitarás esta línea." |
| `N8N_ENCRYPTION_KEY` | "La llave maestra para encriptar tus claves secretas" |
| `DB_TYPE=postgresdb` | "n8n, usa PostgreSQL en vez del archivo SQLite" |
| `DB_POSTGRESDB_HOST=postgres` | "La base de datos está en el servicio llamado 'postgres'" |
| `EXECUTIONS_DATA_PRUNE=true` | "Borra automáticamente ejecuciones viejas para no llenar el disco" |
| `depends_on: postgres` | "No arranques n8n hasta que PostgreSQL esté listo" |

> 💡 **N8N_HOST** es importante para los webhooks. Si configuras Cloudflare Tunnel (Paso 4), cambiarás esto a `n8n.iducdev.org` y `N8N_PROTOCOL=https`. Por ahora con la IP local funciona perfecto.

### 3.4 Desplegar en Dokploy

Ya tienes las claves generadas y entiendes qué hace cada línea del YAML. Ahora vas a pegar todo en Dokploy.

**1. Copia este YAML completo** (desde `services:` hasta `postgres_data:`):

```yaml
services:
  postgres:
    image: postgres:15-alpine
    container_name: n8n-postgres
    restart: unless-stopped
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=n8nuser
      - POSTGRES_PASSWORD=mi_password_seguro   # ← MISMO VALOR que abajo
      - POSTGRES_DB=n8n
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U n8nuser -d n8n"]
      interval: 10s
      retries: 5

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=192.168.0.100
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_SECURE_COOKIE=false
      - N8N_ENCRYPTION_KEY=cambio-esta-clave-por-una-segura
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8nuser
      - DB_POSTGRESDB_PASSWORD=mi_password_seguro   # ← MISMO VALOR que arriba
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=168
      - GENERIC_TIMEZONE=America/Caracas
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  n8n_data:
  postgres_data:
```

> 💡 **N8N_SECURE_COOKIE=false**: n8n por defecto exige HTTPS para las cookies de sesión. Como estamos en red local (HTTP), esta línea lo desactiva. Cuando configures Cloudflare Tunnel con HTTPS (Paso 4), eliminas esta línea.

**2. Reemplaza los marcadores** en el texto que copiaste:

| Marcador | Reemplázalo con | Aparece |
|----------|----------------|---------|
| `cambio-esta-clave-por-una-segura` | El resultado de `openssl rand -base64 32` (encryption key) | 1 vez |
| `mi_password_seguro` | El resultado de `openssl rand -base64 16` (password de BD) | **2 veces** — pon el MISMO valor en ambas |

Puedes hacer el reemplazo directamente en tu bloc de notas o editor de texto antes de pegarlo en Dokploy.

**3. Ve al dashboard de Dokploy** en tu navegador → `http://192.168.0.100:3000`

**4. Dentro del proyecto `n8n-server`:**
   - En la barra lateral izquierda, haz clic en **Compose**
   - Donde dice **Provider**, selecciona **Raw** (no GitHub, no GitLab)
   - Se abrirá un editor de texto
   - **Pega el YAML** (con los valores ya reemplazados)
   - Arriba del editor hay un campo **Name** — escribe `n8n-stack`
   - Haz clic en **Deploy** (o **Save & Deploy**)

Dokploy empezará a trabajar. Esto es lo que pasa detrás:
- Descarga las imágenes de Docker (postgres:15-alpine y n8nio/n8n) → **~1 minuto**
- Crea los contenedores → **~10 segundos**
- Arranca PostgreSQL primero, luego n8n → **~20 segundos**

Puedes ver el progreso desde la terminal:

```bash
# Ver los contenedores mientras se crean
docker ps

# Al principio no verás nada (está descargando)
# Después de ~1 minuto verás:
# CONTAINER ID   IMAGE                  PORTS
# xxxxxxxxxxxx   n8nio/n8n:latest       0.0.0.0:5678->5678/tcp
# xxxxxxxxxxxx   postgres:15-alpine     5432/tcp
```

### 3.5 Verificar que funciona

```bash
# Ver contenedores activos (debes ver 2: n8n y n8n-postgres)
docker ps

# Ver los logs de n8n en vivo (para confirmar que no hay errores)
docker logs n8n -f
```

Presiona `Ctrl+C` para salir de los logs.

### 3.6 Crear tu cuenta en n8n

Abre en tu navegador:

```
http://192.168.0.100:5678
```

Deberías ver la pantalla de bienvenida de n8n con un formulario para crear tu cuenta.

> ⚠️ Si ves "Connection refused", espera 30 segundos más y recarga. La primera vez tarda en arrancar.

Completa el formulario:
- **Email:** tu correo
- **Nombre:** el que quieras
- **Contraseña:** una segura

¡Listo! Ya tienes n8n funcionando en tu servidor.

### 3.7 Posibles errores y soluciones

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `docker ps` no muestra nada | Dokploy aún descarga las imágenes | Ejecuta `docker ps` cada 30s hasta que aparezcan |
| "Connection refused" al abrir 5678 | n8n aún no arrancó | Espera 30s y recarga. Revisa `docker logs n8n -f` |
| n8n se reinicia en bucle | PostgreSQL no está listo | Revisa `docker logs n8n-postgres` |
| `password authentication failed for user "n8nuser"` en logs | La contraseña de PostgreSQL no coincide entre los dos servicios | En el Compose de Dokploy, asegúrate de que `POSTGRES_PASSWORD` (en postgres) y `DB_POSTGRESDB_PASSWORD` (en n8n) tengan el **mismo valor**. Si ya desplegaste con una contraseña incorrecta, borra el volumen de PostgreSQL (`docker volume ls \| grep postgres` → `docker volume rm <nombre>`) y redeploy. |
| La página no carga | IP incorrecta | En el servidor corre `hostname -I` para confirmar la IP |

---

## Paso 4: Cloudflare Tunnel

### ¿Qué es Cloudflare Tunnel y por qué usarlo?

Normalmente para exponer un servicio web necesitas:
1. Una IP pública
2. Abrir puertos en tu router (80, 443)
3. Un proxy inverso (Nginx) con certificado SSL

**Cloudflare Tunnel** elimina todo eso. En lugar de que internet llegue a tu servidor, **tu servidor se conecta a Cloudflare** por un túnel cifrado saliente.

| Ventaja | Explicación |
|---------|-------------|
| **Zero-trust** | No abres ningún puerto en tu router. El túnel es saliente, no entrante. |
| **Sin IP pública** | No necesitas IP fija. El túnel sigue funcionando aunque cambie tu IP. |
| **SSL automático** | Cloudflare maneja los certificados. |
| **Protección DDoS** | Cloudflare filtra el tráfico malicioso antes de que llegue a tu PC. |
| **Ideal para servidor intermitente** | Cuando tu PC está apagado, Cloudflare muestra una página de error en vez de dejar el puerto abierto. |

### Requisito

Un dominio gestionado en Cloudflare. Si compraste el dominio en Cloudflare, ya está. Si lo compraste en otro lado, cambia los nameservers a Cloudflare (panel de Cloudflare → Overview → Nameservers).

### 4.1 Instalar cloudflared en el servidor

Este paso es común para ambas opciones (Dashboard y CLI):

```bash
# Descargar el binario
curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb

# Instalar
sudo dpkg -i /tmp/cloudflared.deb

# Verificar
cloudflared --version
```

---

### Opción A: Desde el Dashboard de Cloudflare (Recomendada)

Esta opción usa la interfaz web de Cloudflare Zero Trust. Es más visual y requiere menos comandos en la terminal.

#### A.1 Crear el tunnel desde el Dashboard

1. Abre [dash.teams.cloudflare.com](https://dash.teams.cloudflare.com) e inicia sesión
2. En el menú lateral, ve a **Network → Tunnels**
3. Haz clic en **Add a tunnel**
4. Elige **cloudflared** y haz clic en **Next**
5. Dale un nombre al tunnel, por ejemplo `n8n-server`, y haz clic en **Save tunnel**
6. Cloudflare te mostrará un panel con diferentes formas de instalar cloudflared. En la sección **Choose your environment**, elige **Debian** (aunque estés en Ubuntu, es compatible)
7. Verás un comando como:
   ```
   sudo cloudflared service install <TOKEN>
   ```
   También te da **Install manually** con instrucciones para copiar el token manualmente.

#### A.2 Conectar cloudflared al tunnel

Ya instalaste cloudflared en el paso 4.1. Ahora solo necesitas darle el token de conexión.

**Opción A.2.a — Con el token directamente (recomendada si cloudflared ya está instalado):**

1. En la misma página del Dashboard, después de crear el tunnel, verás el **token** (una cadena larga que empieza con `eyJ...`)
2. En el servidor, ejecuta:
   ```bash
   sudo cloudflared service install <TOKEN>
   ```
   (reemplaza `<TOKEN>` por el token real)
3. Esto crea el servicio systemd automáticamente

**Opción A.2.b — Manual (si el comando anterior falla):**

```bash
sudo mkdir -p /etc/systemd/system/cloudflared.service.d
sudo tee /etc/systemd/system/cloudflared.service.d/override.conf << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/cloudflared --no-autoupdate tunnel run --token <TOKEN>
EOF
sudo systemctl daemon-reload
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

#### A.3 Agregar la ruta pública

Desde el Dashboard del tunnel:

1. Ve a la pestaña **Public Hostname** (o **Rutas**)
2. Haz clic en **Add a public hostname**
3. Configura:
   - **Subdomain**: `n8n`
   - **Domain**: `iducdev.org` (tu dominio)
   - **Type**: `HTTP`
   - **URL**: `localhost:5678`
4. Haz clic en **Save hostname**

Cloudflare crea automáticamente el registro DNS. Ve a **DNS → Records** y verifica que aparezca un registro tipo **CNAME** (o tipo **Túnel**) para `n8n` apuntando a `<UUID>.cfargotunnel.com`. El ícono ☁️ debe estar **naranja** (proxied).

> ⚠️ **Nota sobre el registro DNS:** A veces Cloudflare crea el registro como tipo **Túnel** y el DNS no se propaga. Si después de 2 minutos `https://n8n.iducdev.org` no carga y `dig @8.8.8.8 n8n.iducdev.org +short` devuelve vacío, ve a **DNS → Records**, borra el registro tipo Túnel y crea uno manual tipo **CNAME**:
> - **Type:** `CNAME`
> - **Name:** `n8n`
> - **Target:** `<UUID>.cfargotunnel.com` (el UUID del tunnel)
> - **Proxy:** ☁️ naranja
> - **TTL:** `Auto`

#### A.4 Verificar

```bash
sudo systemctl status cloudflared --no-pager
```

Debes ver `Active: active (running)` y líneas como `Registered tunnel connection`. Las conexiones deben mostrar `protocol=http2`.

> ⚠️ **Error común: `network is unreachable`** — Si ves errores de red en los logs, es porque tu servidor no tiene IPv6. Solución:
> ```bash
> sudo mkdir -p /etc/systemd/system/cloudflared.service.d
> sudo tee /etc/systemd/system/cloudflared.service.d/override.conf << 'EOF'
> [Service]
> Environment=TUNNEL_TRANSPORT_PROTOCOL=http2
> EOF
> sudo systemctl daemon-reload
> sudo systemctl restart cloudflared
> ```
> Esto fuerza cloudflared a usar HTTP/2 sobre TCP (IPv4) en vez de QUIC sobre UDP (que prefiere IPv6).

---

### Opción B: Desde la terminal (CLI)

Para quienes prefieren no usar el Dashboard y hacer todo desde la terminal.

#### B.1 Autenticar con Cloudflare

```bash
cloudflared tunnel login
```

Esto:
1. Abre un enlace en el navegador (o te da uno para abrir manualmente)
2. Te pide iniciar sesión en Cloudflare
3. Selecciona el dominio que quieres usar
4. Descarga un certificado en `~/.cloudflared/cert.pem`

Si estás en la terminal del servidor sin navegador, el comando te dará una URL. Cópiala, ábrela en tu otra PC, autoriza, y el servidor lo detectará automáticamente.

#### B.2 Crear el tunnel

```bash
cloudflared tunnel create n8n
```

Esto:
- Genera un archivo `<UUID>.json` en `~/.cloudflared/` (credenciales del tunnel)
- Muestra el UUID del tunnel — **guárdalo**

#### B.3 Crear la ruta DNS

```bash
cloudflared tunnel route dns n8n n8n.iducdev.org
```

Esto añade un registro DNS CNAME en Cloudflare que apunta `n8n.iducdev.org` a tu tunnel.

#### B.4 Configurar el tunnel

Crea el archivo de configuración:

```bash
mkdir -p ~/.cloudflared
nano ~/.cloudflared/config.yml
```

Contenido:

```yaml
tunnel: <TU-UUID-DEL-TUNNEL>
credentials-file: /home/iducdev/.cloudflared/<TU-UUID-DEL-TUNNEL>.json

ingress:
  - hostname: n8n.iducdev.org
    service: http://localhost:5678
  - service: http_status:404
```

> **¿Qué hace esto?**
> - Cuando alguien visita `n8n.iducdev.org`, Cloudflare envía la petición al tunnel
> - `cloudflared` en tu servidor recibe la petición y la reenvía a `http://localhost:5678` (tu n8n)
> - Cualquier otro hostname recibe 404

> ⚠️ La ruta al archivo de credenciales debe usar **la ruta absoluta del usuario**. Si instalaste cloudflared con `sudo`, las credenciales estarán en `/root/.cloudflared/`. Si lo ejecutaste como `iducdev`, estarán en `/home/iducdev/.cloudflared/`. Verifica con `ls ~/.cloudflared/`.

#### B.5 Instalar como servicio systemd

```bash
sudo cloudflared install
```

Esto crea un servicio systemd que:
- Arranca automáticamente al bootear el PC
- Mantiene el tunnel siempre conectado
- Se reinicia si falla

> ⚠️ **Error común con systemd:** Si `sudo cloudflared install` falla o el servicio no arranca, puede ser que el archivo de configuración tenga rutas incorrectas o el servicio no tenga acceso a la red. En ese caso, usa el método manual con token (Opción A.2.b) o agrega `Environment=TUNNEL_TRANSPORT_PROTOCOL=http2` si hay errores de IPv6.

#### B.6 Verificar

```bash
sudo systemctl status cloudflared --no-pager
sudo journalctl -u cloudflared -n 30 --no-pager
cloudflared tunnel list
```

---

### Post-Tunnel: Ajustar n8n para HTTPS

Cuando el tunnel está funcionando y el DNS propagado, hay que actualizar las variables de entorno de n8n para que use el dominio público en vez de la IP local.

En el Dashboard de Dokploy (`http://192.168.0.100:3000`):

1. Ve al proyecto `n8n-server`
2. En **Compose**, selecciona **Raw** (si no está ya seleccionado)
3. Modifica las variables de entorno del servicio `n8n`:

| Variable | Valor actual | Nuevo valor | ¿Por qué? |
|----------|-------------|-------------|-----------|
| `N8N_HOST` | `192.168.0.100` | `n8n.iducdev.org` | Para que n8n genere enlaces con el dominio real |
| `N8N_PROTOCOL` | `http` | `https` | Para que n8n genere enlaces con HTTPS |
| `N8N_SECURE_COOKIE` | `false` | **Eliminar la línea** | Ya no necesitas cookies inseguras porque Cloudflare maneja HTTPS |

El resto de variables se quedan igual. No toques las contraseñas ni la encryption key.

4. Haz clic en **Save** y luego **Redeploy**

Dokploy recreará el contenedor de n8n con las nuevas variables. Esto toma ~10-15 segundos.

#### Verificar después del cambio

```bash
# n8n local debe seguir funcionando
curl -I http://localhost:5678

# Ver logs de n8n (no debe haber errores nuevos)
docker logs n8n --tail 20
```

Abre `https://n8n.iducdev.org` en el navegador. Deberías ver la pantalla de inicio de sesión de n8n.

> ⚠️ Si ya tenías una sesión abierta en `http://192.168.0.100:5678`, cierra sesión primero o usa una ventana de incógnito para probar. Las cookies de HTTP no son válidas para HTTPS y viceversa.

---

### Solución de problemas del tunnel

| Problema | Causa | Solución |
|----------|-------|----------|
| `network is unreachable` en logs de cloudflared | El servidor no tiene IPv6 | Agrega `Environment=TUNNEL_TRANSPORT_PROTOCOL=http2` al servicio (ver A.4) |
| `ERR_NAME_NOT_RESOLVED` en el navegador | DNS no propagado o registro mal creado | `dig @8.8.8.8 n8n.iducdev.org`. Si vacío, borra registro Túnel y crea CNAME manual |
| `ERR_SSL_PROTOCOL_ERROR` en el navegador | El proxy de Cloudflare está en gris (DNS only) | En Cloudflare DNS, asegura que ☁️ esté **naranja** |
| navegador dice "connection refused" | n8n no está corriendo o el tunnel no reenvía | `curl -I http://localhost:5678` y `sudo systemctl status cloudflared` |
| tunnel se desconecta cada pocos minutos | Firewall de red bloquea conexiones largas | Verifica que UDP 7844 esté abierto o fuerza HTTP/2 como en A.4 |

---

## Post-instalación

### 1. Cuenta owner

Ya la creaste en el Paso 3.7. Si no lo hiciste, ve a `http://192.168.0.100:5678` y regístrate.

### 2. Probar webhooks (en red local)

Crea un workflow simple en n8n:
```
Webhook → Wait → Respond to Webhook
```

- Activa el webhook
- Desde otra terminal en tu servidor: `curl -X POST http://192.168.0.100:5678/webhook/<ID>`
- Debería responder

> 💡 Con el Cloudflare Tunnel activo, los webhooks también funcionan desde internet con `https://n8n.iducdev.org/webhook/<ID>`.

### 3. Backup de la encryption key

```bash
# Guarda esto en un lugar seguro (gestor de contraseñas)
echo "N8N_ENCRYPTION_KEY: <tu-clave>" >> ~/n8n-credenciales.txt
echo "DB_PASSWORD: <tu-password>" >> ~/n8n-credenciales.txt
```

> ⚠️ Sin esta clave, si borras los contenedores y los recreas, perderás todas las credenciales almacenadas en n8n (API keys de OpenAI, Telegram, etc.)

---

## Resumen de Servicios Instalados

| Servicio | Propósito | Arranque |
|----------|-----------|----------|
| **Docker** | Motor de contenedores | systemd (`docker.service`) → automático |
| **Dokploy** | Panel de control Docker | systemd (`dokploy.service`) → automático |
| **n8n** | Workflow automation | Docker (`restart: unless-stopped`) → automático |
| **PostgreSQL** | Base de datos de n8n | Docker (`restart: unless-stopped`) → automático |

> Si configuras Cloudflare Tunnel (Paso 4), se agregará `cloudflared` como servicio systemd.

**Cuando prendes tu PC, en ~1 minuto todo está funcionando.**

---

## Solución de Problemas Comunes

### docker: permission denied
`sudo usermod -aG docker $USER` y cierra sesión o ejecuta `newgrp docker`.

### n8n no responde en http://192.168.0.100:5678
```bash
docker logs n8n
```
Causas típicas: PostgreSQL no está listo cuando n8n arranca (espera 30s más y recarga). O el contenedor aún se está descargando (revisa con `docker ps`).

### No veo Dokploy en http://192.168.0.100:3000
```bash
# Verificar que Dokploy está corriendo
docker service ls
# Dokploy usa Swarm, no docker ps normal

# Ver logs
docker service logs dokploy --tail 50
sudo systemctl status dokploy
```

### El compose no se despliega en Dokploy
Causa típica: seleccionaste GitHub u otro proveedor en vez de **Raw**. En la sección "Provider" del compose, asegúrate de que esté seleccionado **Raw**.


---

## ¿Y Ahora?

| Quieres... | Ve a... |
|------------|---------|
| Entender Docker a fondo | `modulo_3_docker_dokploy/1_fundamentos_docker.md` |
| Crear workflows en n8n | `modulo_4.5_automatizacion_self_hosted_and_cloud/` |
| Aprender Docker Compose en detalle | `modulo_3_docker_dokploy/2_docker_compose.md` |
| Gestionar tu servidor como profesional | `modulo_7_vps_produccion/` |
| Seguir con LazyVim (Módulo 2) | `modulo_2_Nvim_lazyvim/` |

---

## Referencia: Comandos que Usaste

| Comando | ¿Qué hace? |
|---------|------------|
| `docker ps` | Lista contenedores activos |
| `docker logs n8n -f` | Ver logs de n8n en tiempo real |
| `docker logs n8n-postgres -f` | Ver logs de PostgreSQL |
| `docker restart n8n` | Reiniciar n8n sin apagar todo |
| `nano ~/n8n-docker-compose.yml` | Editar el archivo de configuración |
| `cat ~/n8n-docker-compose.yml` | Ver el contenido del compose |
| `hostname -I` | Saber la IP de tu servidor |
| `openssl rand -base64 32` | Generar clave segura |
| `sudo systemctl status dokploy` | Estado de Dokploy |
| `docker service ls` | Listar servicios de Dokploy |
