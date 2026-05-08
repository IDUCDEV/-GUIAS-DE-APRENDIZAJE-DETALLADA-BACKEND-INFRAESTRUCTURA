# Módulo 3: Automatización con n8n
## 3.9 Automatización de Infraestructura: SSH, FTP, Commandos y Email

### Objetivos de Aprendizaje
- Ejecutar comandos en el servidor local con **Execute Command**.
- Conectarse a servidores remotos vía **SSH** para tareas de mantenimiento.
- Transferir archivos con **FTP**.
- Comprimir y descomprimir archivos con **Compression**.
- Enviar correos transaccionales con **Send Email**.

---

## 1. Execute Command: El Poder del Sistema Operativo

El nodo **Execute Command** ejecuta comandos en el mismo servidor donde corre n8n. Es como tener una terminal dentro de tu flujo.

### ⚠️ Advertencia de Seguridad

Por razones de seguridad, **Execute Command está deshabilitado por defecto** en n8n Cloud y en instalaciones Docker. Para habilitarlo, añade esta variable de entorno en tu `docker-compose.yml` o `.env`:

```env
N8N_BLOCK_SVC_COMMANDS=false
```

NUNCA habilites esto en un entorno compartido o de producción si no confías en todos los usuarios de n8n. Es un riesgo de seguridad importante.

### Configuración básica:

| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Command` | `df -h` | El comando a ejecutar |
| `Execute Once` | Activo | Ejecuta el comando una sola vez (no por cada item) |

### Ejemplos útiles:

```plaintext
# Verificar espacio en disco
Execute Command: df -h /
Output: Filesystem      Size  Used Avail Use% Mounted on
       /dev/sda1        50G   30G   20G  60% /

# Verificar memoria RAM
Execute Command: free -h
Output:               total        used        free
       Mem:           7.6G        3.2G        4.4G

# Listar procesos que más consumen
Execute Command: ps aux --sort=-%mem | head -5

# Backup de base de datos
Execute Command: pg_dump -U postgres midb > /backups/midb_$(date +%Y%m%d).sql
```

### Capturar y usar la salida:

El output del comando viene como texto. Puedes parsearlo con un nodo **Code**:

```javascript
const lines = $input.first().json.stdout.split('\n');
// Procesar cada línea
return lines.map(line => ({ linea: line }));
```

---

## 2. SSH: Automatización Remota

El nodo **SSH** te permite conectarte a servidores remotos y ejecutar comandos, como si estuvieras usando PuTTY o Terminal pero desde un flujo de n8n.

### Configuración de credenciales:

1. Ve a **Credentials → New → SSH**.
2. Opciones de autenticación:
   - **Password:** Simple pero menos seguro.
   - **Private Key:** Recomendado. Usa tu clave privada (la misma de GitHub/GitLab).

| Campo | Valor |
|-------|-------|
| `Host` | `192.168.1.100` o `midominio.com` |
| `Port` | `22` |
| `Authentication` | `Password` o `Private Key` |
| `Username` | `root` o `deploy` |

### Ejemplo: Reiniciar servidor web

```plaintext
[Schedule (cada domingo 3 AM)]
       ↓
[SSH: sudo systemctl restart nginx]
       ↓
[SSH: sudo systemctl status nginx → verificar que está activo]
       ↓
[If: status contiene "active"]
       ↓
[Telegram: "✅ Nginx reiniciado correctamente"]
```

### Operaciones disponibles:

| Operación | Descripción |
|-----------|-------------|
| `Execute Command` | Ejecuta uno o varios comandos en el servidor remoto |
| `Upload File` | Sube un archivo al servidor remoto (SCP) |

---

## 3. FTP: Transferencia de Archivos

El nodo **FTP** (y su versión segura **SFTP**) permite subir, bajar y gestionar archivos en servidores remotos.

### Configuración de credenciales:

| Campo | Valor |
|-------|-------|
| `Host` | `ftp.midominio.com` |
| `Port` | `21` (FTP) o `22` (SFTP) |
| `Auth Type` | `Password` |
| `Username` | `tu-usuario-ftp` |

### Operaciones disponibles:

| Operación | Descripción |
|-----------|-------------|
| `List` | Lista archivos en un directorio remoto |
| `Upload` | Sube un archivo desde n8n al servidor FTP |
| `Download` | Descarga un archivo desde el servidor FTP |
| `Delete` | Elimina un archivo remoto |
| `Rename` | Renombra un archivo en el servidor |

### Ejemplo: Backup diario a servidor FTP

```
[Schedule (cada noche)]
       ↓
[Execute Command: tar -czf /tmp/backup.tar.gz /var/www]
       ↓
[Read/Write Files from Disk: leer /tmp/backup.tar.gz]
       ↓
[FTP → Upload: /backups/backup_20240101.tar.gz]
       ↓
