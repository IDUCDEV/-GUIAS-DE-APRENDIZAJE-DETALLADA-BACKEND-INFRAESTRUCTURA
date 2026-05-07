# Módulo 3: Automatización con n8n
## 3.3 Conectividad Total: APIs, Webhooks y Credenciales

### Objetivos de Aprendizaje
- Entender cómo n8n gestiona la seguridad con **Credentials**.
- Dominar el nodo **HTTP Request** para conectar con cualquier API.
- Configurar **Webhooks** de entrada (Test vs Production).
- Aprender a responder a un Webhook con datos personalizados.

---

## 1. Gestión Segura de Credenciales
Nunca, bajo ningún concepto, escribas una contraseña o una API Key directamente dentro de un nodo.

### Cómo funciona en n8n:
1. Vas a la sección **Credentials** en el menú lateral.
2. Seleccionas el tipo de servicio (ej: Telegram, Gmail, HTTP Basic Auth).
3. Guardas los datos. n8n los encriptará en su base de datos.
4. En el nodo, simplemente seleccionas la credencial por su nombre.

---

## 2. El Nodo HTTP Request (Tu navaja suiza)
Si n8n no tiene un nodo oficial para un servicio, usas este. Permite hacer cualquier petición web (GET, POST, PUT, DELETE).

### Configuración clave:
- **Authentication:** Seleccionas la credencial guardada.
- **Method:** El tipo de acción (POST para enviar, GET para recibir).
- **URL:** La dirección de la API.
- **Body:** Los datos que envías (generalmente en formato JSON).

---

## 3. Webhooks: Escuchando al mundo
Un Webhook es una dirección URL que n8n crea para que otros servicios le envíen información.

### Diferencia Crítica: Test vs Production
- **Test URL:** Solo funciona cuando tienes la ventana de n8n abierta y le das a "Listen for Test Event". Se usa para diseñar.
- **Production URL:** Solo funciona después de que **activas** el workflow (interruptor arriba a la derecha). Esta es la que debes poner en servicios externos (ej: Stripe, GitHub).

### Respond to Webhook
Por defecto, n8n responde "Workflow started". Si quieres que responda algo específico (como un mensaje de éxito para tu App Flutter), debes añadir el nodo **Respond to Webhook** al final de tu flujo.

---

## 4. Aprender Haciendo: Tu propio servidor de "Ping"

### El Reto
Crear un endpoint que reciba un nombre vía Webhook y responda confirmando que los datos llegaron correctamente a tu servidor.

#### Paso A: Configurar el Webhook
1. Añade un nodo **Webhook**.
2. **HTTP Method:** POST.
3. **Path:** `saludo`.
4. Haz clic en "Test URL" y copia la dirección.

#### Paso B: Probar el Webhook
Abre una terminal (o usa una herramienta como Postman) y envía este comando:
```bash
curl -X POST https://tu-n8n-url/webhook-test/saludo \
  -H "Content-Type: application/json" \
  -d '{"usuario": "Iducdev"}'
```

#### Paso C: Responder al cliente
1. Conecta un nodo **Respond to Webhook**.
2. **Respond with:** `Text`.
3. **Response Body:** `Hola {{ $json.body.usuario }}, he recibido tu señal correctamente.`

---

## 5. Wait & Polling (Paciencia programada)
- **Nodo Wait:** Detiene el flujo por X minutos o hasta una fecha específica. Útil para enviar un recordatorio 24h después de un registro.
- **Polling:** Cuando una API no tiene webhooks, n8n debe "preguntar" cada cierto tiempo. Esto lo haces con un **Schedule Trigger** (Cron).

---

## 6. Errores Comunes en Conectividad
1. **Error 401 (Unauthorized):** Tus credenciales están mal o el token expiró.
2. **Error 404 (Not Found):** La URL de la API es incorrecta.
3. **CORS:** Ocurre si intentas llamar al webhook desde un navegador directamente. n8n suele manejarlo, pero es bueno saberlo.

---

## Ejercicio Práctico del Capítulo
1. Busca una API pública que no requiera clave (ej: `https://dog.ceo/api/breeds/image/random`).
2. Usa un nodo **HTTP Request** para obtener una imagen de un perro.
3. Usa un nodo **Edit Fields** para extraer solo la URL de la imagen.
4. Bonus: Intenta enviar esa URL a tu propio chat de Telegram usando el nodo de Telegram.

**Siguiente Guía:** 3.4 Estructuras Avanzadas - Sub-workflows, Errores y Datos Binarios.
