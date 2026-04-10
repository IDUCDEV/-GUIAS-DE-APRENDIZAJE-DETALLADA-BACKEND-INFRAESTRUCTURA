# Módulo 3: Automatización (n8n + OpenClaw)

## 2. n8n Avanzado

### Objetivos de Aprendizaje

- Dominar nodos esenciales de n8n
- Usar HTTP Request para integraciones
- Transformar datos con Set y Code
- Configurar variables de entorno de forma segura

---

## 2.1 Instalación de n8n

### Opciones de Instalación

```bash
# Opción 1: Docker (recomendado)
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -v n8n_data:/home/node/.n8n \
  -e WEBHOOK_URL=http://tu-ip:5678 \
  n8nio/n8n

# Opción 2: Docker Compose
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    volumes:
      - n8n_data:/home/node/.n8n
    environment:
      - WEBHOOK_URL=http://localhost:5678
      - GENERIC_TIMEZONE=America/New_York
EOF

docker compose up -d
```

### Acceso

```
URL: http://localhost:5678 (o tu IP:5678)
Usuario: Crear en primer acceso
```

---

## 2.2 Nodos Esenciales

### Nodo: HTTP Request

```markdown
# Conectar con cualquier API REST

Configuración:
- Method: GET, POST, PUT, DELETE, PATCH
- URL: Endpoint de la API
- Headers: Autenticación, content-type
- Body: Datos a enviar (JSON)
- Authentication: None, Basic, Bearer, OAuth2
```

**Ejemplo: Consultar API de clima**

```json
{
  "node": "HTTP Request",
  "config": {
    "method": "GET",
    "url": "https://api.weather.com/v3/wx/conditions/current",
    "query": {
      "apiKey": "{{$env.WEATHER_API_KEY}}",
      "location": "Madrid"
    }
  }
}
```

**Ejemplo: Enviar datos a Serverpod**

```json
{
  "node": "HTTP Request",
  "config": {
    "method": "POST",
    "url": "http://192.168.1.100:8080/api/users",
    "headers": {
      "Content-Type": "application/json",
      "x-serverpod-key": "{{$env.SERVERPOD_KEY}}"
    },
    "body": {
      "name": "{{$json.name}}",
      "email": "{{$json.email}}"
    }
  }
}
```

### Nodo: Set

```markdown
# Transformar y asignar valores

Usos:
- Renombrar campos
- Calcular nuevos valores
- Seleccionar solo campos necesarios
- Formatear datos
```

**Ejemplo: Transformar datos de usuario**

```json
{
  "node": "Set",
  "config": {
    "assignments": {
      "assignments": [
        {
          "name": "full_name",
          "value": "{{$json.firstName}} {{$json.lastName}}"
        },
        {
          "name": "is_premium",
          "value": "{{Number($json.plan) > 0}}"
        },
        {
          "name": "created_at",
          "value": "{{$now.toISO()}}"
        }
      ]
    },
    "includeOtherFields": true
  }
}
```

### Nodo: Code (JavaScript)

```markdown
# Ejecutar código JavaScript para transformación avanzada

Entorno: Node.js (sintaxis ES6+)

Datos disponibles:
- $json: objeto con los datos de entrada
- $items(): acceder a datos de otros nodos
- $env: variables de entorno
```

**Ejemplo: Calcular métricas**

```javascript
// Obtener datos de entrada
const orders = $json.orders;

// Calcular total
const total = orders.reduce((sum, order) => {
  return sum + (order.price * order.quantity);
}, 0);

// Calcular promedio
const average = total / orders.length;

// Retornar nuevo objeto
return {
  totalOrders: orders.length,
  totalRevenue: total,
  averageOrderValue: Math.round(average * 100) / 100,
  topProduct: orders.reduce((max, order) => {
    return order.quantity > max.quantity ? order : max;
  }, orders[0]).name
};
```

**Ejemplo: Formatear fecha**

