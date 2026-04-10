# Módulo 4: Backend con Serverpod (El Cerebro)

## 1. Arquitectura de Servidor

### Objetivos de Aprendizaje

- Comprender la arquitectura de Serverpod
- Diferenciar entre RPC y REST
- Entender el flujo de generación de código
- Diseñar la estructura de tu backend

---

## 1.1 ¿Qué es Serverpod?

### Concepto

Serverpod es un servidor backend completo escrito en Dart, diseñado específicamente para trabajar con aplicaciones Flutter. Utiliza comunicación RPC (Remote Procedure Call) en lugar de REST, lo que permite una integración más estrecha y tipos compartidos entre cliente y servidor.

### Arquitectura General

```
┌─────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA SERVERPOD                    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   FLUTTER APP                        │   │
│  │  (Cliente)                                          │   │
│  └────────────────────────┬────────────────────────────┘   │
│                           │ RPC                              │
│                           ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              SERVERPOD SERVER                       │   │
│  │                                                     │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │   │
│  │  │  Endpoints  │  │   Models    │  │  Services   │ │   │
│  │  │  (Lógica)   │  │  (Datos)    │  │ (Reusable)  │ │   │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘ │   │
│  │         │                │                │         │   │
│  │  ┌──────┴────────────────┴────────────────┴──────┐  │   │
│  │  │                  SESSION                        │  │   │
│  │  │  (DB, Cache, Auth, Logging)                   │  │   │
│  │  └──────────────────────┬───────────────────────┘  │   │
│  └──────────────────────────┼───────────────────────────┘   │
│                             │                                │
│         ┌───────────────────┼───────────────────┐          │
│         ▼                   ▼                   ▼          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ PostgreSQL  │    │    Redis    │    │    S3/Blob  │     │
│  │  (Datos)    │    │   (Cache)   │    │  (Archivos) │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### ¿Por qué Serverpod para Flutter?

```
┌─────────────────────────────────────────────────────────────┐
│              BENEFICIOS DE SERVERPOD                         │
│                                                             │
│  ✅ Mismo lenguaje (Dart) en cliente y servidor           │
│  ✅ Tipos compartidos (no más JSON manual)                │
│  ✅ Validación automática de tipos                        │
│  ✅ Generación de código automática                        │
│  ✅ Autenticación integrada                                │
│  ✅ Cache distribuido con Redis                            │
│  ✅ Base de datos con PostgreSQL                          │
│  ✅ Websockets para tiempo real                            │
│  ✅ Despliegue con Docker                                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 1.2 RPC vs REST

### REST (El estándar tradicional)

```
┌─────────────────────────────────────────────────────────────┐
│                        REST API                             │
│                                                             │
│  GET    /api/users          → Listar usuarios              │
│  GET    /api/users/123      → Obtener usuario 123         │
│  POST   /api/users          → Crear usuario                │
│  PUT    /api/users/123      → Actualizar usuario          │
│  DELETE /api/users/123      → Eliminar usuario            │
│                                                             │
│  Características:                                          │
│  - Basado en HTTP (verbos, estados)                       │
│  - Formato: JSON                                           │
│  - Sin tipos estrictos                                     │
│  - Cada request es independiente                          │
│                                                             │
└─────────────────────────────────────────────────────────────┘

# Ejemplo de llamada REST
GET /api/users/123 HTTP/1.1
Host: api.midominio.com
Authorization: Bearer token123

# Respuesta
{
  "id": 123,
  "name": "Juan",
  "email": "juan@example.com"
}
```

### RPC (Serverpod)

```
┌─────────────────────────────────────────────────────────────┐
│                    RPC (Serverpod)                          │
│                                                             │
│  client.users.getUser(id: 123)                            │
│  client.orders.createOrder(item: Order)                   │
│  client.products.searchProducts(query: "camara")          │
│                                                             │
│  Características:                                          │
│  - Llamadas a funciones (como llamar función local)      │
│  - Tipos de Dart compartidos                               │
│  - Validación de tipos en compilación                     │
│  - meno código boilerplate                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘

# Ejemplo de llamada RPC
# Tu código Dart (Flutter)
final user = await client.users.getUser(id: 123);

# Internamente se convierte a:
POST /api/endpoint HTTP/1.1
Content-Type: application/json
x-serverpod-key: key123

{
  "endpoint": "users",
  "method": "getUser",
  "parameters": {"id": 123}
}

# Respuesta (ya convertida a objeto Dart)
User(id: 123, name: 'Juan', email: 'juan@example.com')
```

### Comparación

| Aspecto | REST | RPC (Serverpod) |
|---------|------|-----------------|
| Tipado | JSON genérico | Tipos Dart exactos |
| Desarrollo | Más código | Menos código |
| Errores | Códigos HTTP | Excepciones Dart |
| Documentación | OpenAPI/Swagger | Generated |
| Performance | Buena | Mejor |

---

## 1.3 Estructura del Proyecto Serverpod

### Estructura de Archivos

```bash
mi_servidor/
├── packages/
│   ├── server/                    # Código del servidor
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── endpoints/    # Endpoints de la API
│   │   │   │   ├── models/        # Modelos de datos
│   │   │   │   ├── services/     # Servicios reutilizables
│   │   │   │   └── generated/    # Código generado
│   │   │   ├── config/           # Configuraciones
│   │   │   └── server.dart       # Entry point
│   │   ├── config/               # YAML de configuración
│   │   │   ├── generator.yaml    # Config de generación
│   │   │   └── database.yaml     # Config de DB
│   │   ├── docker/               # Docker
│   │   │   └── Dockerfile
│   │   └── pubspec.yaml
│   │
│   └── client/                    # Cliente generado
│       ├── lib/
│       │   └── src/
│       │       └── client/
│       │           └── client.dart
│       └── pubspec.yaml
│
├── flutter_app/                   # Tu app Flutter
│   ├── lib/
│   │   ├── client/
│   │   │   └── client.dart        # Cliente importado
│   │   └── main.dart
│   └── pubspec.yaml
│
└── docker-compose.yml             # Servicios (DB, Redis)
```

