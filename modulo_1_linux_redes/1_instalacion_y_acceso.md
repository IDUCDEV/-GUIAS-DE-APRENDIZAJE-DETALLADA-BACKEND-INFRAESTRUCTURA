# Módulo 1: Fundamentos de Linux y Redes

## 1. Instalación y Acceso

### Objetivos de Aprendizaje

- Instalar Ubuntu Server en modo "headless" (sin interfaz gráfica)
- Configurar acceso seguro mediante SSH con llaves públicas/privadas
- Diferenciar entre IP dinámica (DHCP) e IP estática

---

## 1.1 Ubuntu Server - Instalación Headless

### ¿Qué es el modo "headless"?

El modo headless significa ejecutar un servidor sin monitor, teclado ni mouse. Todo se configuraremotamente a través de SSH. Ideal para servidores en casa o VPS.

### Opciones de Instalación

#### Opción A: Instalación con Raspberry Pi o VM

**Requerimientos mínimos:**
- CPU: 2 núcleos
- RAM: 4 GB (mínimo 2 GB)
- Almacenamiento: 25 GB SSD
- Conexión a red cableada

**Instalación en VirtualBox (recomendado para práctica):**

```bash
# Descargar Ubuntu Server desde:
# https://ubuntu.com/download/server

# En VirtualBox:
# 1. Nueva máquina → Tipo: Linux, Versión: Ubuntu (64-bit)
# 2. Memoria: 4096 MB
# 3. Disco: 25 GB (dinámico)
# 4. Configuración de red: Adaptador puente (Bridge)
# 5. Instalar sin entorno gráfico
```

#### Opción B: Instalación en servidor real

```bash
# Durante la instalación, configurar:
# - Usuario: tu_nombre (NO usar root)
# - OpenSSH server: SÍ
# - docker: NO (lo instalaremos después)
```

###Obtener la IP del servidor

```bash
# Desde el servidor
ip a show eth0

# output esperado:
# 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
#     inet 192.168.1.100/24 brd 192.168.1.255 global scope dynamic
```

### Práctica para Flutter Developer

Cuando deployes tu app Flutter con Serverpod, el servidor Ubuntu será tu backend.

---

## 1.2 SSH - Acceso Seguro

### ¿Por qué SSH?

SSH (Secure Shell) es el protocolo para acceder a servidores remotos de forma segura. Reemplaza el acceso físico a tu servidor.

### Generación de Llaves SSH

```bash
# En TU laptop (no en el servidor)
ssh-keygen -t ed25519 -C "tu_email@ejemplo.com"

# Opciones:
# - File: ~/.ssh/id_ed25519 (ENTER)
# - Passphrase: Crea una contraseña fuerte (opcional pero recomendado)

# Ver las llaves generadas
ls -la ~/.ssh/
# Deberías ver: id_ed25519 (privada) y id_ed25519.pub (pública)
```

### Copiar llave al servidor

```bash
# Método 1: ssh-copy-id (recomendado)
ssh-copy-id usuario@192.168.1.100

# Método 2: manual (si ssh-copy-id no está disponible)
ssh usuario@192.168.1.100 "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
cat ~/.ssh/id_ed25519.pub | ssh usuario@192.168.1.100 "cat >> ~/.ssh/authorized_keys"

#Ahora conecta sin contraseña
ssh usuario@192.168.1.100
```

### Configuración de SSH personalizada

```bash
# Editar configuración SSH
nano ~/.ssh/config

# Agregar:
Host servidor-local
    HostName 192.168.1.100
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    ForwardAgent yes

Host servidor-produccion
    HostName tu-dominio.com
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519
    Port 22
```

```bash
# Ahora puedes conectar con:
ssh servidor-local
```

### Seguridad SSH - Buenas Prácticas

```bash
# En el servidor: deshabilitar login por contraseña
sudo nano /etc/ssh/sshd_config

# Cambiar:
PasswordAuthentication no
PermitRootLogin no
PubKeyAuthentication yes

# Reiniciar SSH
sudo systemctl restart sshd
```

---

