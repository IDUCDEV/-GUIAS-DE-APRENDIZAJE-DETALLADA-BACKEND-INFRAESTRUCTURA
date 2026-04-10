# Módulo 1: Fundamentos de Linux y Redes

## 4. Networking Básico

### Objetivos de Aprendizaje

- Comprender qué son puertos y sockets
- Diferenciar entre localhost e IP privada
- Utilizar herramientas de diagnóstico de red
- Configurar redirecciones de puertos para servicios

---

## 4.1 Puertos y Sockets

### ¿Qué es un Puerto?

Un puerto es un número de 16 bits (0-65535) que identifica un servicio específico en una máquina. Es como un apartamento en un edificio: la IP es la dirección del edificio y el puerto es el número del apartamento.

### Puertos Reservados (Well-Known Ports)

| Puerto | Servicio | Descripción |
|--------|----------|-------------|
| 20/21 | FTP | Transferencia de archivos |
| 22 | SSH | Acceso remoto seguro |
| 25 | SMTP | Correo saliente |
| 53 | DNS | Resolución de nombres |
| 80 | HTTP | Web sin cifrar |
| 110 | POP3 | Correo entrante |
| 143 | IMAP | Correo entrante |
| 443 | HTTPS | Web cifrado |
| 3306 | MySQL | Base de datos |
| 5432 | PostgreSQL | Base de datos |
| 6379 | Redis | Cache |
| 8080 | HTTP Proxy | Puerto alternativo HTTP |

### Puertos para Serverpod

```
8080: Servidor principal (HTTP)
8081: Herramientas de desarrollo (Insights)
8082: Analytics (opcional)
```

### Ver Puertos en Uso

```bash
# Método moderno (recomendado)
ss -tuln                    # todos los puertos TCP/UDP
ss -tuln | grep LISTEN     # solo escuchando
ss -tulpn | grep :8080     # buscar puerto específico

# Método tradicional (net-tools)
netstat -tulpn
netstat -tulpn | grep docker

# Ver proceso específico en un puerto
sudo lsof -i :8080
sudo fuser 8080/tcp
```

### Output típico de ss:

```
State    Recv-Q   Send-Q   Local Address:Port   Peer Address:Port   Process
LISTEN   0        128      0.0.0.0:22          0.0.0.0:*          sshd:/
LISTEN   0        128      0.0.0.0:5432        0.0.0.0:*          postgres
LISTEN   0        128      0.0.0.0:8080       0.0.0.0:*          serverpod
```

---

## 4.2 sockets

### ¿Qué es un Socket?

Un socket es la combinación de IP + puerto. Es el punto final de comunicación entre dos procesos.

### Tipos de Sockets

```
# Socket TCP (orientado a conexión)
tcp://192.168.1.100:8080

# Socket UDP (sin conexión)
udp://192.168.1.100:53

# Socket Unix (comunicación local)
unix:/var/run/docker.sock
```

### Diferencia TCP vs UDP

| Aspecto | TCP | UDP |
|---------|-----|-----|
| Conexión | Establece conexión | Sin conexión |
| Fiabilidad | Garantiza entrega | No garantiza |
| Orden | Mantiene orden | Sin orden |
| Velocidad | Más lento | Más rápido |
| Uso | HTTP, SSH, Postgres | DNS, Streaming |

### Ejemplo: Serverpod en Socket

```dart
// Tu app Flutter se conecta via HTTP (TCP)
final client = ServerpodClient(
  uri: Uri.parse('http://192.168.1.100:8080'),
);

// Internamente, esto crea un socket TCP
// 192.168.1.100:8080
```

---

## 4.3 Localhost vs IP Privada

### Entender las Diferencias

```
┌─────────────────────────────────────────────────────────┐
│                 MI MÁQUINA (localhost)                 │
│                                                         │
│   127.0.0.1  ──────► Loopback (no sale a la red)      │
│                                                         │
│   Tu app Flutter ◄──► Serverpod (misma máquina)        │
│                                                         │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    RED LOCAL                            │
│                                                         │
│   192.168.1.50  ─────► Mi IP en la red LAN            │
│                                                         │
│   Laptop ──────► Router ──────► Servidor               │
│   (Flutter)                   (Serverpod)              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### localhost (127.0.0.1)

```bash
# Ver interfaz loopback
ip a show lo

