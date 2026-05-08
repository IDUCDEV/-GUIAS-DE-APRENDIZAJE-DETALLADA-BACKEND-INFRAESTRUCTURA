# Guiones para TikTok: Automatización con n8n

> **Estructura de cada video:** Hook (3s) → Problema (7s) → Solución en acción (30s) → Resultado (10s) → CTA (10s)
> **Duración objetivo:** 45-60 segundos
> **Formato:** Cara a cámara + screen recording + time-lapse

---

## Día 1 — Recordatorio de Citas Automático (Lab 9)

### Hook (00:00 - 00:03)
"El 30% de tus clientes no asiste a sus citas porque se les olvida."

### Storyboard

| Tiempo | Visual | Audio (texto) | Overlay |
|--------|--------|---------------|---------|
| 00:00-00:03 | Cara a cámara, ceño fruncido | "El 30% de tus clientes no asiste a sus citas porque se les olvida." | 🔴 30% NO ASISTE |
| 00:03-00:08 | Pantalla: calendario de citas | "Si tienes consultorio, clínica, taller o cualquier negocio con citas, esto te interesa." | 🏥 Consultorios · Clínicas · Talleres |
| 00:08-00:10 | Cara a cámara | "Voy a mostrarte cómo lo solucioné en 15 minutos." | |
| 00:10-00:35 | Time-lapse: construyendo el workflow en n8n | (Voz en off) "Programo el flujo para que cada mañana a las 9 AM consulte las citas del día... conecto la base de datos... y por cada cliente, envío un WhatsApp automático con su nombre y hora." | Schedule → Postgres → WhatsApp |
| 00:35-00:45 | Primer plano: el WhatsApp llegando al celular | "Mira. El cliente recibe esto sin que yo haga nada. Llega solo." | 📱 Mensaje entrante automático |
| 00:45-00:50 | Cara a cámara | "Resultado: reduje las ausencias un 80% en la primera semana." | 📉 -80% AUSENCIAS |
| 00:50-01:00 | Cara a cámara, sonrisa | "¿Tienes un negocio con citas? Escríbeme 'AUTOMATIZAR' y te muestro cómo hacerlo." | 👇 ESCRIBE "AUTOMATIZAR" |

### El Cliente Imaginario
Dueño de un consultorio dental que pierde 3-4 citas al día porque los pacientes olvidan. Cada cita perdida son $50-$100 que deja de ganar. Necesita algo que funcione solo, sin que él tenga que estar mandando mensajes uno por uno.

### CTA Final
"Escritor 'AUTOMATIZAR' en los comentarios o envíame un DM y te explico cómo implementarlo en tu negocio."

### Hashtags
#automatizacion #whatsapp #n8n #recordatorios #consultorio #negocios #productividad #clientes

---

## Día 3 — Chatbot de WhatsApp con Palabras Clave (Lab 10)

### Hook (00:00 - 00:03)
"¿Recibes las mismas preguntas todos los días en WhatsApp?"

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, gesto de agobio | "¿Recibes las mismas preguntas todos los días en WhatsApp?" | 😩 "CUÁNTO CUESTA?" "HORARIOS?" "DÓNDE ESTÁN?" |
| 00:03-00:08 | Pantalla: chat de WhatsApp lleno de mensajes | "Precio, horario, ubicación... una y otra vez. Te pagan por trabajar, no por contestar lo mismo." | ⏰ 2 HORAS/DÍA PERDIDAS |
| 00:08-00:10 | Cara a cámara | "Voy a crear un bot que responda por ti al instante." | |
| 00:10-00:35 | Time-lapse: Switch node con rutas | (Voz en off) "Configuro palabras clave: si alguien escribe 'precio', responde automáticamente los planes... si escribe 'horario', responde el horario... si escribe 'ubicación', manda la dirección." | Precio → 💰 Horario → 🕐 Ubicación → 📍 |
| 00:35-00:45 | Split screen: izquierda mensaje entrante, derecha respuesta automática | "Cliente escribe 'cuánto cuesta' y al segundo recibe la respuesta. Sin demora, sin errores, 24/7." | ⚡ RESPUESTA EN 1 SEGUNDO |
| 00:45-00:50 | Cara a cámara | "Esto funciona mientras duermes, mientras trabajas, mientras estás de vacaciones." | 🌙 24/7 AUTOMÁTICO |
| 00:50-01:00 | Cara a cámara, señalando hacia abajo | "¿Quieres un bot así para tu negocio? Comenta 'BOT' o escríbeme al DM." | 👇 COMENTA "BOT" |

