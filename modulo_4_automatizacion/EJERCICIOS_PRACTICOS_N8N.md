# 📚 Manual de Entrenamiento n8n: Aprender Haciendo (Edición Extendida)

Bienvenido a la guía definitiva de aprendizaje práctico. Cada laboratorio te dice exactamente qué configurar, por qué funciona así, qué datos esperar y cómo solucionar problemas comunes.

> **Estructura de cada laboratorio:**
> - Descripción del escenario real
> - Prerequisites (qué tener listo antes de empezar)
> - Paso a paso detallado
> - Ejemplo de datos (entrada → salida)
> - Errores comunes y soluciones
> - Resultado esperado

---

## 🟢 NIVEL 1: FUNDAMENTOS Y LÓGICA DE DATOS

### Laboratorio 1: El Triaje de Alertas (Webhooks y Flujo Lógico)

#### 📋 Descripción del Escenario

Una aplicación móvil envía reportes de errores a tu servidor. No todos los errores son iguales - algunos son críticos (caída de pagos) y otros son informativos (usuario cerró sesión). Necesitas un "triaje automático" que clasifique los errores urgentes y los formatee para que el equipo actúe rápido.

**¿Por qué usar un webhook?** Porque un webhook te permite escuchar eventos externos. Piensa en él como una puerta que solo se abre cuando alguien llama con los datos correctos.

#### ✅ Prerequisites

- [ ] Cuenta en n8n (n8n.io o self-hosted)
- [ ] Terminal para enviar comandos curl (Git Bash en Windows, Terminal en Mac/Linux)

#### 📝 Paso a Paso Detallado

**Paso 1: Crear el Trigger (Webhook)**

1. En el lienzo en blanco de n8n, haz clic en el botón `+` para buscar nodos
2. Escribe "Webhook" en el buscador y selecciona el nodo verde **Webhook**
3. Verás que aparece un nodo con estas opciones:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `HTTP Method` | `POST` | Recibirás datos (no solo una visita a la URL) |
   | `Path` | `alerta-app` | Tu URL será: `.../webhook-test/alerta-app` |
   | `Response` | `200` | n8n responderá OK al emisor cuando reciba datos |

4. **Acción CRUCIAL:** Debajo del nodo verás dos pestañas: "Test URL" y "Production URL"
   - Haz clic en **"Listen for Test Event"** (se pondrá el botón verde)
   - Esto indica que n8n está esperando un mensaje - NO CONTINÚES sin activarlo

**Paso 2: Enviar un mensaje de prueba**

Desde tu terminal (Windows: CMD o Git Bash, Mac/Linux: Terminal), ejecuta:

```bash
curl -X POST "https://TU_ID_DE_N8N.webhook.io/alerta-app" \
  -H "Content-Type: application/json" \
  -d '{"nivel": "CRITICO", "error": "Fallo en el pago", "id": 505}'
```

> ⚠️ Reemplaza `TU_ID_DE_N8N.webhook.io/alerta-app` con la URL que te aparece en la pestaña "Test URL" de n8n. La URL es única para cada usuario.

**Paso 3: Verificar que los datos llegaron**

Haz clic en el nodo Webhook. En el panel de la izquierda verás los datos de entrada:

```json
{
  "nivel": "CRITICO",
  "error": "Fallo en el pago",
  "id": 505
}
```

> 💡 **Nota:** Los datos llegan dentro de un objeto `body`. Si ves `$json.body.nivel`, es porque n8n envuelve los datos del webhook en esa estructura.

**Paso 4: Añadir la lógica de filtro (If Node)**

1. Haz clic en el botón `+` a la derecha del nodo Webhook (conectarás un nuevo nodo)
2. Busca "If" y selecciona el nodo en forma de diamante llamado **If**
3. Observa que este nodo tiene **dos salidas**: la rama de arriba (True) y la de abajo (False)
4. Configura la condición:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Add Condition` | `String` | Vamos a comparar texto |
   | `Value 1` | Arrastra el campo `nivel` desde el panel de datos | Verás que aparece `{{ $json.nivel }}` |
   | `Operation` | `Equal` | Comparamos si es igual |
   | `Value 2` | `CRITICO` | Solo los que digan exactamente CRITICO pasarán |

**Paso 5: Formatear la alerta (Edit Fields)**

1. En la rama **True** (la de arriba), haz clic en `+` y busca "Edit Fields"
2. Agrega un campo:

   | Campo | Valor |
   |-------|-------|
   | `Name` | `msg_final` |
   | `Value` | `🚨 ATENCION INMEDIATA: Error "{{ $json.error }}" (ID: {{ $json.id }}) necesita revision` |

3. **Explicación:** Las llaves `{{ }}` inyectan datos dinámicos dentro del texto. `$json` es el objeto completo de datos que viaja entre nodos.

**Paso 6: Probar de nuevo**

- Envía otro curl con `nivel: "CRITICO"` → verás que pasa por la rama True
- Envía otro curl con `nivel: "BAJO"` → verás que no pasa por la rama True

#### 📊 Ejemplo de Datos

**Entrada (curl):**
```json
{
  "nivel": "CRITICO",
  "error": "Fallo en el pago",
  "id": 505
}
```

**Salida (Edit Fields, rama True):**
```json
{
  "msg_final": "🚨 ATENCION INMEDIATA: Error \"Fallo en el pago\" (ID: 505) necesita revision"
}
```

**Salida (rama False):**
```
(no hay salida - el If filtró el mensaje)
```

#### ⚠️ Errores Comunes y Soluciones

| Error | Causa | Solución |
|-------|-------|----------|
| Webhook no recibe datos | No activaste "Listen for Test Event" | Vuelve a hacer clic en ese botón antes de enviar curl |
| El If siempre cae en False | `CRITICO` escrito en minúsculas | El If es sensible a mayúsculas; escribe exactamente `CRITICO` |
| curl falla con `(7) Failed to connect` | URL incorrecta o sin internet | Copia la URL exacta desde la pestaña Test de n8n |
| `$json.body` no existe | El webhook se configuró en modo diferente | Verifica que el webhook tenga `POST` y `Response: JSON` |

#### 🎯 Resultado Esperado

Después de completar el laboratorio, deberías tener:
- Un workflow con 3 nodos: Webhook → If → Edit Fields
- Si envías un error CRÍTICO, ves el mensaje formateado en la salida del Edit Fields
- Si envías un error NO crítico, no hay salida (se queda en el If)

**Reto Pro:** Añade una segunda condición al `If` para que solo pase si el `id` es mayor a 100. (Pista: añade una regla "Number" con "> 100")

#### 📚 Referencias

- [Webhook](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [If](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.if/)
- [Edit Fields](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)

---

### Laboratorio 2: Monitor de Precios (HTTP & HTML Scraping)

#### 📋 Descripción del Escenario

Quieres monitorear el precio del Bitcoin desde CoinGecko, pero no quieres pagar una API premium. La solución: "bajarte" la página web completa y extraer solo el número del precio usando selectores CSS.

**¿Por qué scraping?** Porque a veces la única forma de obtener datos es yendo directamente a la página web, especialmente cuando no hay una API pública disponible.

#### ✅ Prerequisites

- [ ] Ninguno - los nodos que usaremos son gratuitos

#### 📝 Paso a Paso Detallado

**Paso 1: Añadir el Trigger**

1. Crea un nuevo workflow
2. Busca "Manual" y selecciona **Manual Trigger**
3. Este nodo no necesita configuración - es simplemente un botón "Ejecutar" que puedes presionar cuando quieras

**Paso 2: Descargar la página web (HTTP Request)**

1. Haz clic en `+` y busca **HTTP Request**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Method` | `GET` |
   | `URL` | `https://www.coingecko.com/es/monedas/bitcoin` |
   | `Response Format` | **Text** (MUY importante) |

3. **¿Por qué text y no JSON?** Una página web es código HTML (como un archivo .txt gigante con etiquetas). No tiene estructura de datos. Por eso necesitamos "raspar" lo que nos interesa.

**Paso 3: Extraer el precio (HTML Node)**

1. Busca y añade el nodo **HTML** (no confundir con "HTML Extract", que es anterior)
2. En `Extraction Values`, haz clic en `Add Value`
3. Configura:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Key` | `precio_bruto` | Nombre que le das al dato extraído |
   | `CSS Selector` | `span[data-coin-symbol="btc"]` | La "dirección" exacta en el HTML |
   | `Return Value` | `Text Content` | Extrae solo el texto, sin etiquetas HTML |

4. **Cómo encontrar el CSS Selector correcto:**
   - Abre la página web en Chrome/Firefox
   - Haz clic derecho sobre el precio del Bitcoin
   - Selecciona "Inspeccionar" (Inspect)
   - Busca en el código HTML un elemento HTML con el precio
   - Fíjate si tiene un atributo como `data-coin-symbol`, `class`, o `id`
   - El selector `span[data-coin-symbol="btc"]` significa: "busca una etiqueta `<span>` que tenga un atributo `data-coin-symbol` con valor `btc`"

**Paso 4: Limpiar el precio (Edit Fields)**

El precio llegará como `$64,500.00` - no puedes hacer cálculos con ese formato.

1. Añade un nodo **Edit Fields**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Name` | `precio_limpio` |
   | `Value` | `{{ $json.precio_bruto.replace('$', '').replace(',', '').trim() }}` |