# Output:
# lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
#     inet 127.0.0.1/8 scope host lo
#        valid_lft forever preferred_lft forever

# Ping a localhost
ping -c 2 127.0.0.1
ping -c 2 localhost
```

**Cuándo usar localhost:**
- Desarrollo local (Flutter + Serverpod en misma máquina)
- Testing de servicios en tu laptop
- Bases de datos locales

### IP Privada

```bash
# Ver tu IP privada
ip a show eth0 | grep inet

# Output:
# inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0

# Rangos de IP privadas:
# 10.0.0.0/8       - 10.x.x.x
# 172.16.0.0/12    - 172.16.x.x a 172.31.x.x
# 192.168.0.0/16   - 192.168.x.x (más común en casa)
```

**Cuándo usar IP privada:**
- Acceder a servidor desde otra máquina en la misma red
- Deploy de Serverpod en servidor separado
- Comunicación entre servicios en red local

### Casos de Uso para Flutter Developer

```dart
// Caso 1: Todo en tu laptop (desarrollo)
final client = ServerpodClient(
  uri: Uri.parse('http://127.0.0.1:8080'),
);

// Caso 2: Serverpod en servidor remoto (desarrollo)
final client = ServerpodClient(
  uri: Uri.parse('http://192.168.1.100:8080'),
);

// Caso 3: Serverpod en producción (con dominio)
final client = ServerpodClient(
  uri: Uri.parse('https://api.midominio.com'),
);
```

---

## 4.4 Herramientas de Diagnóstico

### Ver Conectividad

```bash
# Probar conectividad a un servidor
ping -c 4 192.168.1.100
ping -c 4 google.com

# Ver ruta hasta un destino
traceroute 192.168.1.100
tracepath google.com

# Ver información de DNS
nslookup google.com
dig google.com
host google.com
```

### Probar Servicios

```bash
# Ver si un puerto está abierto (TCP)
nc -zv 192.168.1.100 8080

# Con más detalle
nc -zv 192.168.1.100 8080 -w 3

# Con curl
curl -I http://192.168.1.100:8080
curl -v http://127.0.0.1:8080/api/status

# Con wget
wget -qO- http://192.168.1.100:8080
```

### Diagnóstico de Red

```bash
# Ver tablas de rutas
ip route
ip route show

# Ver vecinos (dispositivos en red local)
ip neigh show
arp -a

# Ver configuración de red
ip addr
ip link

# Ver estadísticas de red
ss -s
netstat -s
```

### Ejemplo: Diagnóstico de Serverpod

```bash
# 1. Ver si el servicio está corriendo
systemctl status serverpod
# o
docker ps

# 2. Ver qué puertos está escuchando
ss -tuln | grep 808

# 3. Probar conectividad local
curl -I http://127.0.0.1:8080

# 4. Probar desde otra máquina
curl -I http://192.168.1.100:8080

# 5. Ver logs
docker logs serverpod_container
```

---

## 4.5 Redirección de Puertos (Port Forwarding)

### Concepto

La redirección de puertos permite que externo llegue a interno.

```
Internet ──► Router ──► Servidor (192.168.1.100:8080)
:8080          :8080         192.168.1.100:8080
```

### Configurar en el Router

Esto varía según el router, pero generalmente:

1. Acceder al panel del router (http://192.168.1.1)
2. Buscar "Port Forwarding" o "Virtual Server"
3. Agregar regla:
   - Puerto externo: 8080
   - Puerto interno: 8080
   - IP interna: 192.168.1.100
   - Protocolo: TCP

### Redirección Local (para desarrollo)

```bash
# SSH con tunnel (acceder a servicio local desde remoto)
ssh -L 8080:localhost:8080 usuario@servidor

# Esto hace que http://localhost:8080 en tu laptop
# apunte al puerto 8080 del servidor remoto