### El Cliente Imaginario
Dueño de un gimnasio que recibe 50+ mensajes al día preguntando precios y horarios. Contrata personal solo para contestar WhatsApp. Con el bot, ese empleado puede dedicarse a vender en lugar de responder siempre lo mismo.

### CTA Final
"Comenta 'BOT' y te mando un video personalizado de cómo se vería en tu negocio."

### Hashtags
#chatbot #whatsapp #automatizacion #atencionalcliente #n8n #negociosdigitales #bot #inteligenciaartificial

---

## Día 5 — Facturas PDF por WhatsApp (Lab 11)

### Hook (00:00 - 00:03)
"Tu cliente compra y al instante recibe su factura. Sin que tú hagas nada."

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, sonrisa | "Tu cliente compra y al instante recibe su factura. Sin que tú hagas nada." | ⚡ FACTURA AUTOMÁTICA |
| 00:03-00:08 | Pantalla: bandeja de email llena de "factura pendiente" | "¿Sigues generando y enviando facturas una por una? En 2026 eso no debería pasar." | 📄 PROCESO MANUAL ❌ |
| 00:08-00:10 | Cara a cámara | "Te enseño cómo automatizar esto." | |
| 00:10-00:35 | Time-lapse: Webhook → HTTP Request → WhatsApp | (Voz en off) "Configuro un webhook que recibe la orden de compra, descarga el PDF automáticamente desde tu sistema y lo envía por WhatsApp al cliente." | Webhook → 📥 Descarga PDF → 📤 Envía WhatsApp |
| 00:35-00:45 | Primer plano: chat de WhatsApp con PDF recibido | "Mira, el cliente abre WhatsApp y ahí está su factura. Nombre correcto, archivo correcto, todo automático." | 📎 factura-FAC-001.pdf ✓ |
| 00:45-00:50 | Cara a cámara | "Tu equipo deja de perder tiempo. El cliente queda feliz. Todos ganan." | ✅ CLIENTE FELIZ ✅ EQUIPO LIBERADO |
| 00:50-01:00 | Cara a cámara | "Si vendes productos o servicios, necesitas esto. Comenta 'FACTURA' y te explico." | 👇 COMENTA "FACTURA" |

### El Cliente Imaginario
Dueño de una tienda online que vende 20-30 productos al día. Pasa 1 hora cada tarde generando y enviando facturas. Quiere dedicar ese tiempo a conseguir más ventas en lugar de tareas administrativas.

### CTA Final
"Comenta 'FACTURA' y te cuento cómo integrar esto con tu tienda en una semana."

### Hashtags
#facturas #whatsapp #automatizacion #ecommerce #tiendaonline #n8n #facturacion #pymes

---

## Día 7 — Data Entry por WhatsApp (Lab 12)

### Hook (00:00 - 00:03)
"Agrega clientes a tu CRM sin abrir el sistema. Solo mandando un WhatsApp."

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, mostrando el celular | "Agrega clientes a tu CRM sin abrir el sistema. Solo mandando un WhatsApp." | 📲 UN MENSAJE Y LISTO |
| 00:03-00:08 | Pantalla: sistema CRM con mil ventanas abiertas | "¿Cuántas veces has conocido a alguien, te ha dado su tarjeta, y luego 'se te pierde' porque nunca lo registras?" | 🗃️ DATOS PERDIDOS = DINERO PERDIDO |
| 00:08-00:10 | Cara a cámara | "Hay una forma más fácil. Mira." | |
| 00:10-00:30 | Time-lapse: WhatsApp → Edit Fields → Supabase | (Voz en off) "Defino un formato: escribes 'ADD nombre, teléfono, email'... el sistema parsea el mensaje... y lo guarda automáticamente en tu base de datos." | ADD Juan Pérez, +52... → ✅ GUARDADO |
| 00:30-00:40 | Primer plano: el WhatsApp de confirmación | "Y al instante recibes esto: 'Cliente agregado correctamente'. Sabes que quedó registrado." | ✅ Cliente agregado: Juan Pérez |
| 00:40-00:45 | Cara a cámara | "Cero ventanas. Cero clics. Un solo mensaje." | 0 CLICS |
| 00:45-00:55 | Cara a cámara | "Agentes de bienes raíces, vendedores de campo, cualquiera que conozca clientes fuera de la oficina: esto es para ustedes." | 🏢 PARA VENDEDORES EN CAMPO |
| 00:55-01:00 | Cara a cámara | "Comenta 'CRM' y te enseño cómo conectarlo con tu sistema actual." | 👇 COMENTA "CRM" |

