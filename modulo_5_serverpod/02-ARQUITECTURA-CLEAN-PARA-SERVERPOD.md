# Arquitectura Clean Architecture para Serverpod

> Aprende a adaptar los principios de Clean Architecture que ya conoces de Flutter al desarrollo backend con Serverpod.

---

## Tabla de Contenidos

1. [Clean Architecture en Backend](#1-clean-architecture-en-backend)
2. [Las Capas en Serverpod](#2-las-capas-en-serverpod)
3. [Flujo de Datos](#3-flujo-de-datos)
4. [Arquitectura Híbrida](#4-arquitectura-híbrida-cliente-servidor)
5. [Ejemplo Completo: Sistema de Tareas](#5-ejemplo-completo-sistema-de-tareas)
6. [Reglas de Dependencia](#6-reglas-de-dependencia)
7. [Cuándo Usar Cada Capa](#7-cuándo-usar-cada-capa)

---

## 1. Clean Architecture en Backend

### Recordatorio: La Idea Central

Clean Architecture propone organizar el código en **capas concéntricas** donde:

- Las capas internas **no conocen** a las externas
- Las capas externas **dependen** de las internas
- Cada capa tiene una **responsabilidad única**

```
    ╭──────────────────────────────────────╮
    │        PRESENTATION (UI)            │
    │   Widgets, Pages, Cubits/BLoCs      │
    ╰───────────────╮──────────────────────╯
                    │
    ╭───────────────▼──────────────────────╮
    │            DOMAIN (Lógica)           │
    │   Entities, UseCases, Repositories   │
    ╰───────────────╮──────────────────────╯
                    │
    ╭───────────────▼──────────────────────╮
    │              DATA (Datos)             │
    │   Models, DataSources, Repository Impl│
    ╰──────────────────────────────────────╯
```

### Adaptación a Backend

En un proyecto Serverpod, la arquitectura se divide entre **cliente** y **servidor**:

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PROYECTO SERVERPOD COMPLETO                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│   ┌─────────────────────────────────────────────────────────┐       │
│   │                  FLUTTER APP (Cliente)                   │       │
│   ├─────────────────────────────────────────────────────────┤       │
│   │  Presentation → Domain → Data (Clean Architecture)      │       │
│   │  (Cubits)     (UseCases) (Repositories con Serverpod)   │       │
│   └───────────────────────────┬─────────────────────────────┘       │
│                               │ Type-safe client                   │
│                               ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐       │
│   │                  SERVERPOD (Backend)                     │       │
│   ├─────────────────────────────────────────────────────────┤       │
│   │                                                          │       │
│   │   Endpoints ← Services ← Models ← Database (PostgreSQL) │       │
│   │   (API)       (UseCases)  (ORM)    (Persistencia)       │       │
│   │                                                          │       │
│   │   Clean Architecture adaptada al backend:                │       │
│   │   - Endpoints = Controllers (equivalente a UI)          │       │
│   │   - Services = UseCases (lógica de negocio)            │       │
│   │   - Models = Entities + Data (acceso a BD)              │       │
│   │                                                          │       │
│   └─────────────────────────────────────────────────────────┘       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 2. Las Capas en Serverpod

### Vista Detallada de las Capas Backend

```
    ┌─────────────────────────────────────────────────────────────────┐
    │                      SERVER (Backend)                           │
    ├─────────────────────────────────────────────────────────────────┤
    │                                                                  │
    │  ╭─────────────────────────────────────────────────────────╮   │
    │  │  1. ENDPOINTS (Capa de Presentación del Backend)         │   │
    │  │                                                          │   │
    │  │  - Reciben las requests del cliente                     │   │
    │  │  - Validan parámetros básicos                           │   │
    │  │  - Llaman a los Services                                │   │
    │  │  - Formatean la respuesta                               │   │
    │  │                                                          │   │
    │  │  Responsabilidad: Orquestación y coordinación           │   │
    │  ╰───────────────────────────╮──────────────────────────────╯   │
    │                               │                                   │
    │  ╰───────────────────────────▼──────────────────────────────╮   │
    │  │  2. SERVICES (Capa de Dominio del Backend)               │   │
    │  │                                                          │   │
    │  │  - Contienen la lógica de negocio pura                   │   │
    │  │  - Validaciones complejas                                │   │
    │  │  - Reglas de negocio                                    │   │
    │  │  - No dependen de HTTP ni de la base de datos           │   │
    │  │                                                          │   │
    │  │  Responsabilidad: Lógica de negocio                      │   │
    │  ╰───────────────────────────╮──────────────────────────────╯   │
    │                               │                                   │
    │  ╰───────────────────────────▼──────────────────────────────╮   │
    │  │  3. MODELS (Capa de Datos del Backend)                   │   │
    │  │                                                          │   │
    │  │  - Definen la estructura de datos                        │   │
    │  │  - Manejan la serialización (JSON/Protocol Buffers)      │   │
    │  │  - Acceso a la base de datos (ORM de Serverpod)          │   │
    │  │                                                          │   │
    │  │  Responsabilidad: Persistencia y transformación          │   │
    │  ╰──────────────────────────────────────────────────────────╯   │
    │                                                                  │
    └─────────────────────────────────────────────────────────────────┘
```

### Equivalencias Detalladas

| Capa Flutter | Capa Serverpod | ¿Qué hace? |
|--------------|----------------|------------|
| **Widget** | **Endpoint** | Recibe input del usuario/cliente |
| **Cubit** | **Service** | Maneja la lógica de negocio |
| **Repository Interface** | **Service Interface** | Define contratos |
| **Repository Implementation** | **Model + ORM** | Acceso a datos |
| **Entity** | **Model/TableRow** | Objeto de negocio puro |
| **State** | **Response/Exception** | Resultado de operaciones |

---

## 3. Flujo de Datos

### Diagrama Completo del Flujo

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           FLUJO DE DATOS COMPLETO                        │
└─────────────────────────────────────────────────────────────────────────┘

    USUARIO EN FLUTTER APP
           │
           │ "Presiona botón crear tarea"
           ▼
    ┌─────────────────────┐
    │  WIDGET (Flutter)   │
    │  ─────────────────  │
    │  onPressed: () =>   │
    │    cubit.createTask  │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │  CUBIT (Flutter)    │
    │  ─────────────────  │
    │  emit(Loading)      │
    │  result = await      │
    │    createTask()      │
    └──────────┬──────────┘
               │
               │ client.tasksEndpoint.createTask(...)
               │ (Type-safe call via generated client)
               ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    SERVERPOD SERVER                     │
    ├─────────────────────────────────────────────────────────┤
    │
    │  ┌─────────────────────────────────────────────────┐   │
    │  │  ENDPOINT (Capa de Presentación Backend)         │   │
    │  │  ─────────────────────────────────────────────  │   │
    │  │  Future<Task> createTask(                       │   │
    │  │    Session session,                             │   │
    │  │    CreateTaskInput input                        │   │
    │  │  ) async {                                      │   │
    │  │    return await _service.createTask(input);     │   │
    │  │  }                                              │   │
    │  └─────────────────────┬───────────────────────────┘   │
    │                        │                                 │
    │                        ▼                                 │
    │  ┌─────────────────────────────────────────────────┐   │
    │  │  SERVICE (Capa de Dominio Backend)               │   │
    │  │  ─────────────────────────────────────────────  │   │
    │  │  - Validar lógica de negocio                   │   │
    │  │  - Verificar reglas de autorización             │   │
    │  │  - Llamar al modelo para persistencia           │   │
    │  │                                                  │   │
    │  │  Task createTask(CreateTaskInput input) {       │   │
    │  │    if (input.name.length < 3) {                 │   │
    │  │      throw ValidationException('Name too short');│   │
    │  │    }                                            │   │
    │  │    return _taskModel.create(input);             │   │
    │  │  }                                              │   │
    │  └─────────────────────┬───────────────────────────┘   │
    │                        │                                 │
    │                        ▼                                 │
    │  ┌─────────────────────────────────────────────────┐   │
    │  │  MODEL (Capa de Datos Backend)                   │   │
    │  │  ─────────────────────────────────────────────  │   │
    │  │  - Traduce a/desde formato de base de datos    │   │
    │  │  - Usa el ORM de Serverpod                      │   │
    │  │                                                  │   │
    │  │  await Task(                                    │   │
    │  │    name: input.name,                            │   │
    │  │    userId: session.auth.userId,                 │   │
    │  │  ).insert(session);                             │   │
    │  └─────────────────────┬───────────────────────────┘   │
    │                        │                                 │
    └────────────────────────┼─────────────────────────────────┘
                             │
                             ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    POSTGRESQL DATABASE                    │
    │  ─────────────────────────────────────────────────────  │
    │  INSERT INTO tasks (name, user_id, created_at)            │
    │  VALUES ('Mi tarea', 123, NOW())                         │
    └─────────────────────────────────────────────────────────┘
                             │
                             │ Task created successfully
                             ▼
    ┌─────────────────────────────────────────────────────────┐
    │                    RETORNO DE DATOS                      │
    └─────────────────────────────────────────────────────────┘
                             │
                             ▼
    ┌─────────────────────┐
    │  CUBIT (Flutter)    │
    │  ─────────────────  │
    │  result.fold(        │
    │    (fail) => emit(Error),
    │    (task) => emit(Success)
    │  )                   │
    └──────────┬──────────┘
               │
               ▼
    ┌─────────────────────┐
    │  WIDGET (Flutter)   │
    │  ─────────────────  │
    │  Muestra SnackBar   │
    │  "Tarea creada"     │
    └─────────────────────┘
```

### Código Equivalente Paso a Paso

```dart
// STEP 1: Widget (Flutter) - UI
// =============================

class CreateTaskButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Llama al Cubit
        context.read<TaskCubit>().createTask('Nueva tarea');
      },
      child: Text('Crear Tarea'),
    );
  }
}
```

```dart
// STEP 2: Cubit (Flutter) - Presentation
// =======================================

class TaskCubit extends Cubit<TaskState> {
  final Client client; // Cliente generado por Serverpod
  
  Future<void> createTask(String name) async {
    emit(TaskLoading());
    
    try {
      // Llamada type-safe al servidor
      final task = await client.tasksEndpoint.createTask(
        CreateTaskInput(name: name),
      );
      
      emit(TaskCreated(task));
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }
}
```

```dart
// STEP 3: Endpoint (Serverpod) - Controller
// ==========================================

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  @override
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    // El endpoint solo orquesta
    // Delega toda la lógica al servicio
    return await _taskService.createTask(input);
  }
}
```

```dart
// STEP 4: Service (Serverpod) - Domain Logic
// ==========================================

class TaskService {
  // Lógica de negocio pura
  // Sin dependencias de HTTP ni base de datos
  
  Task createTask(CreateTaskInput input) {
    // Validaciones de negocio
    if (input.name.trim().isEmpty) {
      throw ValidationException('El nombre no puede estar vacío');
    }
    
    if (input.name.length > 100) {
      throw ValidationException('El nombre es demasiado largo');
    }
    
    // Crear el modelo
    final task = Task(
      name: input.name.trim(),
      createdAt: DateTime.now(),
    );
    
    // Guardar en base de datos
    return task;
  }
}
```

```dart
// STEP 5: Model (Serverpod) - Data Layer
// =======================================

// Generado automáticamente por Serverpod desde task.yaml
class Task extends TableRow {
  String name;
  bool isCompleted;
  DateTime createdAt;
  int userId;
  
  // Métodos de acceso a la base de datos
  static Future<Task?> findById(Session session, int id);
  static Future<List<Task>> findAll(Session session);
  Future<int> insert(Session session);
  Future<void> update(Session session);
  Future<void> delete(Session session);
}
```

---

## 4. Arquitectura Híbrida Cliente-Servidor

### Cómo Conectar Ambos Lados

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    ARQUITECTURA HÍBRIDA COMPLETA                        │
└─────────────────────────────────────────────────────────────────────────┘

    ┌───────────────────────────────────────────────────────────────────┐
    │                         FLUTTER APP                               │
    │  lib/                                                             │
    │  ├── core/                        ← Código compartido            │
    │  │   ├── error/failures.dart                                    │
    │  │   └── utils/constants.dart                                    │
    │  │                                                               │
    │  └── features/                   ← Features independientes         │
    │      └── tasks/                                                  │
    │          ├── data/                                               │
    │          │   ├── repositories/      ← Usa el cliente de Serverpod │
    │          │   │   └── task_repository_impl.dart                   │
    │          │   └── models/                                           │
    │          │       └── task_model.dart                              │
    │          ├── domain/                                              │
    │          │   ├── entities/task.dart    ← Entity pura              │
    │          │   ├── repositories/task_repository.dart                 │
    │          │   └── usecases/                                        │
    │          │       └── create_task_usecase.dart                    │
    │          └── presentation/                                        │
    │              ├── cubit/                                           │
    │              └── pages/                                           │
    │                                                               │
    │  Tu app Flutter usa el patrón de Clean Architecture que ya conoces │
    │  La diferencia: el "DataSource" es el cliente de Serverpod         │
    │                                                               │
    └───────────────────────────────┬───────────────────────────────────┘
                                    │
                                    │ Generated client
                                    │ (serverpod_client.dart)
                                    ▼
    ┌───────────────────────────────────────────────────────────────────┐
    │                        SERVERPOD SERVER                            │
    │  lib/                                                             │
    │  └── src/                                                         │
    │      ├── endpoints/                 ← Punto de entrada             │
    │      │   └── tasks_endpoint.dart                                │
    │      ├── services/                 ← Lógica de negocio            │
    │      │   └── task_service.dart                                   │
    │      ├── models/                   ← Input/Output DTOs             │
    │      │   └── task_input.dart                                     │
    │      └── exceptions/                ← Errores personalizados       │
    │          └── task_exceptions.dart                                 │
    │                                                                       │
    │  models/                                                            │
    │  ├── task.yaml                      ← Definición del modelo         │
    │  └── generated/                                                    │
    │      └── protocol.dart               ← Clases de base de datos      │
    │                                                                       │
    │  database/                                                          │
    │  └── migrations/                                                    │
    │      └── 001_create_task.sql                                        │
    │                                                                       │
    └───────────────────────────────────────────────────────────────────┘
```

### La Conexión: Cliente Generado

Serverpod genera automáticamente un cliente que puedes usar en tu app Flutter:

```dart
// En tu Flutter app
// =================

import 'package:my_serverpod_client/my_serverpod_client.dart';

// El cliente ya sabe cómo comunicarse con el servidor
final client = Client('https://api.myserver.com');

// Llamadas que parecen locales pero van al servidor
final tasks = await client.tasksEndpoint.getTasks();
```

### Repository Implementation en Flutter

```dart
// lib/features/tasks/data/repositories/task_repository_impl.dart

class TaskRepositoryImpl implements TaskRepository {
  final Client client;
  
  TaskRepositoryImpl({required this.client});
  
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      // El "DataSource" es el cliente de Serverpod
      final tasks = await client.tasksEndpoint.getTasks();
      
      // Convertir a Entities si es necesario
      return Right(tasks.map((t) => t.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
  
  @override
  Future<Either<Failure, Task>> createTask(String name) async {
    try {
      final input = CreateTaskInput(name: name);
      final task = await client.tasksEndpoint.createTask(input);
      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

---

## 5. Ejemplo Completo: Sistema de Tareas

### Estructura de Archivos

```
    my_serverpod_project/
    │
    ├── my_serverpod_project_flutter/    ← Tu app Flutter
    │   └── lib/
    │       ├── core/
    │       │   └── error/failures.dart
    │       └── features/
    │           └── tasks/
    │               ├── data/
    │               │   ├── repositories/task_repository_impl.dart
    │               │   └── models/task_model.dart
    │               ├── domain/
    │               │   ├── entities/task.dart
    │               │   ├── repositories/task_repository.dart
    │               │   └── usecases/create_task_usecase.dart
    │               └── presentation/
    │                   ├── cubit/task_cubit.dart
    │                   └── pages/tasks_page.dart
    │
    └── my_serverpod_project_server/    ← Backend Serverpod
        └── lib/
            └── src/
                ├── endpoints/
                │   └── tasks_endpoint.dart
                ├── services/
                │   └── task_service.dart
                ├── models/
                │   └── task_input.dart
                └── exceptions/
                    └── task_exceptions.dart
            └── models/
                ├── task.yaml
                └── generated/
                    └── protocol.dart
            └── database/
                └── migrations/
```

### Implementación Paso a Paso

#### Backend (Serverpod)

```dart
// my_serverpod_project_server/lib/src/models/task.yaml
// =====================================================

class: Task
table: tasks
fields:
  name: String
  isCompleted: bool
  createdAt: DateTime
  userId: int, relation=parent=User
```

```dart
// my_serverpod_project_server/lib/src/services/task_service.dart
// ==============================================================

class TaskService {
  // Lógica de negocio pura
  // Sin conocimiento de HTTP ni de cómo se recibió el request
  
  Task createTask({
    required String name,
    required int userId,
  }) {
    // Validaciones de negocio
    if (name.trim().isEmpty) {
      throw TaskValidationException('El nombre no puede estar vacío');
    }
    
    if (name.length > 100) {
      throw TaskValidationException('El nombre no puede superar 100 caracteres');
    }
    
    // Crear la tarea
    final task = Task(
      name: name.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: userId,
    );
    
    // Devolver (el endpoint se encargará de guardar)
    return task;
  }
  
  List<Task> getTasksForUser(List<Task> allTasks, int userId) {
    return allTasks.where((t) => t.userId == userId).toList();
  }
}
```

```dart
// my_serverpod_project_server/lib/src/endpoints/tasks_endpoint.dart
// ==================================================================

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  @override
  bool get requireAuth => true;
  
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    final allTasks = await Task.findAll(session);
    return _taskService.getTasksForUser(allTasks, userId);
  }
  
  Future<Task> createTask(Session session, String name) async {
    final userId = session.auth.authenticatedUser!.id;
    
    // El servicio valida y crea la lógica
    final task = _taskService.createTask(
      name: name,
      userId: userId,
    );
    
    // Guardar en base de datos
    await task.insert(session);
    
    return task;
  }
}
```

#### Frontend (Flutter)

```dart
// my_serverpod_project_flutter/lib/features/tasks/domain/entities/task.dart
// =======================================================================

