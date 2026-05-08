# Módulo 5: Infraestructura Pro (Supabase + Odoo)

## 3. Dominio Local y DNS

### Objetivos de Aprendizaje

- Configurar un servidor DNS local
- Asignar dominios locales a tus servicios
- Simplificar el acceso a aplicaciones
- Usar Pi-hole como DNS y bloqueador de publicidad

---

## 3.1 ¿Por qué un DNS Local?

### Problema

Actualmente accedes a tus servicios así:
```
http://192.168.1.100:8080      # Serverpod
http://192.168.1.100:8069      # Odoo
http://192.168.1.100:5678      # n8n
http://192.168.1.100:3000      # Dokploy
```

### Con DNS Local

```
http://serverpod.local:8080   # Serverpod
http://odoo.local:8069         # Odoo
http://n8n.local:5678          # n8n
http://dokploy.local:3000      # Dokploy
```

### Beneficios

```
✅ URLs más fáciles de recordar
✅ No necesitas recordar IPs
✅ Funciona con DHCP (IP puede cambiar)
✅ Configurar certificados SSL
✅ Desarrollo más realista
```

---

## 3.2 Pi-hole - DNS Local con Bonus

### ¿Qué es Pi-hole?

Pi-hole es un bloqueador de publicidad a nivel de red que también funciona como servidor DNS. Perfecto para uso doméstico.

### Instalación con Docker

```yaml
# docker-compose-pihole.yml

version: '3.8'

services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      - TZ=Europe/Madrid
      - WEBPASSWORD=tu_password_seguro
      - DNSMASQ_LISTENING=local
    volumes:
      - pihole_etc:/etc/pihole
      - pihole_dnsmasq:/etc/dnsmasq.d
    restart: unless-stopped

volumes:
  pihole_etc:
  pihole_dnsmasq:
```

```bash
# Levantar Pi-hole
docker compose -f docker-compose-pihole.yml up -d
```

### Configuración del Router

```
# En tu router:

# DNS Primario: 192.168.1.100 (tu servidor)
# DNS Secundario: 8.8.8.8 (Google, como backup)

# Esto hace que todas las consultas DNS
# pasen por Pi-hole primero
```

### Acceso a Pi-hole

```
URL: http://tu-servidor/admin
Password: (el que configuraste en WEBPASSWORD)
```

---

## 3.3 Configurar DNS Locales en Pi-hole

### Agregar Dominios Locales

```bash
# Desde la UI de Pi-hole:
# Settings → DNS → Conditional Forwarding

# O directamente en el archivo de configuración:

# Editar: /etc/dnsmasq.d/02-local-dns.conf

# Agregar registros:
address=/serverpod.local/192.168.1.100
address=/odoo.local/192.168.1.100
address=/n8n.local/192.168.1.100
address=/dokploy.local/192.168.1.100
address=/supabase.local/192.168.1.100
address=/postgres.local/192.168.1.100

# También puedes agregar wildcards:
address=/*.local/192.168.1.100
```

```bash
# Aplicar cambios
docker exec -it pihole pihole restartdns
```

### Alternativa: Dnsmasq Standalone

```yaml
# Si solo quieres DNS sin Pi-hole:
version: '3.8'

services:
  dnsmasq:
    image: dnsmasq/dnsmasq
    container_name: dnsmasq
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf
      - ./dnsmasq.d:/etc/dnsmasq.d
    restart: unless-stopped
```

```ini
# dnsmasq.conf
# No cargar resolv.conf
no-resolv

# Servidor DNS upstream
server=8.8.8.8
server=8.8.4.4

# Puerto para consultas locales
port=53

# Dominios locales
address=/serverpod.local/192.168.1.100
address=/odoo.local/192.168.1.100

# Log
log-queries
log-dhcp
```

---

## 3.4 Configurar /etc/hosts (Alternativa Simple)

### En tu Laptop (no en el servidor)