## 1.3 Configuración de Red - IP Estática vs Dinámica

### Diferencias Clave

| Aspecto | IP Dinámica (DHCP) | IP Estática |
|---------|-------------------|--------------|
| Asignación | Automática (router) | Manual |
| Cambia | Cada reinicio | Nunca |
| Uso | Dispositivos clientes | Servidores |
| Ejemplo | 192.168.1.105 | 192.168.1.100 |

### Configurar IP Estática en Ubuntu Server

```bash
# Método 1: Netplan (Ubuntu 18+)
sudo nano /etc/netplan/00-installer-config.yaml

network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: false
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4

# Aplicar cambios
sudo netplan apply
```

**Valores a ajustar según tu red:**
- `eth0`: Nombre de tu interfaz (ver con `ip a`)
- `192.168.1.100`: La IP que quieres asignar
- `/24`: Notación CIDR (equivalente a máscara 255.255.255.0)
- `192.168.1.1`: La IP de tu router (puerta de enlace)

```bash
# Método 2: Ver tu configuración actual
ip route show
# Busca: default via 192.168.1.1 dev eth0
```

### Verificar conectividad

```bash
# Ver tu IP
ip addr show eth0 | grep inet

# Probar conectividad
ping -c 4 8.8.8.8
ping -c 4 google.com

# Ver DNS
cat /etc/resolv.conf
```

---

## 1.4 Ejercicios Prácticos

### Ejercicio 1: Configurar tu primer servidor

1. Instala Ubuntu Server en VirtualBox
2. Configura red en modo puente
3. Obtén la IP del servidor
4. Genera tus llaves SSH en tu laptop
5. Conéctate al servidor por SSH

### Ejercicio 2: Configurar IP estática

1. Identifica el rango de IPs de tu red local
2. Asigna una IP estática fuera del rango DHCP
3. Verifica que el servidor sea accesible desde tu laptop

### Ejercicio 3 (Avanzado): Conexión desde Flutter

```dart
// Cuando tengas Serverpod instalado, tu Flutter app se conectará así:

final pod = Serverpod(
  uri: Uri.parse('http://192.168.1.100:8080'),
  authenticationKey: 'tu-key',
);

// Esto solo funcionará si tu servidor:
// - Tiene IP estática o dominio
// - Tiene el puerto 8080 abierto en el firewall
```

---

## 1.5 Recursos Adicionales

### Documentación Oficial
- [Ubuntu Server Guide](https://ubuntu.com/tutorials/install-ubuntu-server)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)

### Comandos SSH Útiles

```bash
# Copiar archivos al servidor
scp archivo.txt usuario@servidor:/home/usuario/

# Copiar archivos del servidor
scp usuario@servidor:/home/usuario/archivo.txt ./

# Ejecutar comando remoto sin conectar
ssh usuario@servidor "df -h"

# Mantener conexión viva
ssh -o ServerAliveInterval=60 usuario@servidor
```

### Redes para Desarrolladores Flutter

```
┌─────────────────────────────────────────────────────────┐
│                    TU RED LOCAL                         │
│                                                         │
│  ┌─────────────┐      ┌─────────────────────────────┐  │
│  │   Router    │──────│  Servidor Ubuntu            │  │
│  │ 192.168.1.1 │      │ 192.168.1.100 (estática)   │  │
│  └─────────────┘      │ - Docker                    │  │
│        │              │ - Serverpod                 │  │
│        │              │ - PostgreSQL                │  │
│  ┌─────┴─────┐         └─────────────────────────────┘  │
│  │ Laptop    │                                       │
│  │(Flutter)  │─────── SSH ──────────────────────────►  │
│  └───────────┘         http://192.168.1.100:8080     │
└─────────────────────────────────────────────────────────┘
```

---

## Resumen

En esta guía has aprendido:

- ✅ Instalar Ubuntu Server en modo headless
- ✅ Generar y configurar llaves SSH
- ✅ Diferenciar IP dinámica de estática
- ✅ Configurar IP estática en Ubuntu

**Siguiente guía:** La Terminal (Bash/Zsh) - Domina la línea de comandos.