# Estructura de Proyecto Serverpod

> Guía detallada de la estructura de carpetas para un proyecto Serverpod con Clean Architecture.

---

## Tabla de Contenidos

1. [Estructura General](#1-estructura-general)
2. [Estructura del Servidor](#2-estructura-del-servidor)
3. [Estructura del Cliente Flutter](#3-estructura-del-cliente-flutter)
4. [Modelos y Generación Automática](#4-modelos-y-generación-automática)
5. [Templates de Código](#5-templates-de-código)
6. [Organización por Features](#6-organización-por-features)

---

## 1. Estructura General

### Estructura Completa del Proyecto

```
    my_serverpod_project/
    │
    ├── my_serverpod_project_flutter/     ← Tu app Flutter
    │   ├── lib/
    │   │   ├── main.dart
    │   │   ├── core/                    ← Código compartido
    │   │   │   ├── di/                  ← Inyección de dependencias
    │   │   │   │   └── injection.dart
    │   │   │   ├── error/               ← Failures y excepciones
    │   │   │   │   ├── failures.dart
    │   │   │   │   └── exceptions.dart
    │   │   │   ├── network/             ← Configuración de red
    │   │   │   │   └── serverpod_client.dart
    │   │   │   └── utils/               ← Utilidades
    │   │   │       └── constants.dart
    │   │   │   │
    │   │   │   └── features/            ← Features independientes
    │   │   │       └── {feature_name}/
    │   │   │           ├── data/
    │   │   │           │   ├── datasources/
    │   │   │           │   ├── models/
    │   │   │           │   └── repositories/
    │   │   │           ├── domain/
    │   │   │           │   ├── entities/
    │   │   │           │   ├── repositories/
    │   │   │           │   └── usecases/
    │   │   │           └── presentation/
    │   │   │               ├── cubit/
    │   │   │               └── pages/
    │   │   │
    │   └── test/
    │       └── features/
    │           └── {feature_name}/
    │
    ├── my_serverpod_project_server/       ← Backend Serverpod
    │   ├── lib/
    │   │   ├── main.dart                 ← Punto de entrada
    │   │   └── src/
    │   │       ├── endpoints/             ← Endpoints (Controllers)
    │   │       ├── services/              ← Lógica de negocio (UseCases)
    │   │       ├── models/                ← DTOs, Input/Output
    │   │       ├── exceptions/             ← Excepciones personalizadas
    │   │       └── utilities/             ← Utilidades del servidor
    │   │
    │   ├── config/                        ← Configuraciones
    │   │   └── passwords.yaml
    │   │
    │   ├── models/                        ← Definición de modelos
    │   │   ├── task.yaml
    │   │   ├── user.yaml
    │   │   └── generated/                 ← AUTO-GENERADO
    │   │       └── protocol.dart
    │   │
    │   └── database/                     ← Migraciones
    │       └── migrations/
    │           ├── 001_create_task.sql
    │           └── 002_create_user.sql
    │
    └── my_serverpod_project_shared/       ← Código compartido
        └── lib/
            └── src/
                └── shared.dart
```

---

## 2. Estructura del Servidor

### Diagrama Detallado del Servidor

```
    my_serverpod_project_server/
    │
    ├── lib/
    │   ├── main.dart                    ← Entry point
    │   │   ```
    │   │   void main(List<String> args) async {
    │   │     final runModes = RunMode.createRunModes(args);
    │   │     final sessionConfig = SessionConfiguration();
    │   │     
    │   │     final server = Server(runModes, sessionConfig)
    │   │       ..addEndpoints([
    │   │         UserEndpoint()
    │   │         TaskEndpoint()
    │   │       ])
    │   │       ..start();
    │   │   }
    │   │   ```
    │   │
    │   └── src/
    │       │
    │       ├── endpoints/               ← CONTROLADORES
    │       │   ├── user_endpoint.dart
    │       │   ├── task_endpoint.dart
    │       │   └── auth_endpoint.dart
    │       │
    │       ├── services/                 ← LÓGICA DE NEGOCIO
    │       │   ├── user_service.dart
    │       │   ├── task_service.dart
    │       │   └── interfaces/
    │       │       ├── user_service_interface.dart
    │       │       └── task_service_interface.dart
    │       │
    │       ├── models/                   ← DTOs INPUT/OUTPUT
    │       │   ├── create_user_input.dart
    │       │   ├── update_user_input.dart
    │       │   ├── user_response.dart
    │       │   ├── create_task_input.dart
    │       │   └── task_response.dart
    │       │
    │       ├── exceptions/               ← ERRORES PERSONALIZADOS
    │       │   ├── app_exception.dart
    │       │   ├── validation_exception.dart
    │       │   ├── not_found_exception.dart
    │       │   └── unauthorized_exception.dart
    │       │
    │       ├── repositories/            ← ACCESO A DATOS (Opcional)
    │       │   ├── user_repository.dart
    │       │   └── task_repository.dart
    │       │
    │       └── utilities/               ← HELPERS
    │           ├── logger.dart
    │           └── validators.dart
    │
    ├── models/                         ← DEFINICIÓN DE ENTIDADES
    │   ├── user.yaml
    │   │   ```
    │   │   class: User
    │   │   table: users
    │   │   fields:
    │   │     email: String, unique
    │   │     name: String
    │   │     passwordHash: String
    │   │     createdAt: DateTime
    │   │   ```
    │   │
    │   ├── task.yaml
    │   │   ```
    │   │   class: Task
    │   │   table: tasks
    │   │   fields:
    │   │     title: String
    │   │     description: String?
    │   │     isCompleted: bool
    │   │     userId: int, relation=parent=User
    │   │     createdAt: DateTime
    │   │   ```
    │   │
    │   └── generated/                   ← AUTO-GENERADO
    │       └── protocol.dart
    │
    └── database/
        └── migrations/                 ← MIGRACIONES
            ├── 001_create_user.yaml
            ├── 002_create_task.yaml
            └── 003_add_index.yaml
```

### Explicación de Cada Carpeta

#### Endpoints

Los endpoints son los **controladores** que reciben las requests del cliente:

```dart
// lib/src/endpoints/task_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  // Todas las tareas del usuario autenticado
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    return await _taskService.getTasksForUser(userId);
  }
  
  // Crear nueva tarea
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    final userId = session.auth.authenticatedUser!.id;
    return await _taskService.createTask(input, userId);
  }
  
  // Marcar como completada
  Future<Task> completeTask(Session session, int taskId) async {
    return await _taskService.completeTask(taskId);
  }
}
```

#### Services

Los services contienen la **lógica de negocio pura**:

```dart
// lib/src/services/task_service.dart

class TaskService {
  Task createTask(CreateTaskInput input, int userId) {
    // Validaciones de negocio
    if (input.title.trim().isEmpty) {
      throw ValidationException('El título no puede estar vacío');
    }
    
    if (input.title.length > 100) {
      throw ValidationException('El título es demasiado largo');
    }
    
    // Crear la tarea
    final task = Task(
      title: input.title.trim(),
      description: input.description?.trim(),
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    return task;
  }
  
  Task completeTask(int taskId) {
    final task = Task.findById(taskId);
    if (task == null) {
      throw NotFoundException('Tarea no encontrada');
    }
    
    task.isCompleted = true;
    return task;
  }
}
```

#### Models (DTOs)

Los DTOs (Data Transfer Objects) definen los datos de entrada y salida:

```dart
// lib/src/models/create_task_input.dart

class CreateTaskInput {
  final String title;
  final String? description;
  
  const CreateTaskInput({
    required this.title,
    this.description,
  });
  
  static CreateTaskInput fromJson(Map<String, dynamic> json) {
    return CreateTaskInput(
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }
}
```

#### Exceptions

Excepciones personalizadas para errores de negocio:

```dart
// lib/src/exceptions/app_exception.dart

class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

// Subclases específicas
class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}
```

---

## 3. Estructura del Cliente Flutter

### Diagrama Detallado del Cliente

```
    my_serverpod_project_flutter/
    │
    ├── lib/
    │   ├── main.dart                    ← Entry point
    │   │
    │   ├── core/                       ← CÓDIGO COMPARTIDO
    │   │   │
    │   │   ├── di/                     ← INYECCIÓN DE DEPENDENCIAS
    │   │   │   ├── injection.dart       ← Configuración de GetIt
    │   │   │   └── injection_init.dart  ← Inicialización
    │   │   │
    │   │   ├── error/                  ← MANEJO DE ERRORES
    │   │   │   ├── failures.dart        ← Failures (dartz)
    │   │   │   ├── exceptions.dart      ← Excepciones
    │   │   │   └── error_handler.dart   ← Utilidad de errores
    │   │   │
    │   │   ├── network/                ← CONFIGURACIÓN DE RED
    │   │   │   ├── serverpod_client.dart
    │   │   │   └── client_provider.dart
    │   │   │
    │   │   ├── utils/                  ← UTILIDADES
    │   │   │   ├── constants.dart
    │   │   │   ├── validators.dart
    │   │   │   └── date_utils.dart
    │   │   │
    │   │   └── theme/                  ← TEMA (Opcional)
    │   │       └── app_theme.dart
    │   │
    │   └── features/                   ← FEATURES INDEPENDIENTES
    │       │
    │       ├── auth/                   ← Feature: Autenticación
    │       │   ├── data/
    │       │   │   ├── datasources/
    │       │   │   │   └── auth_remote_datasource.dart
    │       │   │   └── repositories/
    │       │   │       └── auth_repository_impl.dart
    │       │   ├── domain/
    │       │   │   ├── entities/
    │       │   │   │   └── user.dart
    │       │   │   ├── repositories/
    │       │   │   │   └── auth_repository.dart
    │       │   │   └── usecases/
    │       │   │       ├── login_usecase.dart
    │       │   │       ├── logout_usecase.dart
    │       │   │       └── check_auth_usecase.dart
    │       │   └── presentation/
    │       │       ├── cubit/
    │       │       │   ├── auth_cubit.dart
    │       │       │   └── auth_state.dart
    │       │       └── pages/
    │       │           ├── login_page.dart
    │       │           └── profile_page.dart
    │       │
    │       ├── tasks/                   ← Feature: Tareas
    │       │   ├── data/
    │       │   │   ├── datasources/
    │       │   │   │   └── task_remote_datasource.dart
    │       │   │   ├── models/
    │       │   │   │   └── task_model.dart
    │       │   │   └── repositories/
    │       │   │       └── task_repository_impl.dart
    │       │   ├── domain/
    │       │   │   ├── entities/
    │       │   │   │   └── task.dart
    │       │   │   ├── repositories/
    │       │   │   │   └── task_repository.dart
    │       │   │   └── usecases/
    │       │   │       ├── get_tasks_usecase.dart
    │       │   │       ├── create_task_usecase.dart
    │       │   │       ├── update_task_usecase.dart
    │       │   │       └── delete_task_usecase.dart
    │       │   └── presentation/
    │       │       ├── cubit/
    │       │       │   ├── task_cubit.dart
    │       │       │   └── task_state.dart
    │       │       └── pages/
    │       │           ├── tasks_page.dart
    │       │           └── task_detail_page.dart
    │       │
    │       └── home/                    ← Feature: Home
    │           └── presentation/
    │               └── pages/
    │                   └── home_page.dart
    │
    └── test/
        ├── core/
        │   └── error/
        │       └── failures_test.dart
        └── features/
            ├── auth/
            │   ├── domain/
            │   │   └── usecases/
            │   │       └── login_usecase_test.dart
            │   └── presentation/
            │       └── cubit/
            │           └── auth_cubit_test.dart
            └── tasks/
                ├── data/
                │   └── repositories/
                │       └── task_repository_impl_test.dart
                └── domain/
                    └── usecases/
                        └── get_tasks_usecase_test.dart
```

### Explicación de Cada Capa en Flutter

#### Domain (Igual que antes)

```dart
// lib/features/tasks/domain/entities/task.dart

class Task extends Equatable {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;
  
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
  });
  
  bool get isNew => DateTime.now().difference(createdAt).inDays < 7;
  
  @override
  List<Object?> get props => [id, title, description, isCompleted, createdAt];
}
```

#### Data (Ahora usa Serverpod Client)

```dart
// lib/features/tasks/data/datasources/task_remote_datasource.dart

abstract class TaskRemoteDataSource {
  Future<List<Task>> getTasks();
  Future<Task> createTask(String title, String? description);
  Future<Task> updateTask(int id, {String? title, bool? isCompleted});
  Future<void> deleteTask(int id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Client client;
  
  TaskRemoteDataSourceImpl(this.client);
  
  @override
  Future<List<Task>> getTasks() async {
    final serverTasks = await client.tasksEndpoint.getTasks();
    return serverTasks.map(_toEntity).toList();
  }
  
  @override
  Future<Task> createTask(String title, String? description) async {
    final input = CreateTaskInput(
      title: title,
      description: description,
    );
    final serverTask = await client.tasksEndpoint.createTask(input);
    return _toEntity(serverTask);
  }
  
  Task _toEntity(dynamic serverTask) {
    return Task(
      id: serverTask.id,
      title: serverTask.title,
      description: serverTask.description,
      isCompleted: serverTask.isCompleted,
      createdAt: serverTask.createdAt,
    );
  }
}
```

---

## 4. Modelos y Generación Automática

### Definición de Modelos en YAML

Serverpod usa archivos YAML para definir modelos que se traducen automáticamente a código Dart y SQL:

```yaml
# models/task.yaml

class: Task
table: tasks
fields:
  title: String(100)
  description: String? # nullable
  isCompleted: bool
  createdAt: DateTime
  userId: int, relation=parent=User
```

```yaml
# models/user.yaml

class: User
table: users
fields:
  email: String(100), unique
  name: String(100)
  passwordHash: String
  createdAt: DateTime, defaultValue=now
```

### Comandos de Generación

```bash
# En el directorio del servidor
cd my_serverpod_project_server

# Generar todo el código (protocolo, cliente, migraciones)
serverpod generate

# Generar solo el protocolo (modelos)
serverpod generate --protocol

# Generar migraciones
serverpod create migration add_priority_field
```

### Flujo de Generación

```
    ┌─────────────────────────────────────────────────────────┐
    │                    FLUJO DE GENERACIÓN                 │
    └─────────────────────────────────────────────────────────┘
    
    1. DEFINES MODELO EN YAML
    ══════════════════════════
    
    models/task.yaml
    ```
    class: Task
    table: tasks
    fields:
      title: String
      isCompleted: bool
    ```
    
    │
    ▼
    
    2. EJECUTAS serverpod generate
    ════════════════════════════
    
    $ serverpod generate
    
    │
    ▼
    
    3. SE GENERA CÓDIGO AUTOMÁTICAMENTE
    ═══════════════════════════════════
    
    models/generated/protocol.dart
    - Clase Task
    - Métodos CRUD: insert, update, delete, findById, findAll
    - Tipos serializables
    
    lib/src/generated/protocol.dart
    - Clases serializables para comunicación
    - DTOs automáticos
    
    lib/src/generated/endpoints/
    - Stub de endpoints
    ```
    
    │
    ▼
    
    4. USAS EL CÓDIGO GENERADO
    ══════════════════════════
    
    // En tu endpoint
    Future<Task> createTask(Session session, CreateTaskInput input) async {
      final task = Task(
        title: input.title,
        isCompleted: false,
      );
      await task.insert(session);
      return task;
    }
```

---

## 5. Templates de Código

### Template: Endpoint

```dart
// lib/src/endpoints/{feature}_endpoint.dart

import 'package:serverpod/serverpod.dart';
import '../services/{feature}_service.dart';
import '../models/{feature}_input.dart';
import '../models/{feature}_response.dart';

class {Feature}Endpoint extends Endpoint {
  final {Feature}Service _service;
  
  {Feature}Endpoint(this._service);
  
  // Obtener todos
  Future<List<{Feature}Response>> getAll(Session session) async {
    // TODO: Implementar
  }
  
  // Obtener por ID
  Future<{Feature}Response?> getById(Session session, int id) async {
    // TODO: Implementar
  }
  
  // Crear
  Future<{Feature}Response> create(Session session, Create{Feature}Input input) async {
    // TODO: Implementar
  }
  
  // Actualizar
  Future<{Feature}Response> update(Session session, Update{Feature}Input input) async {
    // TODO: Implementar
  }
  
  // Eliminar
  Future<void> delete(Session session, int id) async {
    // TODO: Implementar
  }
}
```

### Template: Service

```dart
// lib/src/services/{feature}_service.dart

import '../models/{feature}_input.dart';
import '../models/{feature}_response.dart';
import '../exceptions/app_exception.dart';

class {Feature}Service {
  {Feature}Response create(Create{Feature}Input input) {
    // 1. Validaciones de negocio
    _validateInput(input);
    
    // 2. Crear modelo de respuesta
    return {Feature}Response(
      id: 0, // Se asigna al guardar
      title: input.title,
      createdAt: DateTime.now(),
    );
  }
  
  void _validateInput(Create{Feature}Input input) {
    if (input.title.isEmpty) {
      throw ValidationException('El título no puede estar vacío');
    }
    
    if (input.title.length > 100) {
      throw ValidationException('El título es demasiado largo');
    }
  }
}
```

### Template: Input DTO

```dart
// lib/src/models/create_{feature}_input.dart

class Create{Feature}Input {
  final String title;
  final String? description;
  
  const Create{Feature}Input({
    required this.title,
    this.description,
  });
  
  static Create{Feature}Input fromJson(Map<String, dynamic> json) {
    return Create{Feature}Input(
      title: json['title'] as String,
      description: json['description'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
```

### Template: Response DTO

```dart
// lib/src/models/{feature}_response.dart

class {Feature}Response {
  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  
  const {Feature}Response({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
```

---

## 6. Organización por Features

### Principio Fundamental

```
    REGLA: Cada feature es completamente independiente
    
    ✅ CORRECTO:
    features/
    ├── auth/          ← Todo lo de autenticación aquí
    ├── tasks/         ← Todo lo de tareas aquí
    └── users/         ← Todo lo de usuarios aquí
    
    ❌ INCORRECTO:
    features/
    ├── cubits/        ← NO: mezcla de features
    ├── repositories/  ← NO: mezcla de features
    └── models/        ← NO: mezcla de features
```

### Feature Completa Ejemplo

```
    features/
    └── tasks/
        │
        ├── data/
        │   ├── datasources/
        │   │   └── task_remote_datasource.dart
        │   │   ```
        │   │   // Se conecta al cliente de Serverpod
        │   │   ```
        │   │
        │   ├── models/
        │   │   └── task_model.dart
        │   │   ```
        │   │   // Extensión del Entity con serialización
        │   │   ```
        │   │
        │   └── repositories/
        │       └── task_repository_impl.dart
        │       ```
        │       // Implementa el contrato del dominio
        │       ```
        │
        ├── domain/
        │   ├── entities/
        │   │   └── task.dart
        │   │   ```
        │   │   // Objeto de negocio puro
        │   │   class Task extends Equatable {
        │   │     final int id;
        │   │     final String title;
        │   │   }
        │   │   ```
        │   │
        │   ├── repositories/
        │   │   └── task_repository.dart
        │   │   ```
        │   │   // Contrato abstracto
        │   │   abstract class TaskRepository {
        │   │     Future<Either<Failure, List<Task>>> getTasks();
        │   │   }
        │   │   ```
        │   │
        │   └── usecases/
        │       ├── get_tasks_usecase.dart
        │       ├── create_task_usecase.dart
        │       ├── update_task_usecase.dart
        │       └── delete_task_usecase.dart
        │
        └── presentation/
            ├── cubit/
            │   ├── task_cubit.dart
            │   └── task_state.dart
            │
            └── pages/
                ├── tasks_page.dart
                └── task_detail_page.dart
```

---

## 📝 Resumen

Después de leer este documento, deberías saber:

- ✅ La estructura completa de un proyecto Serverpod
- ✅ Cómo organizar el servidor (endpoints, services, models)
- ✅ Cómo organizar el cliente Flutter
- ✅ Cómo usar la generación automática de Serverpod
- ✅ Templates para crear nuevo código rápidamente
- ✅ El principio de organizar por features

---

## 🎯 Próximo Paso

Continúa con [04-MODELS-Y-DATABASE.md](./04-MODELS-Y-DATABASE.md) para aprender sobre modelos, ORM y base de datos en Serverpod.