```bash
# Editar /etc/hosts (Linux/Mac) o C:\Windows\System32\drivers\etc\hosts (Windows)

# Agregar:
192.168.1.100  serverpod.local
192.168.1.100  odoo.local
192.168.1.100  n8n.local
192.168.1.100  dokploy.local

# Ahora puedes acceder:
# http://serverpod.local:8080
# http://odoo.local:8069
```

### Ventaja de esta opción

```
✅ No necesitas configurar router
✅ Solo afecta a tu laptop
✅ Funciona inmediatamente
❌ No funciona en otros dispositivos
❌ Necesitas actualizar si cambia la IP
```

---

## 3.5 Certificados SSL con Dominios Locales

### Problema con HTTPS en Local

Los certificados SSL de Let's Encrypt requieren un dominio público válido. Para local:

### Opción 1: mkcert (Desarrollo)

```bash
# Instalar en tu laptop (Linux/Mac)
sudo apt install libnss3-tools  # Debian/Ubuntu
brew install mkcert              # macOS

# Instalar CA local
mkcert -install

# Generar certificado para local
mkcert serverpod.local odoo.local n8n.local "*.local"

# Archivos generados:
# - serverpod.local.pem (certificado)
# - serverpod.local-key.pem (clave privada)
```

### Opción 2: Caddy con TLS Local

```yaml
# docker-compose-caddy.yml

services:
  caddy:
    image: caddy:2
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    restart: unless-stopped

volumes:
  caddy_data:
```

```caddy
# Caddyfile

# Proxy para Serverpod
serverpod.local {
    reverse_proxy localhost:8080
    tls internal
}

# Proxy para Odoo
odoo.local {
    reverse_proxy localhost:8069
    tls internal
}

# Proxy para n8n
n8n.local {
    reverse_proxy localhost:5678
    tls internal
}
```

```bash
# Ahora accedes con HTTPS:
# https://serverpod.local
# https://odoo.local
# https://n8n.local
```

---

## 3.6 Configuración Completa con Docker Compose

### Stack Completo de Desarrollo

```yaml
version: '3.8'

services:
  # DNS local
  dnsmasq:
    image: dnsmasq/dnsmasq
    container_name: dnsmasq
    ports:
      - "53:53/tcp"
      - "53:53/udp"
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf
    restart: unless-stopped

  # Proxy reverso con SSL
  caddy:
    image: caddy:2
    container_name: caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
    depends_on:
      - dnsmasq
    restart: unless-stopped

  # Tus servicios...
  serverpod:
    image: serverpod/serverpod:latest
    container_name: serverpod
    environment:
      - SERVERPOD_KEY=development_key
    networks:
      - app_network

  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: secret
    networks:
      - app_network

  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    networks:
      - app_network

networks:
  app_network:
    driver: bridge
```

```caddy
# Caddyfile

# Development con certificados locales
dev.local {
    reverse_proxy serverpod:8080
    tls internal
}

serverpod.local:8080 {
    reverse_proxy serverpod:8080
    tls internal
}

odoo.local:8069 {
    reverse_proxy odoo:8069
    tls internal
}

# Redirect HTTP → HTTPS
http:// {
    respond "Use HTTPS" 401
}
```

---

## 3.7 Integración con Flutter

### Configurar URLs en Flutter

```dart
// lib/config.dart

class Config {
  // Desarrollo local con dominio
  static const String devUrl = 'http://serverpod.local:8080';
  static const String devKey = 'development_key';
  
  // Desarrollo con IP (backup)
  static const String devUrlIp = 'http://192.168.1.100:8080';
  
  // Producción (cuando tengas dominio público)
  static const String prodUrl = 'https://api.tudominio.com';
  
  // Función para obtener URL
  static String getApiUrl() {
    // Cambiar según entorno
    #if DEBUG
    return devUrl;
    #else
    return prodUrl;
    #endif
  }
}
```

### Resolver DNS en Flutter (avanzado)