3. **Explicación de las funciones:**
   - `.replace('$', '')` → Quita el símbolo de dólar
   - `.replace(',', '')` → Quita la coma de separador de miles
   - `.trim()` → Quita espacios en blanco al principio/final

#### 📊 Ejemplo de Datos

**Después de HTML Extract:**
```json
{
  "precio_bruto": "$64,500.00"
}
```

**Después de Edit Fields:**
```json
{
  "precio_bruto": "$64,500.00",
  "precio_limpio": "64500.00"
}
```

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| HTML Extract devuelve vacío | El selector CSS es incorrecto | Inspecciona la página de nuevo; los sitios web cambian su HTML |
| HTTP Request falla (403) | El sitio bloquea scrapers | Añade un header `User-Agent: Mozilla/5.0` en Options del HTTP Request |
| El precio tiene formato extraño | El HTML contiene etiquetas anidadas | Cambia `Return Value` a `Text Content` o `Attribute` |

#### 🎯 Resultado Esperado

Al ejecutar el workflow, obtendrás el precio del Bitcoin como un número limpio (sin $ ni comas), listo para guardar en base de datos o usar en una condición.

**Reto Pro:** Añade un nodo `If` que solo te muestre el precio final si es menor de 50,000. Así sabrás cuándo comprar barato.

#### 📚 Referencias

