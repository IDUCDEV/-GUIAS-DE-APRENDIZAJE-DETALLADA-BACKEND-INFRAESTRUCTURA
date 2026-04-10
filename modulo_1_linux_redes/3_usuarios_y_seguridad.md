# Módulo 1: Fundamentos de Linux y Redes

## 3. Administración de Usuarios y Seguridad

### Objetivos de Aprendizaje

- Gestionar usuarios y grupos en Linux
- Comprender y aplicar permisos de archivos
- Configurar sudoers para acceso administrativo seguro
- Implementar firewall básico con UFW

---

## 3.1 Usuarios y Grupos

### Conceptos Fundamentales

En Linux, cada servicio o persona que accede al sistema tiene un usuario asociado. Los usuarios pueden pertenecer a grupos para facilitar la gestión de permisos.

### Comandos de Gestión de Usuarios

```bash
# Ver usuario actual
whoami
id

# Ver todos los usuarios del sistema
cat /etc/passwd | grep -v nologin

# Crear nuevo usuario
sudo adduser nombre_usuario

# Crear usuario sin home (para servicios)
sudo useradd -r -s /bin/false servicio_usuario

# Cambiar contraseña
sudo passwd nombre_usuario

# Eliminar usuario
sudo userdel nombre_usuario
sudo userdel -r nombre_usuario  # eliminar también su home
```

### Gestión de Grupos

```bash
# Ver grupos existentes
cat /etc/group

# Crear grupo
sudo groupadd nombre_grupo

# Agregar usuario a grupo
sudo usermod -aG docker ubuntu      # agregar ubuntu al grupo docker
sudo usermod -aG sudo nombre_usuario  # agregar a sudo

# Ver grupos de un usuario
groups nombre_usuario
id nombre_usuario

# Eliminar usuario de grupo
sudo gpasswd -d nombre_usuario nombre_grupo
```

### Ejemplo: Usuario para Serverpod

```bash
# Crear usuario específico para tu backend
sudo adduser serverpod

# Agregar al grupo docker (necesario para Serverpod)
sudo usermod -aG docker serverpod

# Ahora puedes-switchear a ese usuario
su - serverpod
# o conectarte como ese usuario vía SSH
ssh serverpod@192.168.1.100
```

---

## 3.2 Permisos de Archivos

### Entender los Permisos

Cada archivo en Linux tiene tres tipos de permisos para tres entidades:

```
┌──────────┬──────────┬──────────┐
│ Dueño    │ Grupo    │ Otros    │
│ rwx      │ r-x      │ r-x      │
└──────────┴──────────┴──────────┘
r = leer (4)
w = escribir (2)  
x = ejecutar (1)
```

### Ver Permisos

```bash
# Ver con detalles
ls -la

# Ejemplo de output:
# drwxr-xr-x  1 ubuntu ubuntu  4096 Apr  9 10:30 Documents/
# -rw-r--r--  1 ubuntu ubuntu  1234 Apr  9 10:15 script.sh
# -rw-------  1 ubuntu ubuntu  5678 Apr  9 10:15 .env

# Desglose del primer archivo:
# d rwx r-x r-x  ubuntu ubuntu
# | |  |  |  |
# | |  |  |  └── permisos para otros
# | |  |  └──── permisos para grupo
# | |  └─────── permisos para owner
# | └────────── tipo (d=directorio, -=archivo)
# └──────────── tipo de archivo
```

### Cambiar Permisos (chmod)

```bash
# Método simbólico (recomendado para principiantes)
chmod u+x archivo.sh        # agregar ejecutar a owner
chmod g+w archivo.txt       # agregar escribir a grupo
chmod o-r archivo.conf      # quitar lectura a otros
chmod +x archivo.sh         # agregar ejecutar a todos

# Método numérico (más común en producción)
chmod 755 archivo           # rwxr-xr-x (típico para scripts)
chmod 644 archivo           # rw-r--r-- (típico para archivos)
chmod 600 clave_privada     # rw------- (solo owner)
chmod 700 ~/.ssh            # rwx------ (solo owner)
chmod 400 ~/.ssh/id_ed25519  # solo lectura para llave privada

# Cambiar recursivamente
chmod -R 755 /home/ubuntu/proyecto/
```