class Task extends Equatable {
  final int id;
  final String name;
  final bool isCompleted;
  final DateTime createdAt;
  
  const Task({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
  });
  
  // Getters de lógica de negocio
  bool get isNew => DateTime.now().difference(createdAt).inDays < 7;
  
  @override
  List<Object?> get props => [id, name, isCompleted, createdAt];
}
```

```dart
// my_serverpod_project_flutter/lib/features/tasks/data/repositories/task_repository_impl.dart
// ========================================================================================

class TaskRepositoryImpl implements TaskRepository {
  final Client client;
  
  TaskRepositoryImpl({required this.client});
  
  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    try {
      final serverTasks = await client.tasksEndpoint.getTasks();
      return Right(serverTasks.map(_toEntity).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Task>> createTask(String name) async {
    try {
      final serverTask = await client.tasksEndpoint.createTask(name);
      return Right(_toEntity(serverTask));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  Task _toEntity(dynamic serverTask) {
    // Conversión de Task de Serverpod a Task Entity
    return Task(
      id: serverTask.id,
      name: serverTask.name,
      isCompleted: serverTask.isCompleted,
      createdAt: serverTask.createdAt,
    );
  }
}
```

---

## 6. Reglas de Dependencia

### La Regla de Oro

```
    Las dependencias SIEMPRE apuntan hacia adentro
    Las capas internas NO conocen a las externas
    
    ✅ CORRECTO:
    Endpoint → Service → Model
    
    ❌ INCORRECTO:
    Service → Endpoint (un servicio no debe conocer los endpoints)
    Model → Service (el modelo no debe conocer los servicios)
```

### En Código

```dart
// ✅ CORRECTO: El Endpoint conoce al Service
class TasksEndpoint extends Endpoint {
  final TaskService _taskService; // Inyección por constructor
  
  TasksEndpoint(this._taskService);
  
  Future<Task> createTask(Session session, String name) async {
    // Delega la lógica al servicio
    return await _taskService.createTask(name);
  }
}

// ❌ INCORRECTO: El Service conoce al Endpoint
class TaskService {
  Task createTask(TasksEndpoint endpoint, String name) {
    // MAL: El servicio depende del endpoint
    // Esto crea acoplamiento innecesario
  }
}
```

### Principios SOLID Aplicados

| Principio | Aplicación en Serverpod |
|-----------|-------------------------|
| **S**ingle Responsibility | Cada capa tiene una única razón para cambiar |
| **O**pen/Closed | Extiende sin modificar código existente |
| **L**iskov Substitution | Puedes cambiar implementaciones sin afectar otras capas |
| **I**nterface Segregation | Servicios específicos en lugar de uno genérico |
| **D**ependency Inversion | Dependes de abstracciones, no de concreciones |

---

## 7. Cuándo Usar Cada Capa

### Matriz de Decisiones

| Situación | ¿Dónde va? | Ejemplo en Serverpod |
|-----------|-----------|----------------------|
| Validar formato de email | Service | `if (!email.contains('@')) throw ...` |
| Guardar en base de datos | Model/TableRow | `await task.insert(session)` |
| Verificar permisos de usuario | Service | `if (!user.canDelete()) throw ...` |
| Decidir si la tarea existe | Model | `Task.findById(session, id)` |
| Formatear respuesta JSON | Serverpod (automático) | Se genera automáticamente |
| Manejar autenticación | Endpoint (middleware) | `@requireAuth` |
| Registrar logs | Cualquier capa | `session.logger.info('...')` |
| Conexión a API externa | Service | `await httpClient.get(...)` |

### Checklist de Responsabilidades

```
    ENDPOINT (Controller)
    ──────────────────────
    [ ] Recibir requests del cliente
    [ ] Validar tipos de parámetros básicos
    [ ] Llamar al Service correspondiente
    [ ] Manejar excepciones del Service
    [ ] Devolver respuesta formateada
    
    ❌ NO hacer en Endpoint:
    [ ] Validaciones de negocio complejas
    [ ] Acceso directo a base de datos
    [ ] Lógica de autorización detallada

    SERVICE (UseCase)
    ──────────────────
    [ ] Toda la lógica de negocio
    [ ] Validaciones de reglas de negocio
    [ ] Verificaciones de autorización
    [ ] Llamadas a múltiples modelos
    [ ] Transformaciones de datos
    
    ❌ NO hacer en Service:
    [ ] Serialización/Deserialización
    [ ] Acceso directo a HTTP
    [ ] Conocimiento del cliente

    MODEL (Data)
    ─────────────
    [ ] Definir estructura de datos
    [ ] Métodos de acceso a base de datos
    [ ] Conversiones de tipos
    [ ] Validaciones de formato simple
    
    ❌ NO hacer en Model:
    [ ] Lógica de negocio compleja
    [ ] Decisiones de autorización
    [ ] Llamadas a otros modelos
```

---

## 📝 Resumen

Después de leer este documento, deberías entender:

- ✅ Cómo Clean Architecture se adapta al backend con Serverpod
- ✅ Las tres capas del backend: Endpoints, Services, Models
- ✅ El flujo de datos desde Flutter hasta PostgreSQL
- ✅ La arquitectura híbrida cliente-servidor
- ✅ Las reglas de dependencia entre capas
- ✅ Cuándo usar cada capa y cuándo no

---

## 🎯 Próximo Paso

Continúa con [03-ESTRUCTURA-PROYECTO-SERVERPOD.md](./03-ESTRUCTURA-PROYECTO-SERVERPOD.md) para aprender la estructura de carpetas detallada de un proyecto Serverpod con Clean Architecture.