- [HTTP Request](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [HTML Extract](https://docs.n8n.io/nodes/n8n-nodes-base.html/)
- [Edit Fields](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)

---

### Laboratorio 3: El Limpiador de Leads (JavaScript Avanzado)

#### 📋 Descripción del Escenario

Los usuarios escriben sus datos como les viene en gana: "  jUAN perez  ", "JUAN@GMAIL.COM ", "  +52 55 1234-5678  ". Tu base de datos no acepta ese caos. Necesitas un pipeline de limpieza que estandarice todo antes de guardar.

#### ✅ Prerequisites

- [ ] Ninguno - generaremos datos de prueba con un nodo Code

#### 📝 Paso a Paso Detallado

**Paso 1: Crear datos de prueba**

1. Añade un nodo **Code** (está en la categoría "Helpers")
2. Reemplaza el contenido por defecto con:

   ```javascript
   return [
     { 
       user: "  jUAN perez  ", 
       mail: "JUAN@gmail.com ",
       tel: "+52 55 1234-5678"
     }
   ];
   ```

3. Ejecuta el nodo para ver los datos en el panel izquierdo. Observa cómo vienen con espacios sucios y mayúsculas mezcladas.

**Paso 2: Limpiar el email (Edit Fields)**

1. Conecta un nodo **Edit Fields** al Code
2. Añade un campo:

   | Campo | Valor |
   |-------|-------|
   | `Name` | `email_limpio` |
   | `Value` | `{{ $json.mail.trim().toLowerCase() }}` |

3. `.trim()` elimina espacios al principio/final. `.toLowerCase()` convierte todo a minúsculas.

**Paso 3: Capitalizar el nombre (Code Node)**

1. Conecta otro **Code** al Edit Fields
2. Este código toma el nombre, lo divide en palabras, capitaliza cada una y las une:

   ```javascript
   for (const item of $input.all()) {
     // 1. Quitar espacios y pasar a minúsculas
     let nombre = item.json.user.trim().toLowerCase();
     
     // 2. Dividir en palabras individuales (ej: ["juan", "perez"])
     let palabras = nombre.split(" ");
     
     // 3. Recorrer cada palabra y capitalizar la primera letra
     let final = palabras.map(p => p.charAt(0).toUpperCase() + p.slice(1)).join(" ");
     
     // 4. Guardar el resultado en el item actual
     item.json.nombre_final = final;
   }
   
   return $input.all();
   ```

**Explicación línea por línea:**
- `$input.all()` → obtiene todos los items que llegan al nodo
- `.split(" ")` → convierte "juan perez" en un array ["juan", "perez"]
- `.map(p => ...)` → recorre cada palabra y la transforma
- `p.charAt(0).toUpperCase()` → primera letra en mayúscula
- `p.slice(1)` → el resto de la palabra (desde la posición 1 en adelante)
- `.join(" ")` → vuelve a unir las palabras con un espacio

**Paso 4: Limpiar teléfono**

1. En el mismo Code anterior, puedes agregar (o crear otro Edit Fields):

   ```javascript
   phone: "{{ $json.tel.replace(/[^0-9]/g, '') }}"
   ```

2. Esto usa una expresión regular: "reemplaza todo lo que NO sea dígito (0-9) por vacío"

#### 📊 Ejemplo de Datos

**Entrada:**
```json
{
  "user": "  jUAN perez  ",
  "mail": "JUAN@gmail.com ",
  "tel": "+52 55 1234-5678"
}
```

**Después de Edit Fields (email):**
```json
{
  "email_limpio": "juan@gmail.com"
}
```

**Después de Code (nombre + teléfono):**
```json
{
  "nombre_final": "Juan Perez",
  "tel_limpio": "525512345678"
}
```

#### 📚 Referencias

- [Code](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.code/)
- [Edit Fields](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)

---

### Laboratorio 4: El "Vigilante" de Errores (Error Workflows)

#### 📋 Descripción del Escenario

Has creado flujos de automatización. Pero ¿qué pasa cuando un flujo falla? Si no te enteras, los clientes se quejarán antes de que tú sepas que algo está roto. Necesitas un "Vigilante" que capture cualquier error de cualquier flujo y te notifique al instante.

**¿Cómo funciona?** n8n permite que cada workflow tenga un "Error Workflow" asignado. Si el workflow principal falla, el Error Workflow se ejecuta automáticamente con los detalles del error.

#### ✅ Prerequisites

- [ ] Al menos un workflow normal creado (el que quieres monitorear)

#### 📝 Paso a Paso Detallado

**Paso 1: Crear el workflow de vigilancia**

1. Crea un **nuevo workflow** (Workflows → New)
2. Ponle un nombre, ej: "Vigilante de Errores"
3. Busca y añade el nodo **Error Trigger**
4. Este nodo está en la categoría "Advanced/Helpers"
5. **No necesita configuración** - se activa solo cuando recibe un error

**Paso 2: Dar formato al mensaje de error**

1. Conecta un nodo **Edit Fields** al Error Trigger
2. Añade un campo `mensaje_alerta`:

   ```
   🔴 ERROR en workflow "{{ $json.workflow.name }}"
   
   🕐 Hora: {{ $json.execution.timestamp }}
   
   ❌ Error: {{ $json.execution.error.message }}
   ```

3. **Estructura del objeto de error** que recibes:

   ```json
   {
     "workflow": {
       "name": "Monitor de Precios",
       "id": "12345"
     },
     "execution": {
       "id": "67890",
       "error": {
         "message": "Cannot read property 'replace' of undefined",
         "stack": "..."
       },
       "timestamp": "2024-01-15T10:30:00Z"
     }
   }
   ```

**Paso 3: Enviar la notificación**

1. Conecta el Edit Fields al servicio de notificación que prefieras:
   - **Email:** nodo Email (SMTP)
   - **Slack:** nodo Slack
   - **Telegram:** nodo Telegram
   - **WhatsApp:** nodo WhatsApp Business Cloud
2. En el contenido del mensaje, usa `{{ $json.mensaje_alerta }}`

**Paso 4: Vincular el Vigilante a tus workflows**

1. Ve al workflow que quieres monitorear (NO al Vigilante)
2. Haz clic en el botón ⋯ (tres puntos) arriba a la derecha → **Settings**
3. Busca la opción **Error Workflow** (debajo de "Workflow Settings")
4. En el menú desplegable, selecciona tu workflow "Vigilante de Errores"
5. Guarda los cambios

**Paso 5: Probar la vigilancia**

1. Para probar, fuerza un error en tu workflow principal:
   - Intenta acceder a una propiedad que no existe, ej: `$json.propiedad_inexistente`
   - O usa un nodo HTTP Request con una URL que no existe
2. Al ejecutar, el workflow fallará y automáticamente:
   - Se ejecutará el Vigilante de Errores
   - Recibirás la notificación con los detalles

#### 🎯 Resultado Esperado

- El workflow Vigilante queda "escuchando" (no se ejecuta hasta que otro falle)
- Cuando otro workflow falla, el Vigilante se activa automáticamente
- Recibes un mensaje con: nombre del workflow, timestamp y mensaje de error

#### 📚 Referencias

- [Error Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.errortrigger/)

---

## 🔵 NIVEL 2: INTEGRACIONES Y FLUJOS EMPRESARIALES

### Laboratorio 5: Traductor de Noticias (API Chaining)

#### 📋 Descripción del Escenario

Necesitas consumir una API de frases/noticias en inglés y traducirlas automáticamente al español. Este laboratorio te enseña a "encadenar" APIs: la salida de una es la entrada de la siguiente.

**Concepto:** API Chaining significa que el resultado que te devuelve un servicio (API A) lo usas como parámetro para llamar a otro servicio (API B).

#### ✅ Prerequisites

- [ ] Ninguno - usaremos APIs públicas gratuitas

#### 📝 Paso a Paso Detallado

**Paso 1: Obtener la frase en inglés**

1. Añade un nodo **HTTP Request**
2. Configura:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Method` | `GET` | Solo queremos obtener datos |
   | `URL` | `https://api.quotable.io/random` | API gratuita de frases célebres |
   | `Response Format` | `JSON` | La API devuelve datos estructurados |

3. Ejecuta el nodo para ver el resultado. Deberías ver algo como:

   ```json
   {
     "_id": "abc123",
     "content": "The only way to do great work is to love what you do.",
     "author": "Steve Jobs",
     "tags": ["success", "inspiration"]
   }
   ```

**Paso 2: Traducir la frase al español**

1. Conecta un segundo **HTTP Request** al primero
2. Esta vez haremos un **POST** (porque estamos enviando datos a traducir)
3. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Method` | `POST` |
   | `URL` | `https://libretranslate.de/translate` |
   | `Response Format` | `JSON` |

4. En la sección **Body Parameters** (importante: debajo de "Body"):
   - Cambia "Body Content Type" a `JSON`
   - Añade estos parámetros:

   | Name | Value |
   |------|-------|
   | `q` | `{{ $json.content }}` |
   | `source` | `en` |
   | `target` | `es` |

5. **Explicación:** `q` es el texto a traducir. `source` y `target` son los idiomas de origen y destino. `en` = inglés, `es` = español.

#### 📊 Ejemplo de Datos

**Salida del primer HTTP Request (quotable):**
```json
{
  "content": "The only way to do great work is to love what you do.",
  "author": "Steve Jobs"
}
```

**Salida del segundo HTTP Request (libretranslate):**
```json
{
  "translatedText": "La única forma de hacer un gran trabajo es amar lo que haces."
}
```

**O también podrías ver:**
```json
[{"detectedLanguage": {"confidence": 95, "language": "en"}, "translatedText": "..."}]
```

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| LibreTranslate devuelve 429 Too Many Requests | Límite de la API gratuita | Espera 1 minuto y reintenta |
| El body parameter `q` no se envía | No seleccionaste JSON en Body Content Type | Cambia a `JSON` en el dropdown |
| La traducción está en inglés | `target` está mal escrito | Verifica que sea `es` no `español` |

#### 🎯 Resultado Esperado

Obtienes una frase en inglés desde la API de citas, la pasas por el traductor, y recibes la frase traducida al español. Un solo flujo conecta dos servicios.

#### 📚 Referencias

- [HTTP Request](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)

---

### Laboratorio 6: Sincronizador Supabase → Google Sheets

#### 📋 Descripción del Escenario

Tienes datos de usuarios en Supabase (base de datos PostgreSQL) pero tu equipo administrativo usa Google Sheets para hacer reportes. Necesitas copiar automáticamente los datos de la base de datos a la hoja de cálculo cada vez que se agrega un nuevo usuario.

#### ✅ Prerequisites

- [ ] Proyecto en [Supabase](https://supabase.com) con tabla `usuarios`
- [ ] Cuenta de Google (Gmail/Sheets)
- [ ] Credenciales de Google configuradas en n8n (Settings → Credentials → Google)

#### 📝 Paso a Paso Detallado

**Paso 1: Configurar Supabase**

1. Si es tu primera vez, ve a Supabase y crea una tabla `usuarios` con:
   ```sql
   CREATE TABLE usuarios (
     id SERIAL PRIMARY KEY,
     email TEXT NOT NULL,
     nombre TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW()
   );
   ```
2. En n8n, añade el nodo **Supabase** (Settings → Credentials si necesitas conectar)
3. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Get Many` |
   | `Table` | `usuarios` |
   | `Return All` | Activo |

**Paso 2: Configurar Google Sheets**

1. Añade el nodo **Google Sheets** conectado al Supabase
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Append` |
   | `Spreadsheet ID` | El ID de tu hoja (lo ves en la URL) |
   | `Sheet Name` | `Usuarios` (nombre de la pestaña) |
   | `Columns Mapping` | `email` → Columna A, `nombre` → Columna B |

3. **Column Mapping:** En la sección "Options" puedes mapear manualmente qué campo de Supabase va a qué columna de Sheets

**Paso 3: Programar la ejecución**

1. En lugar de Manual Trigger, usa **Schedule Trigger** al inicio
2. Configura `Every Hour` o `Every Day` según necesites
3. Así los datos se sincronizan automáticamente

#### 📊 Ejemplo de Datos

**Datos en Supabase:**
| id | email | nombre | created_at |
|----|-------|--------|------------|
| 1 | juan@email.com | Juan Perez | 2024-01-15 |
| 2 | maria@email.com | Maria García | 2024-01-16 |

**Después de la sincronización, en Sheets:**
| Email | Nombre |
|-------|--------|
| juan@email.com | Juan Perez |
| maria@email.com | Maria García |

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| Google Sheets no encuentra la hoja | Sheets ID incorrecto | Abre la hoja en Google y copia el ID de la URL |
| Los datos se duplican en cada ejecución | No hay filtro de filas nuevas | Añade un Code antes que filtre por `created_at > ultima_sincro` |
| Supabase no conecta | Credenciales no configuradas | Ve a Settings → Credentials → Añadir Supabase |

#### 🎯 Resultado Esperado

Cada vez que se ejecute el workflow, los datos de Supabase aparecen en Google Sheets. El equipo administrativo ve la info sin tener acceso a la base de datos.

#### 📚 Referencias

- [Supabase](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/)
- [Google Sheets](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.googleSheets/)

---

### Laboratorio 7: El Sistema de Envío por Lotes (Batching)

#### 📋 Descripción del Escenario

Tienes 500 mensajes que enviar por WhatsApp/Email, pero la API de Meta (WhatsApp Business) bloquea tu cuenta si envías más de 1 mensaje por segundo. Necesitas procesar los envíos de uno en uno, con una pausa entre cada uno.

**Solución:** Usar el nodo **Split In Batches** + un **Wait** + devolver la salida a la entrada (loop).

#### ✅ Prerequisites

- [ ] Ninguno para la lógica base (usaremos datos simulados)

#### 📝 Paso a Paso Detallado

**Paso 1: Generar la lista de destinatarios**

1. Añade un nodo **Code** con datos simulados:

   ```javascript
   return [
     { tel: "+5215512345678", nombre: "Cliente 1" },
     { tel: "+5215512345679", nombre: "Cliente 2" },
     { tel: "+5215512345680", nombre: "Cliente 3" },
     { tel: "+5215512345681", nombre: "Cliente 4" },
     { tel: "+5215512345682", nombre: "Cliente 5" }
   ];
   ```

2. En la vida real, aquí conectarías un nodo de Supabase, Sheets, o una API.

**Paso 2: El Divisor (Split In Batches)**

1. Conecta el Code a un nodo **Split In Batches**
2. Configura:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Batch Size` | `1` | Procesa UN elemento a la vez |
   | `Options → Save Batch Progress` | Activo | Si el flujo se corta, continúa donde quedó |

3. **Cómo funciona:** Si entran 5 elementos, el Split:
   - Primero: envía el elemento 1 por la salida principal
   - Guarda los elementos 2, 3, 4, 5 en "espera"
   - Cuando la salida principal se completa, envía el elemento 2
   - Repite hasta que no queden elementos
   - Cuando termina todos, activa la salida "Done"

**Paso 3: La pausa (Wait)**

1. Conecta la salida del Split a un nodo **Wait**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Wait Amount` | `10` |
   | `Wait Unit` | `seconds` |

3. Esto pausa la ejecución 10 segundos entre cada envío. Sin esta pausa, la API de Meta bloquearía tus mensajes.

**Paso 4: La acción (lo que quieras hacer con cada elemento)**

1. Conecta un nodo **Edit Fields** al Wait:

   | Campo | Valor |
   |-------|-------|
   | `Name` | `mensaje_enviado` |
   | `Value` | `Enviando recordatorio a {{ $json.nombre }} ({{ $json.tel }})` |

2. Aquí en la vida real pondrías un nodo de WhatsApp, Email, etc.

**Paso 5: El Loop (MUY IMPORTANTE)**

1. Conecta la **salida del Edit Fields** de vuelta a la **entrada del Split In Batches**
2. Así se forma el ciclo: Split → Wait → Acción → Split → Wait → Acción → ...
3. Cuando no quedan más elementos, el Split activa la rama "Done"
4. La rama "Done" la puedes conectar a un nodo final (ej: "Se enviaron todos los mensajes")

#### 📊 Diagrama del Flujo

```
[Code: Lista de 5 clientes]
       ↓
[Split In Batches (batch=1)]
       ↓ (envía 1 cliente)
[Wait 10s]
       ↓
[Edit Fields / WhatsApp]
       ↓
┌─────────────────────────┐
│  (vuelve al Split)      │  ← Loop hasta que no queden más
└─────────────────────────┘

Cuando termina:
[Split] → (rama "Done") → [Log: "Todos enviados"]
```

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| Loop infinito | No conectaste la salida al Split | Conecta el último nodo → entrada del Split |
| El Wait no pausa | Wait está antes del Split | El Wait debe ir DESPUÉS del Split |
| Split no procesa todos | Batch Size mayor que 1 | Pon Batch Size = 1 para proceso individual |

#### 🎯 Resultado Esperado

- El flujo procesa un elemento cada 10 segundos
- Puedes ver en los logs cómo va uno por uno
- Cuando termina, se activa la rama "Done"

#### 📚 Referencias

- [Loop Over Items (Split In Batches)](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.splitinbatches/)
- [Wait](https://docs.n8n.io/nodes/n8n-nodes-base.wait/)

---

### Laboratorio 8: Inspector de Binarios (Seguridad)

#### 📋 Descripción del Escenario

Tu aplicación permite subir archivos (imágenes, PDFs). Pero no puedes confiar ciegamente: necesitas verificar tamaño, tipo, y extensión antes de aceptarlos. Si un usuario sube un archivo de 500MB, tu servidor colapsará.

#### ✅ Prerequisites

- [ ] URL de un archivo para probar (ej: imagen o PDF público)

#### 📝 Paso a Paso Detallado

**Paso 1: Descargar el archivo binario**

1. Añade un nodo **HTTP Request**
2. Configura:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Method` | `GET` | Descarga simple |
   | `URL` | `https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf` | PDF de prueba |
   | `Response Format` | `File` | ¡CRUCIAL! Esto preserva el archivo binario |

3. **¿Qué pasa si pones JSON?** El archivo se corrompe. Siempre usa "File" cuando descargues archivos binarios.

**Paso 2: Obtener metadatos del archivo**

1. Conecta un nodo **Extract from File** (o **Read Binary Files**)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Get Metadata` |
   | `File` | El binary del paso anterior (arrastra desde el panel de datos) |

3. Esto extraerá información como:

   ```json
   {
     "fileName": "dummy.pdf",
     "fileSize": 12345,
     "mimeType": "application/pdf",
     "extension": "pdf"
   }
   ```

**Paso 3: Validar el tamaño (If Node)**

1. Conecta un nodo **If** al Extract
2. Configura la condición:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Add Condition` | `Number` | Vamos a comparar números |
   | `Value 1` | `{{ $json.fileSize }}` | El tamaño del archivo en bytes |
   | `Operation` | `Less Than` | Menor que... |
   | `Value 2` | `1000000` | 1MB en bytes (1000000 bytes = ~1 MB) |

3. **Conversión rápida de bytes a megabytes:**
   - 1 KB = 1024 bytes
   - 1 MB = 1,048,576 bytes
   - 1000000 bytes ≈ 1 MB

**Paso 4: Rutas según resultado**

- **Rama True (archivo apto):** Procesar normalmente (guardar, enviar, etc.)
- **Rama False (archivo muy grande):** Rechazar, ej: Edit Fields con mensaje de error

#### 📊 Tabla de Tipos MIME Comunes

| Extensión | MIME Type |
|-----------|-----------|
| .pdf | application/pdf |
| .jpg / .jpeg | image/jpeg |
| .png | image/png |
| .docx | application/vnd.openxmlformats-officedocument.wordprocessingml.document |

#### 🎯 Resultado Esperado

- Sabes el tamaño del archivo en bytes
- Sabes la extensión y el tipo MIME
- Decides si aceptarlo o rechazarlo según el tamaño

#### 📚 Referencias

- [HTTP Request](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [Extract from File](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.extractfromfile/)

---

## 🟡 NIVEL 3: WHATSAPP BUSINESS (AUTOMATIZACIÓN REAL)

### Laboratorio 9: Recordatorio de Citas Automático

#### 📋 Descripción del Escenario

Tienes un consultorio/negocio con clientes que tienen citas. Cada día a las 9 AM, necesitas que automáticamente se envíe un recordatorio por WhatsApp a todos los que tienen cita hoy. Esto reduce las ausencias ("no shows") y mejora la satisfacción.

#### ✅ Prerequisites

- [ ] Cuenta de WhatsApp Business API (Meta Business)
- [ ] Nodo de WhatsApp Business Cloud configurado en n8n
- [ ] Base de datos con tabla de citas (Supabase, Sheets, etc.)
- [ ] Una plantilla de WhatsApp aprobada por Meta (Template)

#### 📝 Paso a Paso Detallado

**Paso 1: Programar la ejecución diaria**

1. Añade un nodo **Schedule Trigger**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Trigger Times` | `Every Day` |
   | `At` | `09:00` |

3. También puedes usar una expresión Cron: `0 9 * * *` (a las 9:00 AM todos los días)

**Paso 2: Consultar las citas del día**

1. Conecta un nodo **Supabase** o **Google Sheets** (según donde tengas los datos)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Get Many` |
   | `Table` | `citas` |
   | `Filter` | `fecha = today()` (o la función que corresponda) |

3. **Filtrar por fecha de hoy:** Si usas Supabase, en la sección "Filters":
   - `Field`: `fecha`
   - `Operator`: `Equal`
   - `Value`: `{{ new Date().toISOString().split('T')[0] }}` (est expresión da la fecha de hoy)

**Paso 3: Enviar el recordatorio por WhatsApp**

1. Conecta el nodo **WhatsApp Business Cloud**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Send Template` |
   | `Template Name` | `recordatorio_cita` (debe estar aprobada por Meta) |
   | `Phone Number` | `{{ $json.telefono }}` |
   | `Parameters` | Completa según tu plantilla |

3. **Ejemplo de plantilla de WhatsApp:**

   ```
   Hola {{1}}, te recordamos que tienes una cita hoy a las {{2}}.
   Por favor confirma tu asistencia respondiendo "SÍ".
   ```

   - `{{1}}` se reemplaza con `{{ $json.nombre }}`
   - `{{2}}` se reemplaza con `{{ $json.hora }}`

**Paso 4: Manejar múltiples citas**

- Si hay 10 clientes con cita hoy, el flujo procesará automáticamente cada uno
- Puedes combinarlo con el Lab 7 (Batching) si necesitas pausas entre envíos

#### 📊 Ejemplo de Datos

**Desde la base de datos:**
```json
{
  "nombre": "Juan Pérez",
  "telefono": "+5215512345678",
  "fecha": "2024-01-15",
  "hora": "14:00"
}
```

**Mensaje que recibe el cliente:**
> "Hola Juan Pérez, te recordamos que tienes una cita hoy a las 14:00. Por favor confirma tu asistencia respondiendo SÍ."

#### 📚 Referencias

- [Schedule Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.scheduletrigger/)
- [Supabase](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/)
- [WhatsApp Business Cloud](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.whatsapp/)

---

### Laboratorio 10: Chatbot de Respuesta Automática (Palabras Clave)

#### 📋 Descripción del Escenario

Clientes te escriben por WhatsApp preguntando sobre precios, horarios, ubicación, etc. Quieres que un chatbot responda automáticamente sin que tengas que contestar cada mensaje manualmente.

**¿Cómo funciona?** Detectas palabras clave en el mensaje y diriges la conversación según lo que el cliente pregunte.

#### ✅ Prerequisites

- [ ] Nodo de WhatsApp Business Cloud configurado
- [ ] Conocimiento de las preguntas frecuentes de tu negocio

#### 📝 Paso a Paso Detallado

**Paso 1: Escuchar los mensajes entrantes**

1. Añade el nodo **WhatsApp Business Cloud**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Event` | `Message Received` |

3. Este nodo activará el flujo CADA VEZ que alguien te envíe un mensaje. Sin necesidad de schedule, sin necesidad de webhook.

**Paso 2: Normalizar el texto**

1. Conecta un nodo **Edit Fields**
2. Añade:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Name` | `texto_normalizado` | Nombre del campo |
   | `Value` | `{{ $json.message.body.toLowerCase().trim() }}` | Convierte a minúsculas y quita espacios |

3. **¿Por qué es importante?** Si el cliente escribe "PRECIO", "Precio", o "  precio  ", con esta normalización los tratamos igual.

**Paso 3: El Enrutador (Switch Node)**

1. Conecta un nodo **Switch** (es como un If pero con múltiples rutas)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Data Type to Route` | `String` |
   | `Value` | `{{ $json.texto_normalizado }}` |

3. Añade rutas según las preguntas frecuentes de tu negocio:

   | Ruta | Condición | Ejemplo de mensaje del cliente |
   |------|-----------|-------------------------------|
   | Ruta 1: Precios | `Contains → precio` | "¿Cuánto cuesta?", "precios" |
   | Ruta 2: Ubicación | `Contains → donde` o `contains → ubicacion` | "¿Dónde están?" |
   | Ruta 3: Horario | `Contains → horario` o `contains → hora` | "¿A qué hora abren?" |
   | Ruta Default | (ninguna) | Para preguntas no clasificadas |

**Paso 4: Responder según cada ruta**

Para cada ruta, conecta un nodo **WhatsApp Business Cloud**:

| Campo | Valor |
|-------|-------|
| `Operation` | `Send Text` |
| `Phone Number` | `{{ $json.from }}` (el número que nos escribió) |
| `Message` | La respuesta correspondiente |

- **Ruta Precios:** "Nuestros planes: Básico $199/mes, Premium $399/mes. ¿Te interesa algún plan?"
- **Ruta Ubicación:** "Estamos en Av. Principal 123, Col. Centro. Te enviaré la ubicación."
- **Ruta Horario:** "Abrimos de lunes a viernes de 9:00 a 18:00, sábados de 9:00 a 14:00."
- **Default:** "Gracias por contactarnos. Un agente te responderá pronto. ¿De qué trata tu consulta?"

#### 📊 Ejemplo de Conversación

```
Cliente: "¿Tienen precios de mensualidades?"
       ↓ (webhook recibe)
       ↓ (Switch detecta "precios")
       ↓ (Ruta Precios)
Bot: "Nuestros planes: Básico $199/mes, Premium $399/mes. ¿Te interesa algún plan?"
```

#### 🎯 Resultado Esperado

- El cliente escribe cualquier mensaje
- El flujo detecta automáticamente el tema
- Responde con la información correspondiente
- Si no entiende, pasa a un agente humano

#### 📚 Referencias

- [WhatsApp Business Cloud](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.whatsapp/)
- [Edit Fields](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)
- [Switch](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.switch/)

---

### Laboratorio 11: Envío de Facturas PDF por WhatsApp

#### 📋 Descripción del Escenario

Un cliente hace una compra en tu tienda online. Necesitas enviarle automáticamente la factura en PDF por WhatsApp. Sin emails, sin descargas manuales - el PDF llega directo al chat del cliente.

#### ✅ Prerequisites

- [ ] Nodo de WhatsApp Business Cloud
- [ ] URL donde se genera/almacena el PDF (puede ser un endpoint de tu API)

#### 📝 Paso a Paso Detallado

**Paso 1: Recibir la notificación de compra**

1. Añade un nodo **Webhook** (o un Schedule Trigger si revisas compras pendientes)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `HTTP Method` | `POST` |
   | `Path` | `compra-realizada` |

3. Datos de entrada esperados:

   ```json
   {
     "cliente": "Juan Pérez",
     "telefono": "+5215512345678",
     "factura_id": "FAC-2024-001",
     "pdf_url": "https://tuservidor.com/facturas/fac-2024-001.pdf"
   }
   ```

**Paso 2: Descargar el PDF**

1. Conecta un nodo **HTTP Request**
2. Configura:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `Method` | `GET` | Descargar el PDF |
   | `URL` | `{{ $json.pdf_url }}` | La URL viene del webhook |
   | `Response Format` | `File` | ¡IMPORTANTE! Preserva el binario del PDF |

**Paso 3: Enviar el PDF por WhatsApp**

1. Conecta un nodo **WhatsApp Business Cloud**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Send Document` |
   | `Phone Number` | `{{ $json.telefono }}` (viene del webhook) |
   | `File` | Selecciona el binary descargado (panel de datos) |
   | `Filename` | `factura-{{ $json.factura_id }}.pdf` |
   | `Caption` | `Hola {{ $json.cliente }}, gracias por tu compra. Adjuntamos tu factura.` |

#### 📊 Ejemplo de Datos

**Entrada (webhook):**
```json
{
  "cliente": "Juan Pérez",
  "telefono": "+5215512345678",
  "factura_id": "FAC-2024-001"
}
```

**Lo que recibe el cliente en WhatsApp:**
> Documento: factura-FAC-2024-001.pdf
> Caption: "Hola Juan Pérez, gracias por tu compra. Adjuntamos tu factura."

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| WhatsApp recibe archivo corrupto | HTTP Request no usó Response Format: File | Cambia a `Response Format: File` |
| El documento no se envía | Tamaño máximo excedido (WhatsApp limita a 100MB) | Comprime el PDF o verifica el tamaño |
| Error "invalid file" | El archivo no es realmente PDF | Verifica que la URL devuelva un PDF válido |

#### 🎯 Resultado Esperado

Cuando se activa el flujo, el cliente recibe un WhatsApp con el PDF de su factura adjunto, sin intervención humana.

#### 📚 Referencias

- [Webhook](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [HTTP Request](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)
- [WhatsApp Business Cloud](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.whatsapp/)

---

### Laboratorio 12: Data Entry vía WhatsApp (Comandos)

#### 📋 Descripción del Escenario

Estás fuera de la oficina y necesitas agregar un cliente urgente al CRM. No tienes acceso al sistema, pero sí a WhatsApp. ¿Y si pudieras enviar un mensaje con un formato especial y el sistema lo guardara automáticamente?

**Solución:** Un comando de texto como `ADD Juan Perez, +5215512345678, juan@email.com` es detectado, parseado y guardado en la base de datos.

#### ✅ Prerequisites

- [ ] Nodo de WhatsApp Business Cloud
- [ ] Base de datos (Supabase o Sheets) para guardar los datos

#### 📝 Paso a Paso Detallado

**Paso 1: Definir el formato del comando**

Acuerda un formato simple y consistente. Ejemplo:
```
ADD <nombre>, <telefono>, <email>
```

Ejemplo real:
```
ADD Juan Pérez, +5215512345678, juan@email.com
```

**Paso 2: Escuchar el mensaje**

1. Añade el nodo **WhatsApp Business Cloud**
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Event` | `Message Received` |

**Paso 3: Parsear y extraer datos**

1. Conecta un nodo **Edit Fields** al WhatsApp
2. Extraemos cada parte del mensaje usando las comas como separadores:

   | Campo | Valor | Explicación |
   |-------|-------|-------------|
   | `nombre` | `{{ $json.message.body.replace('ADD ', '').split(',')[0].trim() }}` | Quita "ADD ", toma hasta la primera coma y limpia espacios |
   | `telefono` | `{{ $json.message.body.split(',')[1].trim() }}` | Toma entre la 1ra y 2da coma |
   | `email` | `{{ $json.message.body.split(',')[2].trim() }}` | Toma después de la 2da coma |

3. **Explicación de la expresión:**

   Para `nombre`:
   - `$json.message.body` = "ADD Juan Pérez, +5215512345678, juan@email.com"
   - `.replace('ADD ', '')` = "Juan Pérez, +5215512345678, juan@email.com"
   - `.split(',')[0]` = "Juan Pérez"
   - `.trim()` = "Juan Pérez"

**Paso 4: Validar que los datos sean correctos**

1. Conecta un nodo **If** para asegurarte de que los campos no estén vacíos
2. Condiciones:
   - `$json.nombre` → Not Empty
   - `$json.telefono` → Not Empty
   - `$json.email` → Not Empty

**Paso 5: Guardar en la base de datos**

1. Conecta un nodo **Supabase** (o **Google Sheets**)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Insert` |
   | `Table` | `clientes` |
   | `Data` | Mapea los campos: nombre, telefono, email |

**Paso 6: Confirmar al usuario**

1. Conecta un nodo **WhatsApp Business Cloud** (envío de vuelta)
2. Configura:

   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Send Text` |
   | `Phone` | `{{ $json.from }}` (el que envió el comando) |
   | `Message` | `✅ Cliente agregado correctamente: {{ $json.nombre }} ({{ $json.telefono }})` |

#### 📊 Ejemplo de Datos

**Mensaje recibido por WhatsApp:**
```
ADD Maria García, +5215587654321, maria@test.com
```

**Parseado por Edit Fields:**
```json
{
  "nombre": "Maria García",
  "telefono": "+5215587654321",
  "email": "maria@test.com"
}
```

**Confirmación que recibe el usuario:**
> ✅ Cliente agregado correctamente: Maria García (+5215587654321)

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| Los campos salen undefined | El formato del mensaje no coincide | Verifica que el mensaje tenga exactamente el formato `ADD nombre, telefono, email` |
| Se guardan con espacios | No usaste `.trim()` en el Edit Fields | Añade `.trim()` a cada expresión |
| El Switch no detecta "ADD" | No normalizaste el texto | Usa `.toUpperCase()` o busca en mayúsculas |

#### 🎯 Resultado Esperado

- Envías un WhatsApp con el formato `ADD nombre, telefono, email`
- El flujo parsea automáticamente los datos
- Los guarda en la base de datos
- Recibes una confirmación de que se agregó correctamente

#### 📚 Referencias

- [WhatsApp Business Cloud](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.whatsapp/)
- [Edit Fields](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.set/)
- [Supabase](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.supabase/)

---

---

## 🟣 NIVEL 4: BACKEND, INFRAESTRUCTURA Y PRODUCCIÓN

### Laboratorio 13: API Gateway con JWT + Postgres

#### 📋 Descripción del Escenario

Tu backend de Flutter necesita un endpoint seguro que solo responda si el cliente presenta un token JWT válido. Vas a construir un "API Gateway" casero con n8n: un webhook que valida el token, consulta la base de datos y responde solo si la autenticación es correcta.

**Concepto:** JWT (JSON Web Token) es como un "carnet digital" que demuestra que un usuario está autenticado. El servidor lo firma con una clave secreta y el cliente lo presenta en cada petición.

#### ✅ Prerequisites

- [ ] n8n funcionando (local o cloud)
- [ ] Base de datos Postgres o MySQL (puede ser Supabase)
- [ ] Curl o Postman para probar

#### 📝 Paso a Paso Detallado

**Paso 1: Crear la tabla de usuarios en Postgres**

Ejecuta esta SQL en tu base de datos (o créala desde Supabase):
```sql
CREATE TABLE usuarios (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  nombre TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO usuarios (email, password_hash, nombre) VALUES
('juan@test.com', 'abc123hash', 'Juan Pérez'),
('maria@test.com', 'def456hash', 'Maria García');
```

**Paso 2: El Trigger (Webhook Login)**

1. Crea un nuevo workflow.
2. Añade un nodo **Webhook**:
   | Campo | Valor |
   |-------|-------|
   | `HTTP Method` | `POST` |
   | `Path` | `login` |

3. Haz clic en **Listen for Test Event**.

**Paso 3: Consultar el usuario en Postgres**

1. Conecta un nodo **Postgres** al Webhook.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Execute Query` |
   | `Query` | `SELECT * FROM usuarios WHERE email = $1` |
   | `Query Parameters` | `[{{ $json.body.email }}]` |

3. **¿Por qué `$1`?** Porque parametrizar la query previene SQL Injection. Nunca pongas `{{ $json.body.email }}` directamente dentro del SQL.

**Paso 4: Validar que el usuario existe**

1. Conecta un nodo **If** al Postgres.
2. Condición: `$json` → `Is Not Empty` (si el SELECT devolvió algo, el usuario existe).

**Paso 5: Generar el JWT**

1. En la rama **True** (usuario existe), conecta un nodo **JWT**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Sign` |
   | `Token Payload` | `{{ { "id": $json.id, "email": $json.email, "nombre": $json.nombre } }}` |
   | `Secret or Private Key` | `mi-clave-super-secreta-2024` |
3. En **Options**:
   | Campo | Valor |
   |-------|-------|
   | `Algorithm` | `HS256` |
   | `Expires In` | `24h` |

**Paso 6: Responder con el token**

1. Conecta un nodo **Respond to Webhook** al JWT.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Respond with` | `JSON` |
   | `Response Body` | `{ "token": "{{ $json.token }}", "usuario": "{{ $json.nombre }}" }` |

#### 📊 Ejemplo de Datos

**Petición (curl):**
```bash
curl -X POST "https://tun8n.com/webhook-test/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "juan@test.com"}'
```

**Respuesta exitosa:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwiZW1haWwiOiJqdWFuQHRlc3QuY29tIiwibm9tYnJlIjoiSnVhbiBQZXJleiIsImlhdCI6MTcwNTMyMTIzNCwiZXhwIjoxNzA1NDA3NjM0fQ...",
  "usuario": "Juan Pérez"
}
```

**Respuesta si el usuario no existe:**
```json
{
  "error": "Usuario no encontrado"
}
```

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| JWT devuelve error "invalid algorithm" | No seleccionaste HS256 en Options | Ve a Options → Algorithm → HS256 |
| Postgres no encuentra tabla | La tabla está en otro schema | Usa `SELECT * FROM public.usuarios` |
| El token expira muy rápido | No configuraste Expires In | Pon `24h` o `7d` en Options |
| `$json.body` está vacío | No activaste Listen for Test Event | Vuelve a hacer clic en el botón antes del curl |

#### 🎯 Resultado Esperado

- Envías un email por POST → recibes un JWT firmado.
- Envías un email que no existe → recibes error.
- El token contiene los datos del usuario y expira en 24h.
- Puedes verificar el token en [jwt.io](https://jwt.io) con la clave `mi-clave-super-secreta-2024`.

**Reto Pro:** Añade una validación de contraseña. En lugar de solo buscar por email, compara `password_hash` con un hash SHA256 del password recibido (usa el nodo **Crypto**).

#### 📚 Referencias

- [Postgres](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)
- [JWT](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.jwt/)
- [Crypto](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.crypto/)

---

### Laboratorio 14: Backend CRUD de Usuarios (Postgres)

#### 📋 Descripción del Escenario

Necesitas un backend completo para gestionar usuarios: Crear, Leer, Actualizar y Eliminar (CRUD) usando solo n8n como "servidor backend". Tu app Flutter se comunicará con estos endpoints vía HTTP.

#### ✅ Prerequisites

- [ ] Base de datos Postgres con tabla `usuarios` (del lab anterior)
- [ ] Conocimiento de métodos HTTP (GET, POST, PUT, DELETE)

#### 📝 Paso a Paso Detallado

Vas a crear **4 workflows separados**, uno para cada operación CRUD. Cada uno usará un path de webhook diferente.

**Workflow A: CREATE (POST /usuarios)**

1. Crea un nuevo workflow "Crear Usuario".
2. **Webhook:** POST, Path: `usuarios`.
3. **Crypto (Hash):**
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Hash` |
   | `Fields` | `password` |
   | `Options → Algorithm` | `sha256` |
4. **Postgres (Insert):**
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Insert` |
   | `Table` | `usuarios` |
   | `Columns` | Mapea: email, password_hash, nombre |
5. **Respond to Webhook:** JSON con `{ "id": $json.id, "mensaje": "Usuario creado" }`.

**Workflow B: READ (GET /usuarios)**

1. Nuevo workflow "Listar Usuarios".
2. **Webhook:** GET, Path: `usuarios`.
3. **Postgres (Select):**
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Select` |
   | `Table` | `usuarios` |
   | `Return All` | Activo |
4. **Respond to Webhook:** JSON con la lista.

**Workflow C: UPDATE (PUT /usuarios)**

1. Nuevo workflow "Actualizar Usuario".
2. **Webhook:** PUT, Path: `usuarios`.
3. **Postgres (Update):**
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Update` |
   | `Table` | `usuarios` |
   | `Update Key` | `id` (columna para identificar el registro) |
4. **Respond to Webhook:** Confirmación.

**Workflow D: DELETE (DELETE /usuarios)**

1. Nuevo workflow "Eliminar Usuario".
2. **Webhook:** DELETE, Path: `usuarios`.
3. **Postgres (Delete):**
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Delete` |
   | `Table` | `usuarios` |
   | `Delete Key` | `id` |
4. **Respond to Webhook:** Confirmación.

#### 📊 Resumen de Endpoints

| Método | Path | Body/Params | Acción |
|--------|------|-------------|--------|
| POST | /usuarios | `{ email, password, nombre }` | Crear usuario |
| GET | /usuarios | (ninguno) | Listar todos |
| PUT | /usuarios | `{ id, nombre }` | Actualizar nombre |
| DELETE | /usuarios | `{ id }` | Eliminar usuario |

#### 🎯 Resultado Esperado

Tienes 4 endpoints HTTP que funcionan como un backend REST real. Tu app Flutter puede hacer peticiones a estos webhooks y gestionar usuarios en la base de datos.

**Reto Pro:** Añade un quinto workflow que sea "GET /usuarios/:id" usando un query parameter. (Pista: usa `$json.body.id` o parámetros de URL).

#### 📚 Referencias

- [Postgres](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)
- [Webhook](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [Crypto](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.crypto/)

---

### Laboratorio 15: Pipeline de Reporting Automatizado (Summarize)

#### 📋 Descripción del Escenario

Cada semana, tu jefe te pide un reporte de ventas: cuánto vendió cada vendedor, cuántas ventas hizo, y el ticket promedio. Hacerlo manual toma 2 horas. Vamos a automatizarlo con Summarize.

#### ✅ Prerequisites

- [ ] Base de datos con una tabla `ventas` (o datos simulados con Code)
- [ ] Cuenta de email configurada en n8n (Send Email)

#### 📝 Paso a Paso Detallado

**Paso 1: Generar o consultar datos de ventas**

Opción A (datos reales - Postgres):
1. Añade un nodo **Schedule Trigger** (cada lunes 8 AM).
2. Conecta **Postgres**: `SELECT * FROM ventas WHERE fecha >= NOW() - INTERVAL '7 days'`.

Opción B (datos simulados - Code):
```javascript
return [
  { vendedor: "Ana", producto: "Laptop", monto: 1200, fecha: "2024-01-01" },
  { vendedor: "Luis", producto: "Mouse", monto: 25, fecha: "2024-01-02" },
  { vendedor: "Ana", producto: "Monitor", monto: 300, fecha: "2024-01-03" },
  { vendedor: "Pedro", producto: "Teclado", monto: 80, fecha: "2024-01-04" },
  { vendedor: "Luis", producto: "Laptop", monto: 1100, fecha: "2024-01-05" },
  { vendedor: "Ana", producto: "Mouse", monto: 25, fecha: "2024-01-06" },
  { vendedor: "Pedro", producto: "Monitor", monto: 350, fecha: "2024-01-07" }
];
```

**Paso 2: Agrupar y resumir (Summarize)**

1. Conecta un nodo **Summarize**.
2. Configura:

**Group By:**
| Campo | Valor |
|-------|-------|
| `Field to Group By` | `vendedor` |

**Values (puedes añadir varios):**
| Operation | Field | Alias |
|-----------|-------|-------|
| `Sum` | `monto` | `total_vendido` |
| `Count` | `vendedor` | `cantidad_ventas` |
| `Average` | `monto` | `ticket_promedio` |

**Paso 3: Ordenar por total vendido (Sort)**

1. Conecta un nodo **Sort**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Sort Fields → Field` | `total_vendido` |
   | `Sort Fields → Order` | `Descending` |

**Paso 4: Formatear como tabla (Data Table)**

1. Conecta un nodo **Data Table**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Format` | `Markdown` |
   | `Fields to Include` | `vendedor, total_vendido, cantidad_ventas, ticket_promedio` |

**Paso 5: Enviar por email (Send Email)**

1. Conecta un nodo **Send Email**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `To` | `jefe@midominio.com` |
   | `Subject` | `📊 Reporte semanal de ventas - {{ $now.toFormat('dd/MM') }}` |
   | `HTML` | `{{ $json.html }}` (si usaste HTML en Data Table) o `{{ $json.data }}` para Markdown |

#### 📊 Ejemplo de Datos

**Salida del Summarize:**
```json
[
  { "vendedor": "Ana", "total_vendido": 1525, "cantidad_ventas": 3, "ticket_promedio": 508.33 },
  { "vendedor": "Luis", "total_vendido": 1125, "cantidad_ventas": 2, "ticket_promedio": 562.50 },
  { "vendedor": "Pedro", "total_vendido": 430,  "cantidad_ventas": 2, "ticket_promedio": 215.00 }
]
```

**Correo que recibe el jefe:**
```
📊 Reporte semanal de ventas - 15/01

| Vendedor | Total   | Ventas | Promedio |
|----------|---------|--------|----------|
| Ana      | $1,525  | 3      | $508.33  |
| Luis     | $1,125  | 2      | $562.50  |
| Pedro    | $430    | 2      | $215.00  |
```

#### 🎯 Resultado Esperado

- Cada lunes a las 8 AM recibes un correo con el reporte de ventas.
- No tienes que hacer nada manualmente.
- Los datos están agrupados, ordenados y formateados como tabla.

**Reto Pro:** Añade un nodo **Convert to File** para exportar el reporte a CSV y adjuntarlo al correo.

#### 📚 Referencias

- [Summarize](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.summarize/)
- [Data Table](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.datatable/)
- [Send Email](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.sendemail/)
- [Convert to File](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.converttofile/)

---

### Laboratorio 16: Sistema de Backup Automatizado (SSH + Compression + FTP)

#### 📋 Descripción del Escenario

Tienes un servidor en producción y necesitas backups automáticos: cada noche, conectar vía SSH, hacer un dump de la base de datos, comprimirlo y subirlo a un servidor FTP externo. Si algo falla, recibes una alerta.

#### ✅ Prerequisites

- [ ] Servidor SSH al que conectarte (puede ser localhost para pruebas)
- [ ] Credenciales SSH configuradas en n8n
- [ ] Servidor FTP o SFTP de respaldo
- [ ] Noción de comandos básicos de Linux

#### 📝 Paso a Paso Detallado

**Paso 1: Programar la ejecución nocturna**

1. Añade un nodo **Schedule Trigger**:
   | Campo | Valor |
   |-------|-------|
   | `Trigger Times` | `Every Day` |
   | `At` | `02:00` |

**Paso 2: Ejecutar el backup vía SSH**

1. Conecta un nodo **SSH**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Execute Command` |
   | `Command` | `pg_dump -U postgres nombre_db > /tmp/backup_db.sql && gzip /tmp/backup_db.sql` |

3. **Explicación:** Este comando:
   - Hace un dump de la BD `nombre_db` a `/tmp/backup_db.sql`
   - Comprime el archivo con `gzip`
   - El resultado es `/tmp/backup_db.sql.gz`

**Paso 3: Verificar que el backup se creó**

1. Conecta un segundo **SSH**:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Execute Command` |
   | `Command` | `ls -lh /tmp/backup_db.sql.gz` |

2. El resultado será algo como:
   ```json
   { "stdout": "-rw-r--r-- 1 root root 1.2M Jan 15 02:00 /tmp/backup_db.sql.gz" }
   ```

**Paso 4: Descargar el archivo comprimido**

1. Conecta un nodo **Read/Write Files from Disk**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Read File` |
   | `File Path` | `/tmp/backup_db.sql.gz` |
   | `Options → Data Property Name` | `data` |

**Paso 5: Subir a FTP**

1. Conecta un nodo **FTP** (o **SFTP** si tu servidor lo soporta).
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Upload` |
   | `File Path` | `/backups/backup_{{ $now.toFormat('yyyyMMdd') }}.sql.gz` |
   | `Upload Data` | Arrastra el binary del paso anterior |

**Paso 6: Notificar éxito**

1. Conecta un nodo **Send Email** (o **Telegram**):
   | Campo | Valor |
   |-------|-------|
   | `To` | `admin@midominio.com` |
   | `Subject` | `✅ Backup completado - {{ $now.toFormat('dd/MM/yyyy') }}` |
   | `Text` | `Backup subido exitosamente a FTP. Tamaño: 1.2MB` |

**Paso 7 (Opcional): Manejo de errores**

1. Asigna un **Error Workflow** al flujo principal (revisa el Lab 4).
2. El Error Workflow enviará una alerta si el backup falla.

#### 📊 Diagrama del Flujo

```
[Schedule Trigger - 2:00 AM]
       ↓
[SSH: pg_dump + gzip]
       ↓
[SSH: verificar que el archivo existe]
       ↓
[If: existe?] ──False──> [Stop And Error: "Backup falló"]
       ↓ True
[Read File: backup_db.sql.gz]
       ↓
[FTP: upload a servidor externo]
       ↓
[Send Email: notificar éxito]
```

#### 🎯 Resultado Esperado

- Cada noche a las 2 AM se genera un backup automático.
- El archivo se comprime (aprox. 90% menos espacio).
- Se sube a un servidor FTP externo.
- Recibes un correo de confirmación.
- Si algo falla, recibes una alerta.

**Reto Pro:** Añade un paso de **SSH** que elimine los backups locales después de subirlos para no llenar el disco: `rm /tmp/backup_db.sql.gz`.

#### 📚 Referencias

- [SSH](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ssh/)
- [FTP](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.ftp/)
- [Compression](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.compression/)
- [Read/Write Files from Disk](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.readwritefile/)

---

### Laboratorio 17: Formulario de Registro con n8n Form

#### 📋 Descripción del Escenario

Tienes una landing page pero no quieres pagar un servicio externo de formularios. Vas a crear un formulario de registro de usuarios directamente con n8n, que guarde los datos en una base de datos y envíe un email de bienvenida automático.

#### ✅ Prerequisites

- [ ] n8n funcionando (necesitas activar el workflow para generar la URL)
- [ ] Base de datos (Postgres, Supabase o Sheets)
- [ ] Credenciales de email configuradas

#### 📝 Paso a Paso Detallado

**Paso 1: Crear el formulario**

1. Añade un nodo **n8n Form Trigger**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Title` | `Registro de Usuario` |
   | `Description` | `Completa tus datos para registrarte en nuestra plataforma` |
   | `Button Label` | `Crear cuenta` |

3. Añade los campos del formulario haciendo clic en **Add Form Field**:

   | Field Label | Field Type | Required |
   |-------------|------------|----------|
   | `Nombre completo` | `Text` | Sí |
   | `Email` | `Email` | Sí |
   | `Teléfono` | `Phone` | No |
   | `Plan` | `Dropdown` | Sí |
   | `Acepto términos` | `Checkbox` | Sí |

4. Para el campo **Plan** (Dropdown), añade opciones:
   | Value | Label |
   |-------|-------|
   | `basico` | Básico - $9/mes |
   | `pro` | Pro - $29/mes |
   | `enterprise` | Enterprise - $99/mes |

**Paso 2: Obtener la URL del formulario**

1. Activa el workflow (interruptor arriba a la derecha).
2. Copia la URL que aparece en el nodo **n8n Form Trigger**.
3. Comparte esta URL con tus usuarios. Se verá algo como: `https://tun8n.com/form/abc123/registro`

**Paso 3: Validar los datos**

1. Conecta un nodo **If** al Form Trigger.
2. Condiciones (todas deben cumplirse):
   - `$json.Acepto_términos` → Equal → `true`
   - `$json.Email` → Is Not Empty

**Paso 4: Guardar en base de datos**

1. Conecta un nodo **Postgres** (o **Supabase**):
   | Campo | Valor |
   |-------|-------|
   | `Operation` | `Insert` |
   | `Table` | `registros` |
   | `Columns` | Mapea: nombre, email, telefono, plan |

**Paso 5: Enviar email de bienvenida**

1. Conecta un nodo **Send Email**:
   | Campo | Valor |
   |-------|-------|
   | `To` | `{{ $json.Email }}` |
   | `Subject` | `Bienvenido a nuestra plataforma` |
   | `HTML` | `<h1>Hola {{ $json.Nombre_completo }}!</h1><p>Gracias por registrarte en el plan {{ $json.Plan }}.</p>` |

**Paso 6: Redirigir después del envío**

1. En el nodo **n8n Form Trigger**, ve a **Options**:
   | Campo | Valor |
   |-------|-------|
   | `Redirect URL` | `https://tusitio.com/gracias` |

#### 📊 Ejemplo de Datos

**Lo que ve el usuario:**
```
┌─────────────────────────────────────┐
│  Registro de Usuario                │
│                                     │
│  Completa tus datos para            │
│  registrarte en nuestra plataforma  │
│                                     │
│  Nombre completo: [______________]  │
│  Email:          [______________]  │
│  Teléfono:       [______________]  │
│  Plan:           [Pro ▼         ]  │
│                                     │
│  ☐ Acepto términos y condiciones    │
│                                     │
│  [       Crear cuenta       ]       │
└─────────────────────────────────────┘
```

**Datos que llegan al flujo:**
```json
{
  "Nombre_completo": "Juan Pérez",
  "Email": "juan@email.com",
  "Teléfono": "+5215512345678",
  "Plan": "pro",
  "Acepto_términos": true
}
```

#### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| El formulario no carga | El workflow no está activado | Activa el interruptor arriba a la derecha |
| Los campos llegan en inglés | El nombre del campo tiene caracteres especiales | Usa nombres sin acentos: `Nombre_completo` |
| El email de bienvenida no llega | SMTP no configurado correctamente | Verifica credenciales SMTP en Settings |
| El checkbox siempre es false | No se marcó como Required | Activa Required en el campo Checkbox |

#### 🎯 Resultado Esperado

- Los usuarios ven un formulario profesional.
- Completan sus datos y se guardan automáticamente en la BD.
- Reciben un email de bienvenida personalizado.
- Son redirigidos a una página de agradecimiento.
- Tú tienes todos los registros en tu base de datos.

**Reto Pro:** Crea un formulario de 2 pasos. El paso 1: datos personales. El paso 2: selección de plan. Conecta dos nodos **n8n Form** en secuencia.

#### 📚 Referencias

- [n8n Form Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.formtrigger/)
- [n8n Form](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.form/)
- [Send Email](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.sendemail/)

---

### Laboratorio 18: Bot de Soporte vía Email (IMAP + Switch)

#### 📋 Descripción del Escenario

Tus clientes te escriben emails de soporte. Quieres que automáticamente se clasifiquen (ventas, soporte técnico, facturación), se guarde un ticket en la base de datos y se envíe una respuesta automática de confirmación.

#### ✅ Prerequisites

- [ ] Cuenta de email con IMAP habilitado (Gmail, Outlook, etc.)
- [ ] Credenciales IMAP configuradas en n8n
- [ ] Base de datos para guardar tickets

#### 📝 Paso a Paso Detallado

**Paso 1: Escuchar correos entrantes**

1. Añade un nodo **Email Trigger (IMAP)**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Mailbox` | `INBOX` |
   | `Only Unread` | Activo |
   | `Options → Custom Rules` | Añade regla: Subject CONTAINS `soporte` |

**Paso 2: Normalizar el asunto para clasificar**

1. Conecta un nodo **Edit Fields**.
2. Añade:
   | Campo | Valor |
   |-------|-------|
   | `Name` | `categoria` |
   | `Value` | `{{ $json.subject.toLowerCase() }}` |

**Paso 3: Clasificar con Switch**

1. Conecta un nodo **Switch**.
2. Configura:
   | Campo | Valor |
   |-------|-------|
   | `Data Type to Route` | `String` |
   | `Value` | `{{ $json.categoria }}` |

3. Añade rutas:

   | Ruta | Condición |
   |------|-----------|
   | Ruta 1: Ventas | `Contains → venta` o `Contains → precio` o `Contains → comprar` |
   | Ruta 2: Soporte Técnico | `Contains → error` o `Contains → bug` o `Contains → falla` |
   | Ruta 3: Facturación | `Contains → factura` o `Contains → pago` o `Contains → recibo` |
   | Ruta Default | (ninguna) |

**Paso 4: Guardar ticket en base de datos**

Para cada ruta, conecta un nodo **Postgres** (o **Supabase**):
```sql
CREATE TABLE tickets (
  id SERIAL PRIMARY KEY,
  cliente TEXT,
  email TEXT,
  categoria TEXT,
  asunto TEXT,
  mensaje TEXT,
  estado TEXT DEFAULT 'abierto',
  created_at TIMESTAMP DEFAULT NOW()
);
```

Configura el Postgres:
| Campo | Valor |
|-------|-------|
| `Operation` | `Insert` |
| `Table` | `tickets` |
| `Columns` | Mapea: cliente (fromName), email (from), categoria, asunto (subject), mensaje (body) |

**Paso 5: Enviar respuesta automática**

1. Conecta un nodo **Send Email** al Postgres:
   | Campo | Valor |
   |-------|-------|
   | `To` | `{{ $json.email }}` (la dirección que envió el correo) |
   | `Subject` | `Re: {{ $json.subject }}` |
   | `Text` | `Hola, hemos recibido tu consulta de {{ $json.categoria }}. Te responderemos en max. 24h. Tu ticket #{{ $json.id }} está siendo procesado.` |

**Paso 6: Notificar al equipo**

1. Conecta un nodo **Telegram** o **Slack** al Send Email:
   ```
   📬 Nuevo ticket de soporte
   Cliente: {{ $json.cliente }}
   Categoría: {{ $json.categoria }}
   Ticket: #{{ $json.id }}
   ```

#### 📊 Ejemplo de Datos

**Correo recibido:**
```
From: cliente@email.com
Subject: Error al iniciar sesión - Soporte
Body: Hola, no puedo iniciar sesión en mi cuenta...
```

**Ticket guardado en BD:**
```json
{
  "cliente": "cliente@email.com",
  "email": "cliente@email.com",
  "categoria": "soporte técnico",
  "asunto": "Error al iniciar sesión - Soporte",
  "mensaje": "Hola, no puedo iniciar sesión en mi cuenta...",
  "estado": "abierto"
}
```

**Respuesta automática enviada:**
```
Subject: Re: Error al iniciar sesión - Soporte

Hola, hemos recibido tu consulta de soporte técnico.
Te responderemos en max. 24h.
Tu ticket #42 está siendo procesado.
```

#### 🎯 Resultado Esperado

- El cliente envía un email.
- Se clasifica automáticamente (ventas / soporte / facturación).
- Se guarda como ticket en la base de datos.
- El cliente recibe una respuesta automática de confirmación.
- El equipo recibe una notificación en Telegram/Slack.

**Reto Pro:** Añade un nodo **Code** que extraiga el texto del `body` y lo limpie de firmas HTML (todo después de `<div class="signature">`) para guardar solo el mensaje relevante.

#### 📚 Referencias

- [Email Trigger (IMAP)](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.emailimap/)
- [Switch](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.switch/)
- [Send Email](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.sendemail/)
- [Telegram](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.telegram/)

---

## 🎓 Tarea de Aprendizaje

Implementa ahora mismo el **Laboratorio 1**. Cuando logres que el nodo `Edit Fields` te devuelva el mensaje formateado correctamente después de lanzar el `curl` desde tu terminal, habrás entendido el 50% de cómo funciona n8n. ¡Suerte!

---

## 📚 Recursos Adicionales

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [Comunidad n8n (foro)](https://community.n8n.io/)
- [Expresiones y funciones de n8n](https://docs.n8n.io/code/expressions/)
- [Node-RED vs n8n](https://docs.n8n.io/comparison/)
