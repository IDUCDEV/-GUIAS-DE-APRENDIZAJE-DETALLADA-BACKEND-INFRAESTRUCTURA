# Guía Conceptual: Backend para Desarrolladores Mobile

> Este documento te introduce a los conceptos fundamentales del desarrollo backend, explicando cada término desde tu perspectiva como desarrollador Flutter.

---

## Tabla de Contenidos

1. [¿Qué es el Backend?](#qué-es-el-backend)
2. [El Modelo Cliente-Servidor](#el-modelo-cliente-servidor)
3. [API: La Interfaz de Comunicación](#api-la-interfaz-de-comunicación)
4. [Base de Datos: El Almacenamiento Persistente](#base-de-datos-el-almacenamiento-persistente)
5. [Autenticación y Autorización](#autenticación-y-autorización)
6. [El Ciclo de Vida de una Request](#el-ciclo-de-vida-de-una-request)
7. [Conceptos Backend vs Mobile](#conceptos-backend-vs-mobile)
8. [Glosario Rápido](#glosario-rápido)

---

## 1. ¿Qué es el Backend?

### En términos simples

Piensa en tu app Flutter como un **restaurante**:

```
┌─────────────────────────────────────────────────────────────┐
│                      TU APP FLUTTER                          │
│                                                             │
│   La UI es como el SALÓN del restaurante:                  │
│   - Mesas bonitas (widgets)                                │
│   - Camareros que toman pedidos (Cubits/BLoCs)              │
│   - Los clientes interactúan con los camareros              │
│                                                             │
└─────────────────────────────┬───────────────────────────────┘
                              │
                              │ "Quiero ver mi lista de tareas"
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      BACKEND                                │
│                                                             │
│   Es como la COCINA del restaurante:                       │
│   - Aquí se prepara la comida (lógica de negocio)         │
│   - Se sacan los ingredientes del refrigerador (DB)        │
│   - Los cocineros no interactúan directamente               │
│     con los clientes                                       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### ¿Por qué necesitas un backend?

| Funcionalidad | En Mobile Solo | Con Backend |
|--------------|----------------|-------------|
| Guardar datos | Se pierden al desinstalar | Persisten para siempre |
| Compartir datos | Solo en ese dispositivo | Todos los usuarios acceden |
| Lógica compleja | Hace lento el teléfono | Procesa en servidores potentes |
| Sincronización | No disponible | Múltiples dispositivos |
| Seguridad | Código visible | Lógica protegida en servidor |

---

## 2. El Modelo Cliente-Servidor

### La Analogía del Restaurante

```
    CLIENTE (Flutter)                          SERVIDOR (Backend)
    ┌─────────────────┐                         ┌─────────────────┐
    │                 │                         │                 │
    │  "Mesero"       │ ──── Pide comida ────→ │  "Cocina"       │
    │                 │                         │                 │
    │  - Toma nota    │                         │  - Prepara      │
    │  - Lleva plato  │ ←─── Sirve plato ───── │  - Cocina       │
    │  - Cobra        │                         │  - Entrega      │
    │                 │                         │                 │
    └─────────────────┘                         └─────────────────┘
```

### En tu app Flutter

```dart
// Tu app Flutter (Cliente)
// =========================

// Mobile-only (sin backend)
// =========================
final tasks = await localDatabase.getTasks(); // Datos locales

// Con Backend (Serverpod)
// =======================
final tasks = await client.tasksEndpoint.getTasks(); // Datos del servidor
```

### ¿Por qué esta separación?

1. **Escalabilidad**: Puedes tener 1 usuario o 1 millón sin cambiar tu app
2. **Seguridad**: Tu lógica de negocio está protegida
3. **Performance**: El servidor tiene más poder de procesamiento
4. **Consistencia**: Todos ven los mismos datos

---

## 3. API: La Interfaz de Comunicación

### ¿Qué es una API?

**API** = Application Programming Interface (Interfaz de Programación de Aplicaciones)

Es el "menú" que define qué puede pedir el cliente al servidor.

```
    API = Menú del Restaurante
    ═══════════════════════════
    
    Lo que el cliente PUEDE pedir:
    ─────────────────────────────
    - Ver carta (GET /tasks)
    - Crear plato (POST /tasks)
    - Modificar plato (PUT /tasks/1)
    - Eliminar plato (DELETE /tasks/1)
    
    Lo que el cliente NO puede hacer:
    ──────────────────────────────────
    - Entrar a la cocina directamente
    - Tomar ingredientes sin pedir
    - Usar equipos de cocina
```

### Tipos de APIs en Backend

| Tipo | Descripción | Ejemplo en Flutter |
|------|-------------|-------------------|
| **REST** | Basada en HTTP, usa verbos (GET, POST, PUT, DELETE) | `client.tasks.getTasks()` |
| **gRPC** | Más rápida, usa protocol buffers | Generado automáticamente por Serverpod |
| **WebSocket** | Comunicación en tiempo real bidireccional | Chat en vivo, notificaciones |

### Serverpod usa gRPC

Serverpod genera automáticamente un cliente type-safe:

```dart
// El cliente se genera automáticamente
// No necesitas escribir código de red manualmente

final client = await Client('https://api.myserver.com');

// Llamada simple como si fuera una función local
final tasks = await client.tasks.getTasks();
final task = await client.tasks.createTask(Task(name: 'New task'));
```

---

## 4. Base de Datos: El Almacenamiento Persistente

### SQLite (Mobile) vs PostgreSQL (Backend)

| Aspecto | SQLite (Flutter) | PostgreSQL (Backend) |
|---------|------------------|---------------------|
| **Ubicación** | En el dispositivo | En el servidor |
| **Acceso** | Directo | A través de red |
| **Usuarios** | Solo uno | Múltiples concurrentes |
| **Capacidad** | Limitada | Escalable a terabytes |
| **Rendimiento** | Bueno para local | Optimizado para consultas complejas |

### La Analogía

```
    SQLite = Nevera de casa
    ─────────────────────────
    - Solo tú la usas
    - Cantidad limitada de comida
    - Si se rompe, pierdes todo
    - No compartes con vecinos

    PostgreSQL = Almacén de supermercado
    ──────────────────────────────────────
    - Múltiples empleados acceden
    - Miles de productos
    - Respaldos automáticos
    - Suministra a múltiples tiendas
```

### En Serverpod

Serverpod incluye un **ORM** (Object-Relational Mapping) que convierte objetos Dart a filas de base de datos:

```dart
// Defines tu modelo en un archivo YAML
// Serverpod genera el código automáticamente

// lib/src/models/task.yaml
class: Task
table: tasks
fields:
  name: String
  isCompleted: bool
  createdAt: DateTime
```

```dart
// Serverpod genera esto automáticamente:
// lib/src/generated/protocol.dart

class Task extends TableRow {
  String name;
  bool isCompleted;
  DateTime createdAt;
  
  // Métodos de acceso a la base de datos
  static Task findById(Session session, int id);
  static List<Task> findAll(Session session);
  Future<int> insert(Session session);
  Future<void> update(Session session);
  Future<void> delete(Session session);
}
```

---

## 5. Autenticación y Autorización

### La Diferencia Clave

```
    AUTENTICACIÓN (Who are you?)
    ─────────────────────────────
    "Eres tú realmente?"
    
    Ejemplo: Login con email/password
    - El servidor verifica: "Sí, este usuario existe y la contraseña es correcta"
    - Resultado: Token de sesión

    AUTORIZACIÓN (What can you do?)
    ──────────────────────────────────
    "¿Qué tienes permiso de hacer?"
    
    Ejemplo: Solo admins pueden eliminar usuarios
    - El servidor verifica: "Este usuario tiene rol de admin"
    - Resultado: Permiso concedido o denegado
```

### En Backend vs Mobile

| Concepto | Mobile (Flutter) | Backend (Serverpod) |
|----------|------------------|---------------------|
| **Login** | Guardar token en SharedPreferences | Validar credenciales, generar JWT |
| **Persistencia de sesión** | Token guardado localmente | Token válido en el servidor |
| **Protección de rutas** | No aplica | Middleware de autenticación |
| **Roles/Permisos** | A veces en local | Validación centralizada |

### En Serverpod 3 (Auth Module)

```dart
// Serverpod 3 tiene autenticación robusta integrada

// Endpoint con autenticación requerida
@Route.requiresAuth()
class TaskEndpoint extends Endpoint {
  
  // Solo usuarios autenticados pueden acceder
  Future<List<Task>> getTasks(Session session) async {
    // session.auth.authenticatedUser tiene el usuario actual
    final userId = session.auth.authenticatedUser!.id;
    
    return await Task.findAll(
      session,
      where: (t) => t.userId.equals(userId),
    );
  }
}
```

---

## 6. El Ciclo de Vida de una Request

### Paso a Paso

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CICLO DE VIDA DE UNA REQUEST                        │
└─────────────────────────────────────────────────────────────────────────┘

    1. USUARIO INTERACTÚA CON LA APP
    ═════════════════════════════════
    
    Flutter App: El usuario presiona "Crear Tarea"
    
    ┌──────────────────────────────────────┐
    │ Button(                              │
    │   onPressed: () => _createTask(),    │
    │ )                                    │
    └──────────────────────────────────────┘
    │
    │ client.tasks.createTask(Task(...))
    │
    ▼

    2. CLIENTE ENVÍA REQUEST
    ═══════════════════════════
    
    Se envía por HTTP/gRPC al servidor:
    - Método: POST (crear)
    - URL: /tasks/create
    - Body: { "name": "Mi tarea" }
    - Headers: Authorization: Bearer <token>
    
    │
    ▼

    3. SERVIDOR RECIBE REQUEST
    ═══════════════════════════
    
    Serverpod recibe la petición:
    - Identifica el endpoint correcto
    - Verifica autenticación
    - Valida los parámetros
    
    │
    ▼

    4. LÓGICA DE NEGOCIO
    ═══════════════════════
    
    Se ejecuta la lógica:
    - Validar datos
    - Aplicar reglas de negocio
    - Preparar respuesta
    
    │
    ▼

    5. ACCESO A BASE DE DATOS
    ═══════════════════════════
    
    Se interacts con PostgreSQL:
    - INSERT INTO tasks VALUES (...)
    - Devolver el ID creado
    
    │
    ▼

    6. SERVIDOR ENVÍA RESPUESTA
    ════════════════════════════
    
    Se devuelve al cliente:
    - Status: 200 (éxito)
    - Body: { "id": 1, "name": "Mi tarea" }
    
    │
    ▼

    7. CLIENTE PROCESA RESPUESTA
    ════════════════════════════
    
    Flutter actualiza la UI:
    - Recibe la Task creada
    - Muestra confirmación
    - Actualiza la lista
    
    ┌──────────────────────────────────────┐
    │ SnackBar(                            │
    │   content: Text('Tarea creada'),     │
    │ )                                    │
    └──────────────────────────────────────┘
```

### Código Equivalente

```dart
// Flutter App (Cliente)
// =====================

class TaskCubit extends Cubit<TaskState> {
  Future<void> createTask(String name) async {
    emit(TaskLoading());
    
    try {
      // El cliente genera automáticamente el código de red
      final task = await client.tasks.createTask(
        CreateTaskInput(name: name),
      );
      
      emit(TaskCreated(task));
    } on ServerException catch (e) {
      emit(TaskError(e.message));
    }
  }
}
```

```dart
// Serverpod (Backend)
// ===================

class TaskEndpoint extends Endpoint {
  
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    // 1. Validar input
    if (input.name.isEmpty) {
      throw InvalidInputException('Name cannot be empty');
    }
    
    // 2. Crear la tarea
    final task = Task(
      name: input.name,
      userId: session.auth.authenticatedUser!.id,
      createdAt: DateTime.now(),
    );
    
    // 3. Guardar en base de datos
    await task.insert(session);
    
    // 4. Devolver la tarea creada
    return task;
  }
}
```

---

## 7. Conceptos Backend vs Mobile

### Tabla de Equivalencias

| Concepto Mobile | Concepto Backend | Descripción |
|-----------------|-----------------|-------------|
| **Widget** | **Endpoint** | Punto de entrada para requests |
| **Cubit/BLoC** | **Service/UseCase** | Lógica de negocio |
| **Repository Interface** | **Service Interface** | Contrato de operaciones |
| **Repository Implementation** | **Model + ORM** | Acceso a datos |
| **LocalStorage/Hive** | **PostgreSQL** | Almacenamiento persistente |
| **Provider** | **Service Locator** | Inyección de dependencias |
| **go_router** | **Endpoint routing** | Navegación/definición de rutas |
| **Equatable** | **Data Class** | Objetos de datos |
| **dio/http** | **gRPC generado** | Comunicación de red |

### Estructura Comparativa

```
    FLUTTER (Clean Architecture)          SERVERPOD (Backend)
    ══════════════════════════           ══════════════════════
    
    lib/
    ├── core/                            lib/
    │   ├── error/                       ├── lib/
    │   │   └── failures.dart           │   └── src/
    │   └── di/                          │       ├── exceptions/
    │       └── injection.dart           │       ├── services/
    │                                    │       └── endpoints/
    └── features/                        │
        └── task/                       models/
            ├── data/                   ├── task.yaml (definición)
            │   ├── datasources/        └── generated/
            │   ├── models/                 └── protocol.dart
            │   └── repositories/         
            ├── domain/                 database/
            │   ├── entities/           └── migrations/
            │   ├── repositories/
            │   └── usecases/           
            └── presentation/           
                ├── cubit/             
                └── pages/              
```

---

## 8. Glosario Rápido

### Términos Esenciales

| Término | Definición Simple |
|---------|-------------------|
| **API** | Menú que define qué puede pedir el cliente al servidor |
| **Endpoint** | Función específica en el servidor que el cliente puede llamar |
| **Session** | Conexión temporal entre cliente y servidor |
| **ORM** | Traductor entre objetos de código y filas de base de datos |
| **Middleware** | Código que se ejecuta antes o después de un endpoint |
| **JWT** | Token seguro que identifica al usuario |
| **CRUD** | Create, Read, Update, Delete (operaciones básicas) |
| **Schema** | Estructura de una tabla en la base de datos |
| **Migration** | Script que modifica la estructura de la base de datos |
| **Serialization** | Convertir objetos a texto (JSON) para transmitir |
| **Deserialization** | Convertir texto (JSON) a objetos |

### Términos de Serverpod

| Término | Significado en Serverpod |
|---------|--------------------------|
| **Endpoint** | Clase que agrupa métodos RPC callable desde el cliente |
| **Session** | Contexto de una solicitud con información del usuario |
| **TableRow** | Clase base para modelos que se guardan en PostgreSQL |
| **Protocol** | Clases generadas automáticamente para comunicación |
| **Auth** | Módulo de autenticación integrado |
| **Logging** | Sistema de logs visuales de Serverpod |

---

## 📝 Resumen

Después de leer este documento, deberías entender:

- ✅ El backend es la "cocina" que prepara los datos para tu app
- ✅ El cliente (Flutter) y servidor (Backend) se comunican a través de APIs
- ✅ Serverpod genera clientes type-safe automáticamente
- ✅ PostgreSQL es el almacén persistente en el servidor
- ✅ Autenticación verifica identidad, autorización verifica permisos
- ✅ Una request pasa por: cliente → endpoint → lógica → base de datos → respuesta

---

## 🎯 Próximo Paso

Continúa con [02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md](./02-ARQUITECTURA-CLEAN-PARA-SERVERPOD.md) para aprender cómo aplicar Clean Architecture en tu proyecto Serverpod.
