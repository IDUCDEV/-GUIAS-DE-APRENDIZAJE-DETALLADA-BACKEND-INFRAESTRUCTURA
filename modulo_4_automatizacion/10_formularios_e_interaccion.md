# Módulo 3: Automatización con n8n
## 3.10 Formularios e Interacción Humana: n8n Form, Email Trigger y Switch Avanzado

### Objetivos de Aprendizaje
- Crear formularios visuales con **n8n Form** sin escribir HTML.
- Escuchar correos entrantes con **Email Trigger (IMAP)**.
- Dominar el nodo **Switch** para enrutamiento complejo.
- Combinar formularios + email + Switch para crear flujos de aprobación.

---

## 1. n8n Form: Crea Formularios Sin Código

El nodo **n8n Form** (y su trigger asociado **n8n Form Trigger**) te permite crear formularios web visuales que los usuarios pueden llenar. Los datos se envían directamente a tu flujo.

### n8n Form Trigger vs n8n Form

| Nodo | Función |
|------|---------|
| **n8n Form Trigger** | Es el punto de inicio. Muestra un formulario al usuario y los datos entran al flujo. |
| **n8n Form** | Se coloca después de un trigger. Permite crear formularios de múltiples pasos. |

### Configuración del n8n Form Trigger:

| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Title` | `Registro de Usuario` | Título del formulario |
| `Description` | `Completa tus datos` | Subtítulo |
| `Form Fields` | `nombre, email, telefono` | Los campos que aparecerán |
| `Button Label` | `Enviar` | Texto del botón |
| `Options → Redirect URL` | `https://tusitio.com/gracias` | A dónde redirigir después de enviar |

### Tipos de campos de formulario:

| Tipo | Uso |
|------|-----|
| `Text` | Texto corto (nombre, email) |
| `Number` | Solo números (edad, precio) |
| `Email` | Validación de email automática |
| `Phone` | Validación de teléfono |
| `Textarea` | Texto largo (comentarios) |
| `Dropdown` | Selección de opciones |
| `Checkbox` | Casilla de verificación |
| `Date` | Selector de fecha |
| `File` | Subida de archivos |

### ¿Dónde está la URL del formulario?

Cuando activas el workflow (interruptor arriba a la derecha), n8n genera una URL única como:
```
https://tun8n.com/form/abc123/registro
```

Puedes compartir esta URL con cualquiera. No necesitan cuenta de n8n para llenarlo.

### Ejemplo: Formulario de contacto

```
[n8n Form Trigger:
   Title: "Contáctanos"
   Fields: nombre (Text), email (Email), mensaje (Textarea)]
       ↓
[Send Email:
   To: admin@midominio.com
   Subject: Nuevo contacto: {{ $json.nombre }}
   Text: {{ $json.mensaje }}]
       ↓
[Telegram:
   Message: "📩 Nuevo mensaje de {{ $json.nombre }}"]
```

---

## 2. n8n Form Multistep: Formularios en Varios Pasos

Puedes crear experiencias tipo "wizard" (asistente) conectando múltiples nodos **n8n Form** en secuencia.

```
[n8n Form Trigger: Paso 1 - Datos personales]
       ↓
[n8n Form: Paso 2 - Dirección]
       ↓
[n8n Form: Paso 3 - Confirmación]
       ↓
[Postgres: INSERT INTO usuarios VALUES (...)]
```

Cada nodo **n8n Form** recibe los datos del paso anterior y puede mostrar nuevos campos. Es ideal para registros largos donde no quieres abrumar al usuario.

---

## 3. Email Trigger (IMAP): Escuchar Correos Entrantes

El nodo **Email Trigger (IMAP)** convierte tu bandeja de entrada en un trigger de n8n. Cada vez que llega un correo, el flujo se ejecuta automáticamente.

### Configuración de credenciales IMAP:

| Campo | Valor típico |
|-------|-------------|
| `User` | `tu@email.com` |
| `Password` | App Password (para Gmail) |
| `Host` | `imap.gmail.com` (Gmail) |
| `Port` | `993` |
| `SSL/TLS` | Activo |

### Opciones de filtrado:

| Opción | Descripción |
|--------|-------------|
| `Mailbox` | `INBOX` (bandeja de entrada) |
| `Only Read Unread` | Solo correos no leídos |
| `Custom Rules` | Filtros avanzados (remitente, asunto) |

### Datos que recibes del correo:

```json
{
  "from": "cliente@email.com",
  "fromName": "Juan Pérez",
  "to": "soporte@midominio.com",
  "subject": "Solicitud de soporte #123",
  "body": "Hola, tengo un problema con...",
  "attachments": [
    { "filename": "captura.png", "mimeType": "image/png" }
  ]
}
```