[Telegram: "✅ Backup subido a FTP"]
```

---

## 4. Compression: Zip y Unzip

El nodo **Compression** te permite comprimir y descomprimir archivos sobre la marcha.

### Operaciones:

| Operación | Descripción |
|-----------|-------------|
| `Compress` | Comprime archivos en ZIP, GZip o TAR |
| `Decompress` | Descomprime ZIP, GZip o TAR |
| `Compress (GZip)` | Comprime un solo archivo en formato .gz |

### Ejemplo: Comprimir archivos antes de enviar

```plaintext
[Manual Trigger]
       ↓
[HTTP Request → Response Format: File → URL: imagen1.jpg]
       ↓ (segunda rama)
[HTTP Request → Response Format: File → URL: imagen2.jpg]
       ↓
[Merge → Append (une las dos imágenes)]
       ↓
[Compression → Compress → Format: ZIP]
       ↓
[Send Email: adjuntar ZIP comprimido]
```

---

## 5. Send Email: Correo Transaccional

El nodo **Send Email** te permite enviar correos usando cualquier servidor SMTP.

### Configuración de credenciales SMTP:

| Campo | Valor típico |
|-------|-------------|
| `SMTP Host` | `smtp.gmail.com` o `smtp.sendgrid.net` |
| `SMTP Port` | `587` (TLS) o `465` (SSL) |
| `User` | `tu@email.com` |
| `Password` | Contraseña o App Password |

> **Gmail:** Necesitas usar un "App Password" (Contraseña de aplicación) desde tu cuenta de Google. No uses tu contraseña normal.

### Configuración del nodo:

| Campo | Valor | Explicación |
|-------|-------|-------------|
| `From Email` | `notificaciones@midominio.com` | Quién envía |
| `To` | `{{ $json.email }}` | Destinatario (puede venir de datos) |
| `Subject` | `Tu factura está lista` | Asunto del correo |
| `Text` | `Hola {{ $json.nombre }}, ...` | Cuerpo del correo (texto plano) |
| `HTML` | `<h1>Hola</h1><p>...` | Cuerpo del correo (HTML, opcional) |
| `Attachments` | Datos binarios | Archivos adjuntos |

### Ejemplo: Enviar factura por email

```
[Webhook: nueva compra]
       ↓
[Postgres: obtener datos del cliente]
       ↓
[HTML: generar factura en HTML]
       ↓
[Convert to File: HTML → PDF]
       ↓
[Send Email:
   To: {{ $json.email_cliente }}
   Subject: Factura #{{ $json.factura_id }}
   HTML: "<h2>Gracias por tu compra</h2>..."
   Attachments: [factura.pdf]
]
```

---

## 6. Aprender Haciendo: Sistema de Backup Automatizado

### El Reto
Crear un flujo que cada noche haga backup de la base de datos, lo comprima, lo suba a un servidor FTP y envíe un correo de confirmación.

#### Paso A: Programar y hacer backup
1. **Schedule Trigger:** Cada día a las 2:00 AM.
2. **Execute Command:**
   ```bash
   pg_dump -U postgres midb > /tmp/backup_db.sql
   ```
3. **Read/Write Files from Disk:** Leer `/tmp/backup_db.sql`.

#### Paso B: Comprimir
1. **Compression:** Compress → Format: GZip → Input: binary file del paso anterior.

#### Paso C: Subir a FTP
1. **FTP → Upload:** `/backups/backup_{{ $now.toFormat('yyyyMMdd') }}.sql.gz`.

#### Paso D: Notificar
1. **Send Email:**
   - To: `admin@midominio.com`
   - Subject: Backup completado
   - Text: `Backup subido exitosamente a FTP.`

---

## 7. Tabla Comparativa de Nodos de Infraestructura

| Nodo | ¿Qué hace? | ¿Cuándo usarlo? |
|------|-----------|-----------------|
| Execute Command | Ejecuta comandos en el servidor local | Mantenimiento del VPS donde corre n8n |
| SSH | Ejecuta comandos en servidores remotos | Gestionar múltiples servidores desde un flujo |
| FTP/SFTP | Transfiere archivos a servidores remotos | Backups, deploys, sincronización |
| Compression | Comprime/descomprime archivos | Preparar archivos para transferencia o ahorrar espacio |
| Send Email | Envía correos vía SMTP | Notificaciones, reportes, facturación |

---

## Ejercicio Práctico del Capítulo

1. Crea un flujo que ejecute `df -h` con **Execute Command**.
2. Usa un **Code** para parsear la salida y extraer el porcentaje de uso del disco.
3. Si el uso es mayor al 80%, envía un correo de alerta con **Send Email**.
4. (Opcional) Si tienes un VPS, conéctate vía **SSH** y ejecuta `uptime` para ver cuánto tiempo lleva funcionando.

**Siguiente Guía:** 3.10 Formularios e Interacción Humana - n8n Form, Email Trigger, Switch Avanzado.