```dart
// Para usar dominios .local en Flutter:
// Flutter usa el DNS del sistema, debería funcionar automáticamente

// Si hay problemas, verificar:
// 1. Que el router esté configurado con el DNS correcto
// 2. Que el firewall permita mDNS (multicast DNS)
// 3. Intentar con la IP directamente si .local no funciona
```

---

## 3.8 Ejercicios Prácticos

### Ejercicio 1: Instalar DNS Local

```bash
# Instalar dnsmasq o Pi-hole
# Configurar que responda a .local
docker compose up -d
```

### Ejercicio 2: Configurar Dominios

```bash
# Agregar registros:
# serverpod.local -> tu IP
# odoo.local -> tu IP
# n8n.local -> tu IP

# Verificar que funcionan
ping serverpod.local
ping odoo.local
```

### Ejercicio 3: Configurar Caddy

```bash
# Instalar Caddy
# Configurar proxy con TLS interno
# Probar https://serverpod.local
```

---

## 3.9 Diagrama Final

```
┌─────────────────────────────────────────────────────────────┐
│                    RED LOCAL                               │
│                                                             │
│   ┌─────────────────────────────────────────────────────┐  │
│   │           Servidor Ubuntu (192.168.1.100)          │  │
│   │                                                     │  │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │  │
│   │  │ dnsmasq │  │  Caddy   │  │  Docker  │          │  │
│   │  │  (DNS)  │  │  (SSL)   │  │          │          │  │
│   │  └────┬─────┘  └────┬─────┘  └────┬─────┘          │  │
│   │       │              │              │                 │  │
│   │  ┌────┴──────────────┴──────────────┴───────────┐   │  │
│   │  │              Services                        │   │  │
│   │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐          │   │  │
│   │  │  │Serverpod│ │  Odoo   │ │   n8n   │          │   │  │
│   │  │  │ :8080   │ │  :8069  │ │  :5678  │          │   │  │
│   │  │  └─────────┘ └─────────┘ └─────────┘          │   │  │
│   │  └───────────────────────────────────────────────┘   │  │
│   └──────────────────────────────────────────────────────┘  │
│                          ▲                                   │
│   ┌──────────────────────┴──────────────────────────────┐  │
│   │                    Router                            │  │
│   │            DNS Primario: 192.168.1.100              │  │
│   └──────────────────────────────────────────────────────┘  │
│                          ▲                                   │
│   ┌──────────────────────┴──────────────────────────────┐  │
│   │              Dispositivos en red                    │  │
│   │  ┌─────────┐  ┌─────────┐  ┌─────────┐              │  │
│   │  │ Laptop  │  │  Phone  │  │ Tablet  │              │  │
│   │  │(Flutter)│  │ (Test)  │  │         │              │  │
│   │  └─────────┘  └─────────┘  └─────────┘              │  │
│   │      │            │            │                     │  │
│   │  serverpod.local odoo.local n8n.local              │  │
│   └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3.10 Recursos Adicionales

### Comandos de Diagnóstico

```bash
# Ver DNS
nslookup serverpod.local

# Ver configuración de red
ip route

# Ver puertos DNS
ss -tuln | grep :53

# Ver logs de dnsmasq
docker logs dnsmasq -f
```

### Solución de Problemas

```
Problema: .local no funciona
- Verificar que el router use el DNS del servidor
- Probar con ping desde otra máquina
- Revisar que dnsmasq esté corriendo

Problema: Certificado no válido
- Usar mkcert o Caddy con TLS interno
- Aceptar certificado manualmente en desarrollo
- NO usar certificados de producción en local
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué es un DNS local y por qué usarlo
- ✅ Instalar Pi-hole o dnsmasq
- ✅ Configurar registros de dominios locales
- ✅ Usar /etc/hosts como alternativa
- ✅ Configurar HTTPS local con Caddy
- ✅ Integrar con Flutter

**Fin del Módulo 5** - Tienes infraestructura completa.

**Siguiente:** Módulo 6: Despliegue en VPS Remoto (Producción).