### Ejemplo: Ticket de soporte automático

```
[Email Trigger (IMAP): Filtro → subject contiene "soporte"]
       ↓
[Code: Extraer número de ticket del asunto]
       ↓
[Supabase: INSERT INTO tickets (cliente, asunto, mensaje)]
       ↓
[Send Email:
   Reply to sender: "Hemos recibido tu ticket. Te responderemos en 24h."]
       ↓
[Slack/Telegram:
   "🎫 Nuevo ticket de {{ $json.fromName }}"]
```

---

## 4. Switch Avanzado: Enrutamiento Inteligente

El nodo **Switch** lo presentamos en el nivel de WhatsApp, pero merece un tratamiento más profundo. Es como una serie de `if/else if/else` en un solo nodo.

### Tipos de enrutamiento:

| Tipo | Descripción |
|------|-------------|
| `String` | Compara texto con valores exactos o substrings |
| `Number` | Compara rangos numéricos (>, <, =) |
| `Boolean` | Evalúa verdadero/falso |
| `Fallback` | Ruta por defecto si ninguna condición se cumple |

### Ejemplo: Enrutador de tráfico por ubicación

```
[Webhook: solicitud de compra]
       ↓
[Switch: Data Type → String, Value → {{ $json.pais }}]
       ↓
   ├── Ruta 1: "MX" → [Postgres: servidor MX → calcular impuestos]
   ├── Ruta 2: "CO" → [Postgres: servidor CO → calcular impuestos]
   ├── Ruta 3: "ES" → [Postgres: servidor ES → calcular impuestos]
   └── Default: → [Send Email: "Pedido de país no soportado"]
```

### Switch con múltiples condiciones por ruta:

Puedes combinar condiciones en una sola ruta:

| Ruta | Condición |
|------|-----------|
| Latam | `pais CONTAINS MX` OR `pais CONTAINS CO` OR `pais CONTAINS AR` |
| Europa | `pais CONTAINS ES` OR `pais CONTAINS FR` OR `pais CONTAINS DE` |
| Default | (ninguna, captura todo lo demás) |

---

## 5. Aprender Haciendo: Sistema de Aprobación de Gastos

### El Reto
Crear un flujo donde un empleado solicita un gasto vía formulario, el sistema decide automáticamente quién debe aprobarlo según el monto, y notifica al aprobador por email.

#### Paso A: Formulario de solicitud
1. **n8n Form Trigger:**
   - Title: "Solicitud de Gasto"
   - Fields: `empleado` (Text), `monto` (Number), `motivo` (Textarea).

#### Paso B: Enrutar según monto
1. **Switch:** `Value → {{ $json.monto }}` → Data Type: `Number`.
   - Ruta 1: `< 1000` → Aprueba automáticamente.
   - Ruta 2: `>= 1000 AND < 5000` → Enviar a jefe directo.
   - Ruta 3: `>= 5000` → Enviar a dirección.

#### Paso C: Acción según ruta
- **Ruta 1 (< $1000):** **Send Email** al empleado: "Gasto #{{ $json.id }} aprobado automáticamente."
- **Ruta 2 ($1000-$5000):**
  1. **Send Email** al jefe: "El empleado {{ $json.empleado }} solicita ${{ $json.monto }}. Aprobar: [Link]"
  2. **Wait** (48 horas máximo por respuesta).
  3. Procesar respuesta.
- **Ruta 3 (> $5000):**
  1. **Send Email** a dirección: "Aprobación especial requerida."
  2. **Telegram:** mensaje urgente al CEO.

#### Paso D: Response
1. **Respond to Webhook:** Confirmación al empleado.

---

## 6. Comparativa de Triggers de Interacción Humana

| Trigger | ¿Qué escucha? | ¿Cuándo usarlo? |
|---------|---------------|-----------------|
| n8n Form Trigger | Envío de formulario web | Registros, encuestas, solicitudes |
| Webhook | Llamadas HTTP externas | APIs, notificaciones de servicios |
| Email Trigger (IMAP) | Correos entrantes | Tickets de soporte, pedidos por email |
| WhatsApp | Mensajes de WhatsApp | Chatbot, atención al cliente |

---

## Ejercicio Práctico del Capítulo

1. Crea un **n8n Form Trigger** con 3 campos: `nombre`, `email`, `tipo_consulta` (Dropdown: Soporte / Ventas / Otro).
2. Conecta un **Switch** que enrute según `tipo_consulta`.
3. Cada ruta debe enviar un **Send Email** al departamento correspondiente.
4. Opcional: Agrega un paso de confirmación automática (`Respond to Webhook`).

**Siguiente Guía:** Revisa el archivo de Ejercicios Prácticos para los laboratorios de Nivel 4.