### Tabla de Permisos Numéricos

| Número | Permisos | Representación |
|--------|----------|-----------------|
| 0 | ninguna | --- |
| 1 | ejecutar | --x |
| 2 | escribir | -w- |
| 3 | escribir+ejecutar | -wx |
| 4 | leer | r-- |
| 5 | leer+ejecutar | r-x |
| 6 | leer+escribir | rw- |
| 7 | todos | rwx |

### Cambiar Propietario (chown)

```bash
# Cambiar owner
sudo chown ubuntu archivo.txt

# Cambiar owner y grupo
sudo chown ubuntu:docker archivo.txt

# Cambiar recursivamente
sudo chown -R ubuntu:ubuntu /home/ubuntu/proyecto/

# Mantener permisos pero cambiar grupo
sudo chgrp docker archivo.txt
```

### Ejemplo Práctico: Permisos para Proyecto Serverpod

```bash
# Estructura típica de proyecto
ls -la ~/mi_servidor/

# Output:
# drwxr-xr-x ubuntu ubuntu ./
# -rw-r--r-- 1 ubuntu ubuntu config/
# -rw-r--r-- 1 ubuntu ubuntu lib/
# -rw-r--r-- 1 ubuntu ubuntu packages/

# La llave SSH debe tener permisos estrictos
chmod 600 ~/.ssh/id_ed25519
chmod 700 ~/.ssh/
ls -la ~/.ssh/
```

---

## 3.3 Sudoers - Acceso Administrativo

### ¿Qué es sudo?

`sudo` (superuser do) permite ejecutar comandos con privilegios de administrador temporalmente, sin necesidad de iniciar sesión como root.

### Configurar sudoers

```bash
# Ver si un usuario tiene acceso sudo
sudo -l

# Editar archivo sudoers (SIEMPRE usar visudo)
sudo visudo

# Agregar línea para usuario específico
# al final del archivo:
ubuntu ALL=(ALL:ALL) ALL
```

### Seguridad en sudoers

```bash
# NO HACER ESTO (inseguro):
# username ALL=(ALL) NOPASSWD: ALL

# CORRECTO - pedir contraseña:
username ALL=(ALL) ALL

# CORRECTO - solo comandos específicos:
username ALL=(ALL) /usr/bin/docker, /usr/bin/systemctl
```

### Diferencia entre root y usuario normal

```bash
# Ver como root
sudo su -
# Ahora eres root (observarás el # en lugar de $)

# Ejecutar un comando como root
sudo chown root:root /var/archivo_importante

# Volver a usuario normal
exit
```

### Buenas Prácticas

```bash
# 1. NO usar root como usuario principal
# 2. Crear usuario propio con permisos sudo
# 3. Usar llave SSH (no contraseña)

# Ver historial de sudo
sudo log

# Timeout de sudo (editar /etc/sudoers)
Defaults timestamp_timeout=30  # minutos
```

---

## 3.4 Firewall con UFW

### ¿Qué es UFW?

UFW (Uncomplicated Firewall) es una interfaz simplificada para iptables. Perfecto para proteger tu servidor.

### Comandos Básicos

```bash
# Ver estado del firewall
sudo ufw status
sudo ufw status verbose

# Habilitar/deshabilitar firewall
sudo ufw enable
sudo ufw disable

# Reglas por defecto (recomendado)
sudo ufw default deny incoming   # denegar todo entrante
sudo ufw default allow outgoing  # permitir todo saliente
```

### Puertos Comunes para Desarrollo

```bash
# SSH (IMPORTANTE: hacer esto antes de enable!)
sudo ufw allow 22/tcp comment 'SSH'

# HTTP
sudo ufw allow 80/tcp comment 'HTTP'

# HTTPS
sudo ufw allow 443/tcp comment 'HTTPS'

# Puertos para Serverpod
sudo ufw allow 8080/tcp comment 'Serverpod HTTP'
sudo ufw allow 8081/tcp comment 'Serverpod Insights'

# Puertos para Docker/Dokploy
sudo ufw allow 3000/tcp comment 'Dokploy'
sudo ufw allow 5432/tcp comment 'PostgreSQL'

# Ver reglas actuales
sudo ufw status numbered
```