### Flujo de Trabajo

```
1. Escribes modelos en YAML
2. Ejecutas "serverpod generate"
3. Se genera código:
   - Cliente: clases, métodos RPC
   - Servidor: tablas DB, endpoints
4. Implementas lógica en endpoints
5. Despliegas

┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  YAML       │───►│  Generate   │───►│  Dart       │
│  (Modelos)  │    │             │    │  (Código)   │
└─────────────┘    └─────────────┘    └─────────────┘
```

---

## 1.4 Configuración Inicial

### generator.yaml

```yaml
# config/generator.yaml

type: serverpod

# Clave de autenticación (secreta)
authenticationKey: tu_clave_secreta_de_desarrollo

# Configuración de la base de datos
database:
  host: postgres
  port: 5432
  user: postgres
  password: ${DB_PASSWORD}
  name: serverpod

# Configuración de Redis (opcional)
cache:
  host: redis
  port: 6379

# Configuración de la API
api:
  port: 8080

# Insighs (herramientas de desarrollo)
insights:
  port: 8081
```

### database.yaml

```yaml
# config/database.yaml

# Nombre de la base de datos
databaseName: serverpod

# Esquema de la base de datos
schema: public

# Tablas se definen en archivos separados
# en src/models/
```

---

## 1.5 Comandos de Serverpod

### Comandos Esenciales

```bash
# Generar código (después de crear modelos)
dart run serverpod generate

# Iniciar servidor en desarrollo
dart run bin/main.dart

# Con Docker
docker compose up --build

# Ver logs
docker compose logs -f serverpod

# Regenerar después de cambios
dart run serverpod generate
dart run bin/main.dart
```

### Estructura de un Endpoint

```dart
// packages/server/lib/src/endpoints/usuario_endpoint.dart

class UsuarioEndpoint extends Endpoint {
  @override
  Future<Usuario?> getUsuario(Session session, int id) async {
    // Lógica para obtener usuario
    return await Usuario.db.findById(session, id);
  }

  @override
  Future<Usuario> crearUsuario(Session session, CreateUsuario data) async {
    // Validar datos
    // Crear en DB
    // Retornar usuario creado
    return await data.insert(session);
  }
}
```

---

## 1.6 Integración con Flutter

### Importar Cliente Generado

```dart
// flutter_app/lib/main.dart

import 'package:serverpod_client/serverpod_client.dart';
import 'package:flutter/material.dart';

late Client client;

void main() async {
  // Inicializar cliente
  client = Client(
    Uri.parse('http://192.168.1.100:8080'),
    authenticationKey: 'tu_clave_secreta',
  );

  runApp(const MyApp());
}
```

### Usar el Cliente

```dart
// Obtener usuario
final usuario = await client.usuarioEndpoint.getUsuario(1);

// Crear usuario
final nuevoUsuario = await client.usuarioEndpoint.crearUsuario(
  CreateUsuario(
    nombre: 'Juan',
    email: 'juan@example.com',
  ),
);

// Actualizar
await client.usuarioEndpoint.actualizarUsuario(
  usuario.copyWith(nombre: 'Juan Actualizado'),
);

// Eliminar
await client.usuarioEndpoint.eliminarUsuario(1);
```

---

## 1.7 Ejercicios Prácticos

### Ejercicio 1: Instalar Serverpod

```bash
# Crear proyecto Serverpod
dart pub global activate serverpod_cli
serverpod create mi_proyecto

# O con template
dart create --template=serverpod mi_proyecto

cd mi_proyecto

# Ver estructura
ls -la
ls -la packages/server/lib/src/
```

### Ejercicio 2: Configurar docker-compose

```bash
# Editar docker-compose.yml
# Asegurar que incluye:
# - postgres
# - redis (opcional)
# - serverpod

docker compose up -d

# Ver servicios
docker compose ps
```

### Ejercicio 3: Generar Código Inicial

```bash
cd packages/server

# Ver config
cat config/generator.yaml

# Generar
dart run serverpod generate

# Ver archivos generados
ls -la lib/src/generated/
```

---

## 1.8 Recursos Adicionales

### Documentación Oficial

- [Serverpod Docs](https://docs.serverpod.dev/)
- [Serverpod GitHub](https://github.com/serverpod/serverpod)

### Comandos de Referencia

```bash
# Desarrollo
dart run serverpod generate    # Regenerar código
dart run bin/main.dart        # Iniciar servidor

# Docker
docker compose up -d          # Levantar servicios
docker compose logs -f       # Ver logs
docker compose down          # Detener servicios
```

### Puertos por Defecto

```
8080: API principal (endpoints)
8081: Insights (herramientas de desarrollo)
5432: PostgreSQL
6379: Redis
```

---

## Resumen

En esta guía has aprendido:

- ✅ Qué es Serverpod y su arquitectura
- ✅ Diferencia entre RPC y REST
- ✅ Estructura del proyecto Serverpod
- ✅ Configuración inicial (generator.yaml)
- ✅ Integración básica con Flutter

**Siguiente guía:** Modelado de Datos con YAML - Crear modelos que se convierten en tablas de PostgreSQL.