### El Cliente Imaginario
Agente de bienes raíces que conoce 5-10 personas al día en eventos, cafeterías, llamadas. Le dan su tarjeta, él la guarda en el bolsillo, y el 70% nunca entra al sistema. Con esto, solo saca el celular, escribe el comando, y el lead ya está en su CRM.

### CTA Final
"Si siempre estás fuera de la oficina pero necesitas capturar datos, comenta 'CRM' y te muestro cómo adaptarlo a tu negocio."

### Hashtags
#crm #whatsapp #automatizacion #ventas #bienesraices #n8n #lead #clientes

---

## Día 9 — Pipeline de Reporting Automatizado (Lab 15)

### Hook (00:00 - 00:03)
"Dejé de perder 2 horas cada lunes haciendo reportes. Así lo logré."

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, aliviado | "Dejé de perder 2 horas cada lunes haciendo reportes. Así lo logré." | 😌 ADIÓS A LOS LUNES DE REPORTES |
| 00:03-00:08 | Pantalla: Excel vacío, luego lleno de datos | "Lunes por la mañana, tu jefe te pide el reporte de ventas. Abres Excel, exportas, copias, pegas, fórmulas... 2 horas." | 📊 2 HORAS SEMANALES = 8 HORAS AL MES |
| 00:08-00:10 | Cara a cámara | "Ahora el reporte llega solo a tu correo." | |
| 00:10-00:35 | Time-lapse: Schedule → Postgres → Summarize → Data Table → Email | (Voz en off) "Programo el flujo para que cada lunes a las 8 AM consulte las ventas, las agrupe por vendedor, calcule totales y promedios, lo convierta en tabla bonita y lo envíe por correo." | 📅 Lunes 8AM → 📧 Reporte en tu bandeja |
| 00:35-00:45 | Primer plano: el correo recibido con la tabla | "Mira. Llega al correo con los datos ordenados: quién vendió más, cuánto, ticket promedio. Todo listo para presentar." | 📧 REPORTE LISTO PARA PRESENTAR |
| 00:45-00:50 | Cara a cámara | "Mientras tú tomas café, el reporte ya está en tu bandeja." | ☕ TÚ TRABAJAS EN LO IMPORTANTE |
| 00:50-01:00 | Cara a cámara | "¿Aún haces reportes manuales? Comenta 'REPORTE' y te ayudo a automatizar el tuyo." | 👇 COMENTA "REPORTE" |

### El Cliente Imaginario
Gerente de ventas que cada lunes debe presentar resultados al directorio. Pasa 2-3 horas compilando datos de varios sistemas. No es que no sepa hacerlo, es que ese tiempo podría usarlo para vender o capacitar a su equipo.

### CTA Final
"Comenta 'REPORTE' dime qué reporte haces semanalmente y te digo si se puede automatizar."

### Hashtags
#reportes #automatizacion #excel #n8n #ventas #productividad #businessintelligence #reportesautomaticos

---

## Día 11 — Formulario de Registro con n8n Form (Lab 17)

