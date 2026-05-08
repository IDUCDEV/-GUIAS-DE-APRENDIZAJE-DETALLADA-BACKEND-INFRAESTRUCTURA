# Módulo 3: Automatización con n8n
## 3.7 Nodos Esenciales: Bases de Datos, JWT, Crypto y GraphQL

### Objetivos de Aprendizaje
- Conectar y operar sobre **Postgres** y **MySQL** directamente desde n8n.
- Generar y validar **Tokens JWT** para autenticación entre servicios.
- Aplicar **Crypto** (hashing, encriptación) para proteger datos sensibles.
- Consumir **APIs GraphQL** con el nodo especializado.

---

## 1. Conexión a Bases de Datos (Postgres y MySQL)

Como backend developer, tu pan de cada día es interactuar con bases de datos. n8n tiene nodos nativos para los motores más populares.

### El Nodo Postgres

Permite ejecutar consultas SQL completas de forma segura.

**Configuración de credenciales:**
1. Ve a **Credentials → New → Postgres**.
2. Ingresa:
   - `Host`: IP de tu servidor PostgreSQL.
   - `Database`: Nombre de la base de datos.
   - `User` / `Password`: Credenciales de acceso.
   - `Port`: 5432 (por defecto).
   - `SSL`: Actívalo si tu base de datos lo requiere.

**Operaciones principales:**
| Operación | Descripción | Ejemplo |
|-----------|-------------|---------|
| `Execute Query` | SQL libre (SELECT, INSERT, UPDATE, DELETE) | `SELECT * FROM usuarios WHERE id = $1` |
| `Insert` | Insertar registros desde los items del flujo | Mapea campos automáticamente |
| `Update` | Actualizar registros existentes | Filtra por ID y actualiza campos |
| `Delete` | Eliminar registros | Condición WHERE |
| `Select` | Obtener datos con filtros visuales | Sin escribir SQL |

**Parámetros con `$1`, `$2`... (MUY IMPORTANTE):**
Nunca concatentes strings en SQL. Usa parámetros:
```sql
-- MAL (SQL Injection):
SELECT * FROM usuarios WHERE email = '{{ $json.email }}'

-- BIEN (Parametrizado):
SELECT * FROM usuarios WHERE email = $1
```
Luego asigna `$1` con el valor `{{ $json.email }}` en el campo **Query Parameters**.

### El Nodo MySQL

Funciona de forma casi idéntica a Postgres.

**Configuración de credenciales:**
- `Host`, `Database`, `User`, `Password`, `Port` (3306 por defecto).

**Operaciones:**
- `Execute Query`: SQL parametrizado con `?` en lugar de `$1`.
- `Insert`, `Update`, `Delete`, `Select`: Modo visual sin SQL.

### Diferencia clave: Postgres vs MySQL en n8n

| Aspecto | Postgres | MySQL |
|---------|----------|-------|
| Placeholder para parámetros | `$1`, `$2`... | `?`, `?`... |
| Puerto por defecto | 5432 | 3306 |
| SSL | Configurable | Configurable |
| JSON nativo | Sí (JSONB) | Sí (JSON) |

---

## 2. JWT: Autenticación entre Servicios

JWT (JSON Web Token) es el estándar para autenticar APIs. n8n puede generarlos y validarlos con el nodo **JWT**.

### Generar un Token

```plaintext
Input: { "userId": 42, "role": "admin" }
Nodo JWT → Operation: Sign → Secret: mi-clave-secreta
Output: eyJhbGciOiJIUzI1NiJ9...
```

**Configuración del nodo JWT (Sign):**
| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Operation` | `Sign` | Generar un nuevo token |
| `Token Payload` | `{{ $json }}` | Los datos que irán dentro del token |
| `Secret or Private Key` | Tu clave secreta | La clave con la que se firmará |
| `Options → Algorithm` | `HS256` | Algoritmo de firma (HS256 es el estándar) |
| `Options → Expires In` | `7d` | El token expirará en 7 días |

### Validar un Token

```plaintext
Input: { "token": "eyJhbGciOiJIUzI1NiJ9..." }
Nodo JWT → Operation: Verify → Secret: mi-clave-secreta
Output: { "userId": 42, "role": "admin", "iat": ..., "exp": ... }
```

**Configuración del nodo JWT (Verify):**
| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Operation` | `Verify` | Validar un token existente |
| `Token` | `{{ $json.token }}` | El token a verificar |
| `Secret or Public Key` | Misma clave usada al firmar | Debe coincidir |

---

## 3. Crypto: Hashing y Encriptación

El nodo **Crypto** te permite aplicar operaciones criptográficas sin escribir una sola línea de código.

### Operaciones disponibles:

| Operación | Uso típico |
|-----------|------------|
| `Hash` | Crear un hash SHA256/MD5 de un string (ej: para comparar contraseñas sin almacenarlas en texto plano) |
| `Hmac` | Hash con clave secreta (autenticación de mensajes) |
| `Encrypt` | Encriptar datos con AES |
| `Decrypt` | Desencriptar datos |
| `Generate` | Generar bytes aleatorios o UUIDs |

### Ejemplo: Hash de contraseña

```plaintext
Input: { "password": "miClave123" }
Nodo Crypto → Operation: Hash → Field: password
Output: { "password_hash": "a8f5f167f44f4964e6c998d..." }
```

**Configuración:**
| Campo | Valor | Explicación |
|-------|-------|-------------|
| `Operation` | `Hash` | Aplicar función hash |
| `Fields` | `password` | El campo del item a hashear |
| `Options → Algorithm` | `sha256` | Algoritmo de hash |

### Ejemplo: Encriptar datos sensibles

| Campo | Valor |
|-------|-------|
| `Operation` | `Encrypt` |
| `Fields` | `tarjeta_credito` |
| `Cipher Algorithm` | `aes-256-cbc` |
| `Secret Key` | MiClaveDe32Caracteres!! |

---

## 4. GraphQL: APIs Modernas

Cada vez más servicios usan GraphQL en lugar de REST. n8n tiene un nodo **GraphQL** dedicado.

### Diferencia clave: REST vs GraphQL

| REST | GraphQL |
|------|---------|
| Múltiples endpoints | Un solo endpoint |
| Recibe más datos de los necesarios | Pides exactamente lo que necesitas |
| `/api/users`, `/api/posts`, `/api/comments` | `POST /graphql` con query personalizada |

### Configuración del nodo GraphQL:

| Campo | Valor | Explicación |
|-------|-------|-------------|
| `HTTP Request Method` | `POST` | GraphQL siempre usa POST |
| `Endpoint` | `https://api.example.com/graphql` | URL del endpoint |
| `Query` | `query { users { id name email } }` | La query GraphQL |
| `Variables` | `{"limit": 10}` | Variables para la query (JSON) |

### Ejemplo de Query con variables:

```graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    email
    posts {
      title
      content
    }
  }
}
```

Variables: `{"id": "{{ $json.userId }}"}`

---

## 5. Aprender Haciendo: API Gateway con JWT + Postgres

### El Reto
Crear un flujo que reciba una petición vía Webhook, valide un JWT, consulte un usuario en Postgres y devuelva sus datos solo si el token es válido.

#### Paso A: Webhook + JWT Verify
1. Añade un nodo **Webhook** (POST, path: `api/usuario`).
2. Conecta un nodo **JWT** con Operation `Verify`.
   - Token: `{{ $json.body.token }}`
   - Secret: `mi-super-secreto`

#### Paso B: Consultar Postgres solo si el token es válido
1. Conecta un nodo **If** a la salida del JWT.
   - Condición: `$json` → `Is Not Empty` (si el token es válido, hay datos).
2. En la rama True, conecta un nodo **Postgres**:
   - Operation: `Execute Query`
   - Query: `SELECT id, nombre, email FROM usuarios WHERE id = $1`
   - Query Parameters: `[{{ $json.body.userId }}]`

#### Paso C: Responder al Webhook
1. Conecta un nodo **Respond to Webhook** al Postgres.
   - Respond with: `JSON`
   - Response Body: `{{ $json }}`

---

## 6. Buenas Prácticas con Bases de Datos

1. **Siempre usa parámetros (`$1`, `$2`):** Nunca concatenes valores directamente en SQL. Esto previene SQL Injection.
2. **Limita las consultas:** Usa `LIMIT` y `WHERE` para no saturar tu base de datos.
3. **No expongas credenciales:** Las credenciales de BD deben estar en n8n Credentials, nunca escritas en nodos.
4. **Transacciones:** Si haces múltiples operaciones (ej: insertar orden + items), usa el campo `Options → Transaction` en Postgres.
5. **Pool de conexiones:** n8n reutiliza conexiones, pero si tienes muchos flujos simultáneos, ajusta `max` en tu `pgbouncer` o config de BD.

---

## Ejercicio Práctico del Capítulo
1. Crea una tabla `usuarios` en Postgres con `id SERIAL, email TEXT, password_hash TEXT`.
2. Crea un flujo que reciba un registro (email + password) por Webhook.
3. Hashea la contraseña con el nodo Crypto (SHA256).
4. Inserta el usuario en Postgres.
5. Genera un JWT con el ID del usuario creado y responde con el token.

**Siguiente Guía:** 3.8 Transformación Avanzada - Summarize, Aggregate, Split Out y más.
