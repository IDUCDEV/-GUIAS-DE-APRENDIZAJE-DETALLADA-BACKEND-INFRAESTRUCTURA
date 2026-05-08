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

## 6. Source Control (Control de Versiones con Git)

n8n Enterprise permite integración nativa con Git para manejar entornos (desarrollo, staging, producción).

### Conceptos clave:

| Término | Significado |
|---------|-------------|
| **Production** | El entorno donde viven tus flujos activos |
| **Development** | Entorno de pruebas donde diseñas sin afectar producción |
| **Staging** | Entorno intermedio para validar antes de producción |
| **Push** | Subir cambios locales al repositorio Git remoto |
| **Pull** | Traer cambios del repositorio remoto a tu instancia |

### Flujo de trabajo recomendado:

1. **Development:** Diseñas y pruebas tus flujos.
2. **Push:** Subes los cambios a una rama `develop` en Git.
3. **Staging:** Haces pull desde el entorno de staging para validar.
4. **Merge:** Fusionas a `main` cuando todo funciona.
5. **Production:** Haces pull desde producción.

### Configuración básica:

1. Ve a **Settings → Source Control**.
2. Conecta tu repositorio Git (GitHub, GitLab, etc.).
3. Define las ramas: `main` para producción, `develop` para desarrollo.
4. Usa los botones **Push** y **Pull** para sincronizar.

> Nota: Esta funcionalidad está disponible en los planes Enterprise y Self-hosted con licencia.

---

## 7. Workflow History: Versionado de Flujos

**Workflow History** guarda versiones anteriores de tus flujos, permitiéndote volver atrás si algo sale mal.

### ¿Cómo funciona?

Cada vez que guardas un workflow, n8n crea una **versión**. Puedes:
- Ver el historial de cambios.
- Comparar versiones anteriores con la actual.
- Restaurar una versión anterior.

### Para acceder:

1. Abre cualquier workflow.
2. Haz clic en el menú ⋯ (tres puntos) arriba a la derecha.
3. Selecciona **Workflow History**.
4. Verás una línea de tiempo con todas las versiones guardadas.

### Configuración de retención:

```env
# Número máximo de versiones a conservar por workflow
N8N_WORKFLOW_HISTORY_MAX_COUNT=50
# Días que se conservarán las versiones
N8N_WORKFLOW_HISTORY_MAX_AGE=30
```

---

## 8. Data Pinning: Mockea Datos para Pruebas

**Data Pinning** te permite "fijar" datos de prueba en un nodo para que siempre devuelva esa misma información, sin tener que llamar a la API real cada vez que pruebas.

### ¿Para qué sirve?

- **Desarrollo:** No necesitas depender de APIs externas mientras diseñas.
- **Testing:** Puedes probar escenarios específicos con datos controlados.
- **Demo:** Presentas el flujo con datos predecibles.

### Cómo usarlo:

1. Ejecuta un nodo y obtén los datos reales una vez.
2. Haz clic en el icono 📌 (pin) que aparece al lado del nodo.
3. Los datos se "fijan": ahora cada vez que ejecutes, el nodo devolverá esos datos exactos.
4. Para liberar, haz clic de nuevo en el pin.

> ⚠️ Importante: En producción, asegúrate de que ningún nodo tenga datos pineados, o tu flujo siempre procesará los mismos datos de prueba.

---

## 9. Concurrency: Control de Ejecuciones Paralelas

Por defecto, n8n procesa un workflow a la vez. Pero cuando tienes múltiples eventos simultáneos (ej: 100 usuarios llenan un formulario al mismo tiempo), necesitas concurrencia.

### Configuración de Concurrency:

En **Settings → Execution**:

| Campo | Descripción | Recomendación |
|-------|-------------|---------------|
| `Production concurrency` | Máximo de ejecuciones simultáneas en producción | `10` - `20` |
| `Timeout` | Tiempo máximo antes de matar una ejecución colgada | `300` (5 minutos) |