```javascript
// Convertir fecha a formato específico
const date = new Date($json.createdAt);

return {
  formattedDate: date.toLocaleDateString('es-ES', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  }),
  timestamp: date.getTime(),
  year: date.getFullYear(),
  month: date.getMonth() + 1
};
```

### Nodo: IF (Condicional)

```markdown
# Bifurcar el flujo según condición

Condiciones disponibles:
- Equal / Not Equal
- Contains / Not Contains
- Greater / Less
- Starts With / Ends With
- Is Empty / Is Not Empty
- Regex Match
```

**Ejemplo: Diferenciar usuarios**

```json
{
  "node": "IF",
  "config": {
    "conditions": {
      "conditions": [
        {
          "value1": "{{$json.plan}}",
          "operation": "equal",
          "value2": "premium"
        }
      ]
    }
  },
  "onTrue": "Send Premium Email",
  "onFalse": "Send Standard Email"
}
```

### Nodo: Switch

```markdown
# Múltiples condiciones (como switch en programación)

Permite múltiples casos + caso por defecto
```

---

## 2.3 Variables de Entorno

### ¿Por qué usarlas?

```markdown
# NO hacer esto:
- hardcodear claves API en nodos
- escribir contraseñas en flujos
- guardar tokens en código

# HACER esto:
- Usar variables de entorno
- n8n las encripta automáticamente
- Se pueden compartir entre workflows
```

### Configurar Variables

```markdown
# En n8n UI:
1. Variables → Add Variable
2. Name: API_KEY
3. Type: String (o Secret para sensibles)
4. Value: tu_clave
5. Guardar
```

### Usar en Expresiones

```
{{$env.NOMBRE_VARIABLE}}

Ejemplos:
{{$env.SERVERPOD_KEY}}
{{$env.STRIPE_SECRET}}
{{$env.DATABASE_URL}}
```

### Variables para Flutter + Serverpod

```json
{
  "variables": [
    {
      "name": "SERVERPOD_URL",
      "value": "http://192.168.1.100:8080"
    },
    {
      "name": "SERVERPOD_KEY",
      "type": "secret",
      "value": "mi_key_produccion"
    },
    {
      "name": "TELEGRAM_BOT_TOKEN",
      "type": "secret",
      "value": "123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11"
    }
  ]
}
```

---

## 2.4 Integración con Serverpod

### Ejemplo: Recibir webhook de Serverpod

```markdown
# Workflow: Procesar evento de Serverpod

1. Trigger: Webhook
   - Webhook URL: copiada para Serverpod
   - Method: POST

2. Nodo: Set (parsear datos)
   - Extraer: event_type, user_id, data

3. Nodo: Switch (por tipo de evento)
   - case: "user_created" → Enviar email bienv.
   - case: "order_completed" → Notificar admin
   - case: "payment_failed" → Alertar

4. Nodo: HTTP (respuesta a Serverpod)
   - POST /api/webhook/response
```

### Configurar Webhook en Serverpod

```dart
// En tu endpoint de Serverpod
Future<void> handleEvent(Session session, WebhookEvent event) async {
  // Enviar a n8n
  await http.post(
    Uri.parse('https://tu-n8n.com/webhook/evento'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': env.N8N_API_KEY,
    },
    body: jsonEncode({
      'type': event.type,
      'data': event.data,
      'timestamp': DateTime.now().toIso8601String(),
    }),
  );
}
```

### Notificar a Flutter App via Serverpod

```markdown
# Workflow: Notificar a usuario

1. Trigger: Cron (o webhook)
2. Nodo: HTTP Request
   - POST a Serverpod endpoint
   - Body: { "type": "push", "userId": "xxx", "message": "..." }
3. Nodo: Return (respuesta)
```

---

## 2.5 Nodos de Telegram para Notificaciones

### Configurar Bot de Telegram

```markdown
1. Buscar @BotFather en Telegram
2. Enviar /newbot
3. Dar nombre al bot
4. Copiar token (format: 123456:ABC-DEF...)
5. Buscar @userinfobot para obtener tu chat_id
```

