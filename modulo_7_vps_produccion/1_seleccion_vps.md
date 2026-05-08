# Módulo 6: Despliegue en VPS Remoto (Producción)

## 1. Selección de VPS

### Objetivos de Aprendizaje

- Comparar proveedores de VPS populares
- Elegir el mejor proveedor según tus necesidades
- Configurar tu primer VPS

---

## 1.1 Proveedores Populares

### Comparativa

| Proveedor | Precio | Ubicaciones | Características | Mejor Para |
|-----------|--------|-------------|-----------------|------------|
| **Hetzner** | €4-€/mes | Alemania, Finlandia, EE.UU. | Excelente precio/calidad | Mejor valor |
| **DigitalOcean** | $4-/mes | Global | Interfaz fácil, API | Principiantes |
| **Contabo** | €5-€/mes | Alemania, EE.UU. | HDD + SSD, bueno para storage | Presupuesto limitado |
| **Linode** | $5-/mes | Global | Confiable, buen soporte | Profesionales |
| **AWS Lightsail** | $3.50-/mes | Global | Integración AWS | AWS users |
| **Vultr** | $2.50-/mes | Global | Excelente rendimiento | Alto rendimiento |

### Recomendación para Desarrollador Flutter

```
🎯 Hetzner (CLOUD22): 
   - €4.63/mes (2 vCPU, 4GB RAM, 40GB SSD)
   - Excelente rendimiento
   - Panel simple
   - API completa
   - ¡Recibes €20 de crédito con el link!
```

---

## 1.2 Elegir el VPS Correcto

### Requisitos Mínimos

```
Para desarrollo/小 aplicação:
- vCPU: 2
- RAM: 4 GB
- SSD: 40 GB
- Ancho de banda: 1 TB

Para producción mediana:
- vCPU: 4
- RAM: 8 GB
- SSD: 80 GB
- Ancho de banda: 2 TB
```

### Factores a Considerar

```
1. Ubicación del servidor
   - Elegir la más cercana a tus usuarios
   - Menor latencia

2. Escalabilidad
   - ¿Puedes aumentar recursos fácilmente?
   - ¿Facturación por hora o mes?

3. API y automatización
   - Para CI/CD
   - Para backups programados

4. Soporte
   - Nivel de soporte incluido
   - Tickets, email, teléfono

5. Backups
   - ¿Ofrecen backups automáticos?
   - ¿Costo adicional?
```

---

## 1.3 Crear tu Cuenta en Hetzner

### Pasos

```bash
# 1. Ir a https://hetzner.cloud/?ref=xxxxx (tu link de referido)

# 2. Registrarse con email

# 3. Verificar cuenta

# 4. Crear proyecto

# 5. Crear servidor:
#    - Location: Nuremberg (eu-central)
#    - Image: Ubuntu 22.04 LTS
#    - Type: CPX21 (€4.63/mo)
#    - Volumes: Optional
#    - Networking: IPv4 + IPv6
#    - Protection: Optional
#    - Labels: Optional
#    - Name: mi-servidor-flutter
```

### Configurar SSH en Hetzner

```bash
# Hetzner proporciona consola web
# O puedes agregar tu SSH key desde el panel

# Crear SSH key desde tu laptop:
ssh-keygen -t ed25519 -C "tu_email"

# Copiar la clave pública:
cat ~/.ssh/id_ed25519.pub

# Pegar en Hetzner Cloud Console → SSH Keys
```

---

## 1.4 Conexión al VPS

```bash
# Obtener IP del panel de Hetzner
# Conectar por SSH

ssh root@tu_ip

# Ejemplo:
ssh root@167.235.12.34

# Verificar que funciona
whoami
```

### Configurar Usuario No-Root

```bash
# Crear usuario
adduser ubuntu

# Agregar a sudo
usermod -aG sudo ubuntu

# Copiar SSH key
mkdir /home/ubuntu/.ssh
cp ~/.ssh/authorized_keys /home/ubuntu/.ssh/
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
```

---

## 1.5 First Login - Checklist

```bash
# 1. Actualizar sistema
apt update && apt upgrade -y

# 2. Verificar zona horaria
timedatectl

# 3. Configurar zona horaria
timedatectl set-timezone Europe/Madrid

# 4. Ver recursos
df -h
free -h
nproc

# 5. Configurar hostname
hostnamectl set-hostname mi-servidor

# 6. Ver IP
ip a

# 7. Verificar conectividad
ping -c 3 google.com
```

---

## 1.6 Instalar Herramientas Básicas

```bash
# Instalar herramientas esenciales
apt install -y \
  curl \
  wget \
  git \
  htop \
  nano \
  unzip \
  ca-certificates \
  gnupg \
  lsb-release

# Instalar Docker (script oficial)
curl -fsSL https://get.docker.com | sh

# Agregar usuario a grupo docker
usermod -aG docker ubuntu

# Instalar Docker Compose
apt install docker-compose-plugin

# Verificar versiones
docker --version
docker compose version
```

---

## 1.7 Configurar Dominio (Opcional)

```bash
# Si tienes un dominio, configurar DNS

# En tu proveedor de dominio (GoDaddy, Cloudflare, etc.):
# Crear registro A:
# @ -> tu_ip
# www -> tu_ip
# api -> tu_ip

# Verificar propagación
dig tu-dominio.com
```

---

## 1.8 Ejercicios Prácticos

### Ejercicio 1: Crear VPS en Hetzner

```bash
# 1. Crear cuenta en Hetzner
# 2. Crear proyecto
# 3. Crear servidor (Ubuntu 22.04, 2 vCPU, 4GB RAM)
# 4. Agregar SSH key
# 5. Conectar vía SSH
```

### Ejercicio 2: Configuración Inicial

```bash
# En tu nuevo servidor:
apt update && apt upgrade -y
apt install docker.io docker-compose
docker --version
```

### Ejercicio 3: Probar Docker

```bash
# Ejecutar contenedor de prueba
docker run -d --name test-nginx -p 80:80 nginx:alpine

# Probar
curl http://localhost

# Limpiar
docker rm -f test-nginx
```

---

## 1.9 Comparativa Detallada

### Hetzner Cloud

```
PROS:
✓ Precio inmejorable
✓ Rendimiento excelente
✓ Panel simple e intuitivo
✓ API强大
✓ Backups automáticos (€1.55/mes)
✓ Sin compromiso, pay-as-you-go

CONTRAS:
✗ Solo 3 ubicaciones principales
✗ Soporte en inglés (pero muy bueno)
✗ No tiene variedad de tipos de instancia
```

### DigitalOcean

```
PROS:
✓ Muy fácil de usar
✓ Marketplace con imágenes pre-configuradas
✓ Excelente documentación
✓ Funciones de seguridad integradas

CONTRAS:
✗ Más caro que Hetzner
✗ Facturación por hora puede sorpresas
```

---

## 1.10 Recursos Adicionales

### Links Útiles

```
Hetzner: https://hetzner.cloud/?ref=xxxxx
DigitalOcean: https://digitalocean.com
Linode: https://linode.com
```

### Comandos de Referencia

```bash
# Ver IP pública
curl -4 ifconfig.me

# Ver información del sistema
neofetch

# Ver proceso de arranque
systemd-analyze
```

---

## Resumen

En esta guía has aprendido:

- ✅ Comparar proveedores de VPS
- ✅ Elegir Hetzner como mejor opción
- ✅ Crear cuenta y configurar servidor
- ✅ Conectarse por primera vez
- ✅ Instalar herramientas básicas
- ✅ Probar Docker

**Siguiente guía:** Hardening del Servidor - Seguridad en producción.