### Hook (00:00 - 00:03)
"¿Pagas $30 al mes por Typeform o Google Forms? Te muestro algo mejor."

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, sorprendido | "¿Pagas $30 al mes por Typeform o Google Forms? Te muestro algo mejor." | 💸 GRATIS |
| 00:03-00:08 | Pantalla: factura de Typeform/Google | "Formularios, registros, encuestas... les pagas a 3 servicios distintos cuando n8n ya lo hace gratis." | Typeform $30 + Google $12 + ... |
| 00:08-00:10 | Cara a cámara | "Mira lo fácil que es." | |
| 00:10-00:30 | Time-lapse: n8n Form Trigger → Postgres → Send Email | (Voz en off) "Arrastro el nodo de formulario, pongo los campos: nombre, email, teléfono... conecto directo a mi base de datos... y añado un email de bienvenida automático." | 1️⃣ Arrastra nodo 2️⃣ Configura campos 3️⃣ Conecta BD |
| 00:30-00:40 | Pantalla: el formulario funcionando desde el celular | "Compartes el link y los usuarios llenan sus datos. Al instante se guardan en tu base de datos y reciben un correo de confirmación." | 📱 Funciona en cualquier dispositivo |
| 00:40-00:45 | Cara a cámara | "Cero código. Cero suscripciones adicionales. Quince minutos." | 🚀 15 MINUTOS |
| 00:45-00:55 | Cara a cámara | "Landing pages, registros a webinars, captura de leads, formularios de contacto... todo desde un solo lugar." | 📝 Leads · Registros · Contacto |
| 00:55-01:00 | Cara a cámara | "Comenta 'FORMULARIO' y te ayudo a montar el tuyo." | 👇 COMENTA "FORMULARIO" |

### El Cliente Imaginario
Dueño de un negocio que usa Google Forms para captar leads, Typeform para encuestas, y Mailchimp para los correos de bienvenida. Paga 3 suscripciones para algo que se puede hacer en un solo flujo de n8n.

### CTA Final
"¿Para qué necesitas el formulario? Comenta 'FORMULARIO' y te digo si sirve o si necesitas algo más."

### Hashtags
#formularios #n8n #typeform #googleforms #automatizacion #leads #registro #productividad

---

## Día 13 — Sincronizador Supabase → Google Sheets (Lab 6)

### Hook (00:00 - 00:03)
"Tu equipo administrativo necesita datos de la base de datos pero no sabe SQL."

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara | "Tu equipo administrativo necesita datos de la base de datos pero no sabe SQL." | 🗄️ EQUIPO VS BASE DE DATOS |
| 00:03-00:08 | Pantalla: mensaje de WhatsApp "me pasas los datos en Excel?" | "Te ha pasado mil veces: 'me pasas los clientes en Excel?' y tú pierdes 20 minutos exportando." | 📧 "ME LOS PASAS EN EXCEL?" |
| 00:08-00:10 | Cara a cámara | "Hay una forma de que los datos lleguen solos a Sheets." | |
| 00:10-00:35 | Time-lapse: Postgres/Supabase → Google Sheets | (Voz en off) "Conecto la base de datos con Google Sheets. Cada hora, los datos nuevos se copian automáticamente a la hoja de cálculo. El equipo abre Sheets y ve los datos actualizados." | BD → 🔄 → 📊 Google Sheets |
| 00:35-00:45 | Pantalla: Sheets actualizándose en tiempo real | "Mira, mientras tú trabajas en otras cosas, los datos fluyen solos. El equipo ve la información sin tener que molestarte." | ⏱️ ACTUALIZACIÓN AUTOMÁTICA |
| 00:45-00:50 | Cara a cámara | "Tú dejas de ser el 'departamento de TI' del equipo y te dedicas a lo que importa." | 🙌 TÚ LIBERADO |
| 00:50-01:00 | Cara a cámara | "¿Tu equipo siempre te está pidiendo datos? Comenta 'SHEETS' y lo solucionamos." | 👇 COMENTA "SHEETS" |

### El Cliente Imaginario
CEO de una startup pequeña donde el equipo de ventas necesita los clientes nuevos en Excel, pero los datos están en Supabase/Postgres. El desarrollador se cansa de que le pidan "el Excel" cada semana. Automatiza la sincronización y todos felices.

### CTA Final
"Comenta 'SHEETS' y te cuento cómo conectar tu base de datos con Google Sheets en un solo día."