### Gestión de Reglas

```bash
# Eliminar regla por número
sudo ufw delete 2

# Eliminar por regla
sudo ufw delete allow 8080/tcp

# Permitir desde IP específica
sudo ufw allow from 192.168.1.50 to any port 22

# Permitir rango de IPs (red local)
sudo ufw allow from 192.168.1.0/24

# Bloquear IP específica
sudo ufw deny from 192.168.1.100

# Ver logs del firewall
sudo ufw logging on
sudo tail -f /var/log/ufw.log
```

### Configuración Recomendada para Servidor

```bash
# Configuración completa para servidor de desarrollo
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (tu IP específica si es posible)
sudo ufw allow from 192.168.1.0/24 to any port 22

# HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Serverpod
sudo ufw allow 8080:8081/tcp

# Habilitar
sudo ufw enable
sudo ufw status verbose
```

---

## 3.5 Ejercicios Prácticos

### Ejercicio 1: Crear Usuario para Proyecto

```bash
# Crear usuario específico para tu proyecto Flutter
sudo adduser flutter_dev
sudo usermod -aG docker flutter_dev

# Verificar
id flutter_dev
groups flutter_dev
```

### Ejercicio 2: Configurar Permisos de Proyecto

```bash
# Crear estructura de proyecto
mkdir -p ~/proyecto/{config,logs,data}
touch ~/proyecto/config/app.yaml
touch ~/proyecto/.env

# Configurar permisos
chmod 755 ~/proyecto/
chmod 644 ~/proyecto/config/app.yaml
chmod 600 ~/proyecto/.env  # sensible!

# Verificar
ls -la ~/proyecto/
```

### Ejercicio 3: Firewall para Serverpod

```bash
# Configurar firewall completo para desarrollo
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Tu red local
sudo ufw allow from 192.168.1.0/24

# Servicios
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 8080/tcp  # Serverpod

sudo ufw enable
sudo ufw status
```

---

## 3.6 Aplicación para Flutter + Serverpod

### Diagrama de Seguridad

```
┌─────────────────────────────────────────────────────────┐
│                    SERVIDOR                             │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │   SSH (22)  │  │ HTTP (80)   │  │HTTPS (443)  │   │
│  │  Solo Tu IP │  │  Todos      │  │  Todos      │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
│         │                │                │           │
│  ┌──────┴────────────────┴────────────────┴──────┐   │
│  │              UFW Firewall                     │   │
│  └───────────────────────────────────────────────┘   │
│                           │                            │
│  ┌────────────────────────┴────────────────────┐    │
│  │            Serverpod (8080)                 │    │
│  │            PostgreSQL (5432)                 │    │
│  │            Redis (6379)                       │    │
│  └───────────────────────────────────────────────┘    │
│                                                         │
│  Usuario: ubuntu (sudo) + serverpod (Docker)         │
└─────────────────────────────────────────────────────────┘
```

### Conexión desde Flutter

```dart
// Tu app Flutter se conectará a:
// http://192.168.1.100:8080

// El firewall debe permitir:
// - Entrada en puerto 8080 (Serverpod)
// - Tu IP puede acceder al puerto 22 (SSH)
```

---

## 3.7 Recursos Adicionales

### Comandos de Seguridad Resumen

```bash
# Usuarios
whoami, id, adduser, usermod, passwd

# Permisos
chmod, chown, chgrp
ls -la

# Sudo
sudo -l, sudo su -, visudo

# Firewall
sudo ufw status, allow, deny, delete
```

### Herramientas de Monitoreo de Seguridad

```bash
# Ver intentos de login fallidos
sudo lastb

# Ver login recientes
sudo last

# Ver procesos activos
ps aux | head -20

# Ver conexiones de red
ss -tuln
```

---

## Resumen

En esta guía has aprendido:

- ✅ Crear y gestionar usuarios y grupos
- ✅ Entender y aplicar permisos de archivos (chmod, chown)
- ✅ Configurar sudoers de forma segura
- ✅ Implementar firewall con UFW

**Siguiente guía:** Networking Básico - Puertos, sockets, localhost vs IP privada.