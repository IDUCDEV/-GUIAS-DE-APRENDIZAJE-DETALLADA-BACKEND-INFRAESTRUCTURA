# Módulo 6: Despliegue en VPS Remoto (Producción)

## 2. Hardening del Servidor

### Objetivos de Aprendizaje

- Deshabilitar login por contraseña
- Configurar firewall básico
- Instalar y configurar Fail2Ban
- Implementar medidas de seguridad adicionales

---

## 2.1 Fundamentos de Seguridad

### Principios Clave

```
1. Mínima superficie de ataque
2. Defence in depth (defensa en profundidad)
3. Principio de mínimo privilegio
4. No confiar, verificar siempre
```

### Checklist de Seguridad

```
✅ Login solo con SSH keys
✅ Firewall configurado
✅ Puertos innecesarios cerrados
✅ Fail2Ban instalado
✅ Actualizaciones automáticas
✅ Logs monitorizados
✅ Backups regulares
```

---

## 2.2 Hardening SSH

### Deshabilitar Login por Contraseña

```bash
# Editar configuración SSH
sudo nano /etc/ssh/sshd_config

# Cambiar o agregar:
PasswordAuthentication no
PermitRootLogin no
PubKeyAuthentication yes
ChallengeResponseAuthentication no
UsePAM no

# Reiniciar SSH
sudo systemctl restart sshd
```

### Cambiar Puerto SSH (Opcional)

```bash
# Editar sshd_config
sudo nano /etc/ssh/sshd_config

# Cambiar puerto (elegir uno >1024)
Port 2222

# Abrir nuevo puerto en firewall antes de reiniciar
sudo ufw allow 2222/tcp

# Reiniciar SSH
sudo systemctl restart sshd

# Ahora conectarte con:
ssh -p 2222 ubuntu@tu_ip
```

### Configuración SSH Completa

```bash
# /etc/ssh/sshd_config

# Puerto
Port 2222

# Autenticación
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Timeout
ClientAliveInterval 300
ClientAliveCountMax 2

# Максимальные попытки
MaxAuthTries 3
MaxSessions 10

# Deshabilitar protocolos antiguos
Protocol 2

# Logging
LogLevel VERBOSE
```

---

## 2.3 Firewall con UFW

### Instalación

```bash
# Instalar UFW
sudo apt install ufw

# Ver estado
sudo ufw status verbose
```

### Configuración Básica

```bash
# Política por defecto
sudo ufw default deny incoming
sudo ufw default allow outgoing

# SSH (tu puerto personalizado si lo cambiaste)
sudo ufw allow 2222/tcp comment 'SSH'

# HTTP
sudo ufw allow 80/tcp comment 'HTTP'

# HTTPS
sudo ufw allow 443/tcp comment 'HTTPS'

# Serverpod
sudo ufw allow 8080/tcp comment 'Serverpod'
sudo ufw allow 8081/tcp comment 'Serverpod Insights'

# Habilitar firewall
sudo ufw enable

# Ver reglas
sudo ufw status numbered
```

### Reglas Avanzadas

```bash
# Permitir desde IP específica (solo tú)
sudo ufw allow from tu_ip_propia to any port 22

# Permitir rango de IPs
sudo ufw allow from 192.168.1.0/24

# Bloquear IP específica
sudo ufw deny from 192.168.1.100

# Eliminar regla
sudo ufw delete 2
```

---

## 2.4 Fail2Ban - Protección contra Fuerza Bruta

### Instalación

```bash
sudo apt install fail2ban

# Ver estado
sudo systemctl status fail2ban
```

### Configuración

```bash
# Copiar archivo de configuración por defecto
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Editar configuración
sudo nano /etc/fail2ban/jail.local
```

```ini
# /etc/fail2ban/jail.local

# Configuración de email
destemail = tu_email@dominio.com
sender = fail2ban@tu-servidor.com

# Acción por defecto (banear IP)
banaction = ufw

# SSH
[sshd]
enabled = true
port = 2222
filter = sshd
maxretry = 3
findtime = 600
bantime = 3600

# Nginx (si tienes web server)
[nginx-http-auth]
enabled = true
```

### Comandos Fail2Ban

```bash
# Ver estado
sudo fail2ban-client status

# Ver banned IPs
sudo fail2ban-client status sshd

# Desbanear IP
sudo fail2ban-client set sshd unbanip IP_A_DESBANEAR

# Banear manualmente
sudo fail2ban-client set sshd banip IP_A_BANEAR

# Recargar configuración
sudo fail2ban-client reload

# Ver logs
sudo tail -f /var/log/fail2ban.log
```

---

## 2.5 Actualizaciones Automáticas

### Instalar Unattended Upgrades

```bash
sudo apt install unattended-upgrades

# Configurar
sudo dpkg-reconfigure -plow unattended-upgrades
```