# Redirección con iptables (servidor)
sudo iptables -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
```

---

## 4.6 Ejercicios Prácticos

### Ejercicio 1: Identificar Servicios

```bash
# Lista todos los servicios escuchando en tu sistema
ss -tuln

# Identifica:
# - Puerto SSH (22)
# - Puerto HTTP (80/8080)
# - Puerto PostgreSQL (5432)
# - Puerto Redis (6379)
```

### Ejercicio 2: Probar Conectividad a Serverpod

```bash
# Si tienes Serverpod instalado:

# 1. Verificar que está corriendo
docker ps | grep serverpod

# 2. Ver puertos
ss -tuln | grep 808

# 3. Probar localmente
curl -I http://127.0.0.1:8080

# 4. Probar desde otra máquina en la red
curl -I http://192.168.1.100:8080

# 5. Si falla, revisar firewall
sudo ufw status
sudo ufw allow 8080/tcp
```

### Ejercicio 3: Configurar Acceso desde Flutter

```dart
// En tu proyecto Flutter, modificar la URI según tu setup

// Para desarrollo local (misma máquina)
static const apiUrl = 'http://127.0.0.1:8080';

// Para desarrollo en red (servidor separado)
static const apiUrl = 'http://192.168.1.100:8080';

// Para producción (dominio)
static const apiUrl = 'https://api.tudominio.com';
```

---

## 4.7 Diagrama de Red para Desarrollo

```
┌─────────────────────────────────────────────────────────────┐
│                     RED LOCAL (192.168.1.x)                 │
│                                                              │
│   ┌──────────────┐         ┌──────────────────────────┐    │
│   │   Router     │         │   Servidor Ubuntu        │    │
│   │ 192.168.1.1  │─────────│ 192.168.1.100            │    │
│   └──────────────┘         │                          │    │
│        │                   │ ┌──────────────────────┐ │    │
│   ┌────┴────┐              │ │ Docker               │ │    │
│   │         │              │ │ ├─ serverpod:8080    │ │    │
│   │ Laptop  │              │ │ ├─ postgres:5432     │ │    │
│   │ (Flutter│              │ │ └─ redis:6379        │ │    │
│   │ App)    │              │ └──────────────────────┘ │    │
│   └─────────┘              └──────────────────────────┘    │
│        │                           │                        │
│   SSH  │                           │ HTTP                   │
│   :22  │                           │ :8080                  │
│        │                           │                        │
└────────┼───────────────────────────┼────────────────────────┘
         │                           │
         │ ┌─────────────┐           │ ┌─────────────────────┐
         │ │ Tu laptop  │           │ │ Tu teléfono (测试)   │
         │ │ Flutter    │           │ │ App Debug           │
         │ │ http://192 │           │ │ http://192.168.1.100│
         │ │ .168.1.100 │           │ │ :8080               │
         │ └─────────────┘           │ └─────────────────────┘
```

---

## 4.8 Recursos Adicionales

### Comandos de Red Resumen

```bash
# Puertos
ss -tuln, lsof -i

# Conectividad
ping, curl, wget, nc

# Diagnóstico
ip addr, ip route, traceroute, nslookup

# Configuración
netstat, ifconfig (deprecated)
```

### Puertos para Servicios Comunes

```
Desarrollo:
- 3000: React/Vue dev server
- 5000: Python Flask
- 8000: Django/Python
- 8080: Serverpod/General

Bases de datos:
- 3306: MySQL
- 5432: PostgreSQL
- 27017: MongoDB
- 6379: Redis

Contenedores:
- 2375: Docker (sin TLS)
- 2376: Docker (con TLS)
- 3000: Dokploy
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué son puertos y cómo verlos en uso
- ✅ Diferencia entre sockets TCP y UDP
- ✅ Diferencia entre localhost (127.0.0.1) e IP privada
- ✅ Herramientas de diagnóstico de red
- ✅ Concepto de redirección de puertos

**Fin del Módulo 1** - Has completado los fundamentos de Linux y Redes. El siguiente módulo cubriremos Docker y Dokploy para la orquestación de servicios.

**Siguiente:** Módulo 2: Docker y Dokploy - Fundamentos de contenedores.