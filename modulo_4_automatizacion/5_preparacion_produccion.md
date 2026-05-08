# Módulo 3: Automatización con n8n
## 3.5 Preparación para Producción: VPS, Seguridad y Mantenimiento

### Objetivos de Aprendizaje
- Configurar las **Variables de Entorno** críticas para un VPS.
- Implementar la **Llave de Encriptación** para seguridad de credenciales.
- Optimizar el **Almacenamiento y Memoria** (Pruning).
- Crear una estrategia de **Backups con Git**.

---

## 1. Variables de Entorno Críticas
Cuando despliegas n8n en un VPS (usando Docker como vimos en el Módulo 2), n8n necesita saber ciertas cosas para funcionar correctamente.

### Las 3 Variables Obligatorias:
1. **`N8N_ENCRYPTION_KEY`:** Es una clave aleatoria que encripta tus passwords. **Si la pierdes, perderás todas tus credenciales.**
   - *Ejemplo:* `N8N_ENCRYPTION_KEY=mi-clave-ultra-secreta-123`
2. **`WEBHOOK_URL`:** n8n la usa para generar las URLs de los webhooks que darás a servicios externos.
   - *Ejemplo:* `WEBHOOK_URL=https://n8n.midominio.com/`
3. **`N8N_HOST`:** Tu dominio o IP.
   - *Ejemplo:* `N8N_HOST=n8n.midominio.com`

---

## 2. Gestión de Almacenamiento (Pruning)
Por defecto, n8n guarda el historial de CADA ejecución. Si tu flujo corre cada minuto, en un mes podrías tener millones de registros llenando el disco duro de tu VPS.

### Configuración Recomendada (en tu archivo .env):
```env
# Borrar datos viejos automáticamente
EXECUTIONS_DATA_PRUNE=true
# Mantener datos solo de las últimas 168 horas (7 días)
EXECUTIONS_DATA_MAX_AGE=168
# No guardar datos de ejecuciones exitosas (Solo si quieres ahorrar máximo espacio)
# EXECUTIONS_DATA_SAVE_ON_SUCCESS=none
```

---

## 3. Seguridad y Usuarios
1. **User Management:** Activa el sistema de usuarios para que nadie pueda entrar a tu n8n sin login.
2. **SSO / LDAP:** Solo si estás en un entorno corporativo (generalmente no necesario para proyectos personales).
3. **HTTPS:** Esto lo gestionará **Dokploy** (Módulo 2.3) automáticamente, pero asegúrate de que el puerto `5678` esté protegido.

---

## 4. Estrategia de Backups con Git
No confíes solo en el VPS. Tus flujos (workflows) deben estar en Git.

### Cómo hacerlo:
1. n8n tiene un nodo llamado **n8n** (sí, n8n dentro de n8n).
2. Puedes crear un flujo que cada noche:
   - Use el nodo **n8n** para "Exportar todos los flujos".
   - Use el nodo **GitHub** para subirlos a un repositorio privado.
3. **Resultado:** Si tu VPS explota, solo tienes que instalar n8n en uno nuevo e importar tus archivos JSON desde GitHub.

---

## 5. Aprender Haciendo: El "Check de Salud" del VPS

### El Reto
Crear un flujo que te avise si n8n está consumiendo demasiada memoria o si el disco está casi lleno.

#### Paso A: Obtener datos del sistema
1. Añade un nodo **Manual Trigger** (o Schedule cada 24h).
2. Añade un nodo **Code** para ejecutar un comando de Linux:
   ```javascript
   // Esto requiere que n8n tenga permisos para ejecutar comandos (N8N_BLOCK_SVC_COMMANDS=false)
   const { execSync } = require('child_process');
   const disk = execSync('df -h /').toString();
   return { disk_info: disk };
   ```

#### Paso B: La Alerta
1. Usa un nodo **If** para ver si el porcentaje de uso es mayor al 80%.
2. Conecta un nodo de **Telegram** para avisarte.

---

## 6. Checklist antes del "Go Live"
- [ ] ¿He definido una `N8N_ENCRYPTION_KEY` fija en mi `.env`?
- [ ] ¿He configurado el `WEBHOOK_URL` con HTTPS?
- [ ] ¿He activado el `PRUNE` para que el disco no se llene?
- [ ] ¿Tengo el flujo de backup a GitHub funcionando?
- [ ] ¿He abierto el puerto `5678` en el firewall (Módulo 1.3)?

---

## Ejercicio Final del Módulo
1. Toma uno de los flujos que creaste en la guía 3.3 o 3.4.
2. Exporta el archivo JSON manualmente a tu computadora.
3. Intenta importarlo en una pestaña de incógnito de n8n para verificar que funciona perfectamente.
4. Felicidades: **Has completado el Módulo de n8n.**

**Siguiente Paso:** Aplica todo esto en tu servidor real usando el **Módulo 2 (Docker/Dokploy)**.