```yaml
# /etc/apt/apt.conf.d/50unattended-upgrades

// Actualizar automáticamente
Origin "${distro_id}" and "${distro_codename}-updates"
Origin "${distro_id}" and "${distro_codename}-security"
Origin "${distro_id}" and "${distro_codename}-proposed-updates"

// Instalar sin preguntar
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-updates";
    "${distro_id}:${distro_codename}-security";
};

// Reiniciar automáticamente si es necesario
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

// Enviar email
Unattended-Upgrade::Mail "tu_email@dominio.com";
```

---

## 2.6 Seguridad Adicional

### Ver Puertos Abiertos

```bash
# Ver qué escucha en la red
sudo ss -tuln

# Ver procesos escuchando
sudo lsof -i -P -n
```

### Configurar sysctl (Protección Red)

```bash
# Editar /etc/sysctl.conf

# Prevenir IP spoofing
net.ipv4.conf.default.rp_filter=1
net.ipv4.conf.all.rp_filter=1

# No responder a ping
net.ipv4.icmp_echo_ignore_all=1
net.ipv4.icmp_echo_ignore_broadcasts=1

# Prevenir ataque SYN flood
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2

# Habilitar IP forwarding solo si es necesario
# net.ipv4.ip_forward=0

# Aplicar cambios
sudo sysctl -p
```

### Monitor de Integridad (AIDE)

```bash
# Instalar AIDE
sudo apt install aide

# Inicializar base de datos
sudo aideinit

# Mover a ubicación correcta
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db

# Verificar sistema
sudo aide --check
```

---

## 2.7 Backup del Servidor

### Script de Backup

```bash
#!/bin/bash
# backup_server.sh

BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)
SERVER_NAME="mi_servidor"

mkdir -p $BACKUP_DIR

# Backup de configuración del sistema
tar -czf $BACKUP_DIR/${SERVER_NAME}_config_$DATE.tar.gz \
  /etc/ssh/sshd_config \
  /etc/fail2ban/jail.local \
  /etc/ufw \
  /etc/nginx

# Backup de Docker volumes (si hay)
docker run --rm -v postgres_data:/data -v $BACKUP_DIR:/backup \
  alpine tar -czf /backup/postgres_$DATE.tar.gz -C /data .

# Backup de scripts
tar -czf $BACKUP_DIR/scripts_$DATE.tar.gz /home/ubuntu/scripts/

# Limpiar backups antiguos (>7 días)
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completado: $DATE"
```

```bash
# Programar backup diario
chmod +x backup_server.sh
crontab -e
# Agregar: 0 3 * * * /home/ubuntu/backup_server.sh
```

---

## 2.8 Ejercicios Prácticos

### Ejercicio 1: Hardening SSH

```bash
# 1. Generar SSH key si no tienes
ssh-keygen -t ed25519

# 2. Copiar key al servidor
ssh-copy-id -p 2222 ubuntu@tu_ip

# 3. Probar login sin contraseña
ssh -p 2222 ubuntu@tu_ip

# 4. Deshabilitar contraseña
# Editar /etc/ssh/sshd_config
```

### Ejercicio 2: Configurar Firewall

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 2222/tcp  # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

### Ejercicio 3: Fail2Ban

```bash
# 1. Instalar
sudo apt install fail2ban

# 2. Configurar para SSH
sudo nano /etc/fail2ban/jail.local

# 3. Habilitar y reiniciar
sudo systemctl restart fail2ban

# 4. Ver estado
sudo fail2ban-client status
```

---

## 2.9 Checklist de Hardening

```
HARDENING CHECKLIST
===================

[ ] SSH key configurada
[ ] Login por contraseña deshabilitado
[ ] Puerto SSH cambiado (2222)
[ ] Firewall UFW configurado
[ ] Fail2Ban instalado y configurado
[ ] Actualizaciones automáticas
[ ] Puertos innecesarios cerrados
[ ] Logs de seguridad monitorizados
[ ] Backups configurados
[ ] Usuario no-root configurado
```

---

## 2.10 Recursos Adicionales

### Comandos de Seguridad

```bash
# Ver últimos login
last

# Ver intentos fallidos
sudo lastb

# Ver proceso de login actual
who

# Ver conexiones activas
ss -tunap

# Ver servicios activos
systemctl list-units --type=service
```

### Links de Referencia

```
- https://www.ssh.com/academy/ssh/sshd-configuration
- https://www.fail2ban.org/
- https://help.ubuntu.com/community/UFW
```

---

## Resumen

En esta guía has aprendido:

- ✅ Configurar SSH con keys (sin contraseña)
- ✅ Instalar y configurar UFW (firewall)
- ✅ Instalar Fail2Ban contra ataques de fuerza bruta
- ✅ Configurar actualizaciones automáticas
- ✅ Medidas de seguridad adicionales
- ✅ Configurar backups automáticos

**Siguiente guía:** CI/CD - Integración continua con GitHub y Dokploy.