### Hashtags
#sheets #automatizacion #basesdedatos #excel #n8n #supabase #productividad #equipo

---

## Día 15 — Bot de Soporte vía Email (Lab 18)

### Hook (00:00 - 00:03)
"¿Tus clientes se quejan de que nunca respondes los correos rápido?"

### Storyboard

| Tiempo | Visual | Audio | Overlay |
|--------|--------|-------|---------|
| 00:00-00:03 | Cara a cámara, serio | "¿Tus clientes se quejan de que nunca respondes los correos rápido?" | ⏳ "NUNCA RESPONDEN" |
| 00:03-00:08 | Pantalla: bandeja de entrada con 50+ correos sin leer | "Cuando tienes 20, 50, 100 correos al día, es imposible responder al instante. Pero el cliente espera inmediatez." | 📬 100+ CORREOS/DÍA |
| 00:08-00:10 | Cara a cámara | "Solución: un bot que responda automáticamente mientras tú trabajas." | |
| 00:10-00:35 | Time-lapse: Email Trigger IMAP → Switch → Postgres → Send Email | (Voz en off) "Configuro que cada correo que llegue se clasifique automáticamente: ventas, soporte o facturación. Se guarda como ticket en la base de datos. Y el cliente recibe una respuesta automática: 'Hemos recibido tu consulta, te responderemos en 24h'." | 📩 Correo entra → 🏷️ Se clasifica → 📋 Se guarda → 📤 Se responde |
| 00:35-00:45 | Split screen: izquierda correo del cliente, derecha respuesta automática | "El cliente escribe y al segundo recibe confirmación. Ya no se siente ignorado. Y tú tienes un ticket registrado para darle seguimiento." | ⚡ RESPUESTA INMEDIATA |
| 00:45-00:50 | Cara a cámara | "Además, cada vez que llega un ticket, tu equipo recibe una notificación en Telegram o Slack." | 🔔 NOTIFICACIÓN AL EQUIPO |
| 00:50-01:00 | Cara a cámara | "¿Tu soporte al cliente necesita orden? Comenta 'SOPORTE' y lo arreglamos." | 👇 COMENTA "SOPORTE" |

### El Cliente Imaginario
Dueño de una agencia o negocio digital que recibe decenas de correos al día entre ventas, facturación y soporte. No tiene un sistema de tickets porque es muy pequeño para Zendesk. Los clientes se quejan de que "nunca les responden". Con esto, automatiza la confirmación y organiza los tickets sin pagar un CRM caro.

### CTA Final
"Comenta 'SOPORTE' y te ayudo a montar un sistema de tickets automático para tu negocio."

### Hashtags
#soporte #email #automatizacion #atencionalcliente #n8n #tickets #servicioalcliente #bot

---

## 📌 Notas para la grabación

### Equipo mínimo recomendado
- Celular con cámara trasera (1080p)
- Software de captura de pantalla (OBS Studio, gratuito)
- Micrófono (el del celular funciona, uno de solapa mejora el audio)
- (Opcional) Trípode para el celular

### Tips para cada video
1. **Graba el audio por separado** con la nota de voz del celular — suena mejor que el micrófono integrado
2. **Muestra el resultado primero**, después explica cómo se hizo (la gente decide en 3 segundos si vale la pena)
3. **No digas "n8n" ni "automatización" en el hook** — di "esto" o "un sistema" — suena más sencillo
4. **Time-lapse a 3x-4x velocidad** cuando estés arrastrando nodos; velocidad normal solo cuando muestres el resultado
5. **Overlays con emojis** mantienen la atención: ✅ ❌ ⚡ 💰 📱 🔥

### Adaptación para Reels/Shorts
Cada guion está pensado para 60 segundos. Si necesitas versión de 30 segundos:
- Elimina el paso a paso técnico (00:10-00:35)
- Deja: Hook → Problema → Resultado → CTA

### Frecuencia de publicación
- **Ideal:** 3-4 videos por semana
- **Mínimo:** 2 videos por semana
- Los días 1, 3, 5, 7 son los más importantes (WhatsApp) — publícalos sí o sí

---

*Documento generado para creador de contenido de automatizaciones con n8n.*