### Variables de entorno para concurrencia:

```env
# Máximo de ejecuciones simultáneas
N8N_CONCURRENCY_PRODUCTION_LIMIT=20
# Timeout por ejecución (en segundos)
EXECUTIONS_TIMEOUT=300
```

### ¿Qué pasa si se excede el límite?

Las ejecuciones adicionales entran en una **cola de espera**. Se procesarán automáticamente cuando haya capacidad disponible. No se pierden, solo se retrasan.

---

## 10. External Secrets: No Hardcodees Claves

En lugar de poner claves de API en variables de entorno, **External Secrets** te permite integrar n8n con gestores de secretos como:

- **HashiCorp Vault**
- **AWS Secrets Manager**
- **Azure Key Vault**
- **GCP Secret Manager**

### Beneficios:

- Las claves rotan sin necesidad de reiniciar n8n.
- Centralizas la gestión de secretos en tu equipo.
- Auditoría de quién accede a qué secreto.

### Configuración básica (Vault):

1. Settings → External Secrets → Add.
2. Selecciona "HashiCorp Vault".
3. Configura: URL, Token, Path.
4. Ahora puedes usar `{{ $secrets.mi-clave }}` en cualquier nodo.

---

## 11. Log Streaming: Centraliza tus Logs

**Log Streaming** envía los logs de ejecución de n8n a servicios externos para monitoreo centralizado.

### Destinos soportados:

| Servicio | Formato |
|----------|---------|
| **Datadog** | Logs estructurados en JSON |
| **Sentry** | Errores y excepciones |
| **Logz.io** | Logs centralizados |
| **Sumo Logic** | Análisis de logs |

### Qué información incluye:

- Workflow ejecutado (nombre, ID).
- Estado (éxito, error, timeout).
- Duración de la ejecución.
- Mensaje de error (si falló).
- Datos de entrada/salida (opcional).

### Configuración:

1. Settings → Log Streaming → Add Destination.
2. Selecciona el servicio (ej: Datadog).
3. Configura la API Key del servicio.
4. Todos los logs empezarán a fluir automáticamente.

---

## 12. Insights: Analítica de tus Flujos

**Insights** es la herramienta de analítica de n8n. Te muestra:

- **Workflows más ejecutados:** Sabes cuáles son los que más trabajo hacen.
- **Tasa de fallos:** Detectas flujos problemáticos.
- **Tiempo de ejecución:** Identificas cuellos de botella.
- **Ahorro de tiempo:** Calcula cuántas horas humanas has automatizado.

> Disponible en n8n Cloud y Self-hosted con licencia Enterprise.

---

## 13. Checklist antes del "Go Live"
- [ ] ¿He definido una `N8N_ENCRYPTION_KEY` fija en mi `.env`?
- [ ] ¿He configurado el `WEBHOOK_URL` con HTTPS?
- [ ] ¿He activado el `PRUNE` para que el disco no se llene?
- [ ] ¿Tengo el flujo de backup a GitHub funcionando?
- [ ] ¿He abierto el puerto `5678` en el firewall (Módulo 1.3)?
- [ ] ¿He configurado la **concurrencia** para producción (`N8N_CONCURRENCY_PRODUCTION_LIMIT`)?
- [ ] ¿He desactivado el **Data Pinning** en todos los nodos de prueba?
- [ ] ¿Tengo un **Error Workflow** global asignado?
- [ ] (Opcional) ¿He configurado **Log Streaming** o **External Secrets**?

---

## Ejercicio Final del Módulo
1. Toma uno de los flujos que creaste en la guía 3.3 o 3.4.
2. Exporta el archivo JSON manualmente a tu computadora.
3. Intenta importarlo en una pestaña de incógnito de n8n para verificar que funciona perfectamente.
4. Felicidades: **Has completado el Módulo de n8n.**

**Siguiente Paso:** Aplica todo esto en tu servidor real usando el **Módulo 2 (Docker/Dokploy)**.