### Enviar Mensaje

```json
{
  "node": "Telegram",
  "config": {
    "operation": "sendMessage",
    "chatId": "TU_CHAT_ID",
    "text": "Nuevo usuario: {{$json.name}}"
  }
}
```

### Enviar con Botones

```json
{
  "node": "Telegram",
  "config": {
    "operation": "sendMessage",
    "chatId": "{{$json.chatId}}",
    "text": "Orden #{{$json.orderId}} ha sido procesada",
    "replyMarkup": {
      "inline_keyboard": [
        [
          {"text": "Ver Detalles", "url": "https://tuapp.com/orders/{{$json.orderId}}"},
          {"text": "Marcar Entregada", "callback_data": "deliver:{{$json.orderId}}"}
        ]
      ]
    }
  }
}
```

---

## 2.6 Manejo de Errores

### Nodo: Error Workflow

```markdown
# Crear workflow para manejar errores

1. Trigger: Error (en workflow principal)
2. Nodo: Telegram
   - Enviar notificación con error
3. Nodo: Set
   - Guardar en log
```

### Retry Automático

```markdown
# Configurar en cada nodo:
- Error Workflow: opcional
- Retry On Fail: marcar
- Max Retries: 3
- Retry Interval: 5s, 10s, 30s
```

### Try-Catch en Code

```javascript
try {
  // Código que puede fallar
  const result = await someFunction();
  return result;
} catch (error) {
  // Manejar error
  return {
    error: error.message,
    timestamp: new Date().toISOString(),
    // Reintentar o marcar para revisión manual
    needsReview: true
  };
}
```

---

## 2.7 Ejercicios Prácticos

### Ejercicio 1: Conectar API Externa

```markdown
# Workflow: Obtener汇率 (tipo de cambio)

1. Trigger: Cron (cada hora)
2. HTTP Request
   - GET https://api.exchangerate-api.com/v4/latest/USD
3. Set
   - EUR: {{$json.rates.EUR}}
   - GBP: {{$json.rates.GBP}}
4. Telegram
   - Enviar a tu chat
```

### Ejercicio 2: Webhook de Serverpod

```markdown
# Workflow: Registrar actividad de usuario

1. Trigger: Webhook
   - Guardar URL para Serverpod
2. Set
   - userId: {{$json.userId}}
   - action: {{$json.action}}
   - timestamp: {{$now}}
3. HTTP
   - POST a tu Serverpod /api/logs
```

### Ejercicio 3: Notificación de Errores

```markdown
# Workflow: Alertas de errores

1. Trigger: Manual
2. Code
   - Simular error
3. Telegram
   - Si error → Enviar alerta
   - Si éxito → Confirmar
```

---

## 2.8 Recursos Adicionales

### Expresiones en n8n

```
# Acceso a datos
{{$json.field}}          → campo específico
{{$json.nested.field}}   → campo anidado
{{$json.array[0]}}       → primer elemento de array
{{$json.object.key}}     → clave de objeto

# Funciones
{{$now}}                 → fecha actual
{{$json.date | date}}    → formatear fecha
{{Number($json.value)}}  → convertir a número
{{$json.text.toUpperCase()}}  → mayúsculas

# Condiciones
{{$if($json.active, 'yes', 'no')}}
```

### Nodos Populares

```
- Gmail: enviar/leer emails
- Slack: enviar mensajes
- Google Sheets: hoja de cálculo
- GitHub: issues, PRs
- Discord: webhooks
- RSS: feeds
- IMAP: email genérico
```

---

## Resumen

En esta guía has aprendido:

- ✅ Instalar n8n con Docker
- ✅ Usar nodos HTTP Request, Set, Code
- ✅ Configurar variables de entorno seguras
- ✅ Integrar con Serverpod y Telegram
- ✅ Manejar errores y reintentos

**Siguiente guía:** Scraping y APIs con OpenClaw.