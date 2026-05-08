# Endpoints y Servicios en Serverpod

> Aprende a crear endpoints (controladores), servicios (lógica de negocio), autenticación y validaciones en Serverpod.

---

## Tabla de Contenidos

1. [Endpoints: El Punto de Entrada](#1-endpoints-el-punto-de-entrada)
2. [Services: La Lógica de Negocio](#2-services-la-lógica-de-negocio)
3. [Autenticación Profesional con 'serverpod_auth'](#3-autenticación-profesional-con-serverpod_auth)
4. [Streams: Comunicación en Tiempo Real (WebSockets)](#4-streams-comunicación-en-tiempo-real-websockets)
5. [Validaciones y Manejo de Errores](#5-validaciones-y-manejo-de-errores)
6. [DTOs: Input y Output](#6-dtos-input-y-output)
7. [Ejemplo Completo de CRUD](#7-ejemplo-completo-de-crud)
8. [Logging y Monitoreo](#8-logging-y-monitoreo)

---

## 1. Endpoints: El Punto de Entrada

### ¿Qué es un Endpoint?

Un endpoint es un **método RPC** (Remote Procedure Call) que el cliente puede llamar. Es similar a un controller en otros frameworks o a un método de API REST.

```
    EQUIVALENCIAS DE ENDPOINTS
    ═══════════════════════════
    
    Flutter (Riverpod)     Serverpod           REST API
    ──────────────────     ─────────           ───────
    FutureProvider         Endpoint method      GET /resource
    StateNotifier         Endpoint method      POST /resource
    AsyncNotifier         Endpoint method      PUT /resource/:id
```

### Estructura Básica de un Endpoint

```dart
// lib/src/endpoints/tasks_endpoint.dart

import 'package:serverpod/serverpod.dart';
import '../services/task_service.dart';

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  // Cada método público es un endpoint RPC callable desde el cliente
  Future<List<Task>> getTasks(Session session) async {
    // Tu código aquí
  }
  
  Future<Task> createTask(Session session, String title) async {
    // Tu código aquí
  }
}
```

### Métodos del Endpoint

Serverpod automáticamente genera clientes para estos métodos:

```dart
// Cliente generado automáticamente en Flutter
// my_serverpod_client_flutter/lib/src/generated/protocol.dart

class Client {
  late TasksEndpoint tasksEndpoint;
  
  Future<List<Task>> getTasks() async {
    // Implementación automática
  }
}
```

### Uso desde Flutter

```dart
// En tu app Flutter
final client = Client('https://api.myserver.com');

// Llamar al endpoint como si fuera una función local
final tasks = await client.tasksEndpoint.getTasks();
final task = await client.tasksEndpoint.createTask('Mi nueva tarea');
```

---

## 2. Services: La Lógica de Negocio

### Separación de Responsabilidades

```
    ENDPOINT vs SERVICE
    ═══════════════════
    
    ENDPOINT (Controlador)       SERVICE (UseCase)
    ───────────────────────       ─────────────────
    - Recibe requests            - Contiene lógica de negocio
    - Valida parámetros          - Valida reglas de negocio
    - Llama al service           - No conoce HTTP ni BD
    - Maneja excepciones         - Lanza excepciones de negocio
    - Formatea respuestas        - Devuelve objetos de dominio
```

### Ejemplo de Service

```dart
// lib/src/services/task_service.dart

class TaskService {
  Task createTask({
    required String title,
    required int userId,
    String? description,
  }) {
    // VALIDACIONES DE NEGOCIO
    // ───────────────────────
    
    // 1. Validar título no vacío
    if (title.trim().isEmpty) {
      throw ValidationException('El título no puede estar vacío');
    }
    
    // 2. Validar longitud máxima
    if (title.length > 100) {
      throw ValidationException('El título no puede superar 100 caracteres');
    }
    
    // 3. Validar descripción si existe
    if (description != null && description.length > 500) {
      throw ValidationException('La descripción es demasiado larga');
    }
    
    // CREAR EL MODELO
    // ───────────────
    final task = Task(
      title: title.trim(),
      description: description?.trim(),
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    return task;
  }
  
  List<Task> getTasksForUser(List<Task> allTasks, int userId) {
    return allTasks.where((t) => t.userId == userId).toList();
  }
}
```

### Conectar Endpoint con Service

```dart
// lib/src/endpoints/tasks_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  Future<List<Task>> getTasks(Session session) async {
    // Obtener ID del usuario autenticado
    final userId = session.auth.authenticatedUser!.id;
    
    // Obtener todas las tareas
    final allTasks = await Task.findAll(session);
    
    // Delegar lógica al service
    return _taskService.getTasksForUser(allTasks, userId);
  }
  
  Future<Task> createTask(Session session, String title, {String? description}) async {
    // Obtener ID del usuario autenticado
    final userId = session.auth.authenticatedUser!.id;
    
    // Delegar validación y creación al service
    final task = _taskService.createTask(
      title: title,
      userId: userId,
      description: description,
    );
    
    // Guardar en base de datos
    await task.insert(session);
    
    return task;
  }
}

---

## 3. Autenticación Profesional con 'serverpod_auth'

### ¿Por qué usar el módulo oficial?
No reinventes la rueda. Serverpod ofrece el paquete 'serverpod_auth' que ya implementa de forma segura:
- Registro e inicio de sesión por Email/Password.
- Verificación de emails y recuperación de contraseñas.
- Integración nativa con Google, Apple, y Facebook.
- Gestión de sesiones y tokens JWT automáticos.

### Configuración en el Servidor
1. Añade la dependencia en tu 'pubspec.yaml' del servidor:
```yaml
dependencies:
  serverpod_auth_server: ^3.0.0
```
2. Configura el módulo en tu 'main.dart':
```dart
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), ...);
  auth.AuthConfig.set(auth.AuthConfig(
    sendValidationEmail: (session, email, validationCode) async {
      print('Código de validación para $email: $validationCode');
      return true;
    },
  ));
  await pod.start();
}
```

### Proteger Endpoints en Serverpod v3
```dart
class TasksEndpoint extends Endpoint {
  @override
  bool get requireAuth => true;

  Future<void> createTask(Session session, Task task) async {
    final userInfo = await session.auth.authenticatedUser;
    task.userId = userInfo!.id!;
    await Task.db.insertRow(session, task);
  }
}
```

### Integración en Flutter (Cliente)
```dart
var client = Client('http://localhost:8080/')..setModules([
  auth.AuthModule(),
]);
var result = await client.modules.auth.email.authenticate('user@test.com', 'pass123');
```

---

## 4. Streams: Comunicación en Tiempo Real (WebSockets)

### ¿Qué es un Stream en Serverpod?
Permite enviar datos 'Push' al cliente. Ideal para chats, notificaciones o dashboards en vivo.

### Ejemplo: Notificaciones de Tareas
```dart
class TaskNotificationsEndpoint extends Endpoint {
  @override
  Future<void> streamOpened(StreamingSession session) async {
    session.messages.addListener('updates', (message) {
      sendStreamMessage(session, message);
    });
  }

  @override
  Future<void> handleStreamMessage(StreamingSession session, SerializableModel message) async {
    if (message is TaskUpdateMessage) {
      session.messages.postMessage('updates', message);
    }
  }
}
```

### Uso en Flutter (Cliente)
```dart
client.taskNotifications.stream.listen((message) {
  if (message is TaskUpdateMessage) {
    showNotification(message.title, message.description);
  }
});
```

---

## 5. Validaciones y Manejo de Errores

### Excepciones Personalizadas

```dart
// lib/src/exceptions/app_exceptions.dart

class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => message;
}

// Excepciones específicas
class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message);
}

class ForbiddenException extends AppException {
  const ForbiddenException(super.message);
}

class ConflictException extends AppException {
  const ConflictException(super.message);
}

class ServerException extends AppException {
  const ServerException([String message = 'Error interno del servidor'])
      : super(message);
}
```

### Validaciones Comunes

```dart
// lib/src/services/task_service.dart

class TaskService {
  void validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw ValidationException('El título no puede estar vacío');
    }
    
    if (title.length > 100) {
      throw ValidationException('El título no puede superar 100 caracteres');
    }
    
    if (title.length < 3) {
      throw ValidationException('El título debe tener al menos 3 caracteres');
    }
  }
  
  void validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException('El email no tiene un formato válido');
    }
  }
  
  void validatePassword(String password) {
    if (password.length < 8) {
      throw ValidationException('La contraseña debe tener al menos 8 caracteres');
    }
    
    if (!password.contains(RegExp(r'[A-Z]'))) {
      throw ValidationException('La contraseña debe contener al menos una mayúscula');
    }
    
    if (!password.contains(RegExp(r'[0-9]'))) {
      throw ValidationException('La contraseña debe contener al menos un número');
    }
  }
}
```

### Manejo de Errores en Endpoints

```dart
// lib/src/endpoints/tasks_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    try {
      final userId = session.auth.authenticatedUser!.id;
      
      // El service lanza excepciones si hay errores
      final task = _taskService.createTask(
        title: input.title,
        description: input.description,
        userId: userId,
      );
      
      await task.insert(session);
      return task;
      
    } on ValidationException catch (e) {
      // Re-lanzar como excepción de Serverpod
      throw BadRequestException(e.message);
      
    } on NotFoundException catch (e) {
      throw NotFoundException(e.message);
      
    } catch (e) {
      // Loguear errores inesperados
      session.logger.error('Error creando tarea', source: e);
      throw ServerException('Error al crear la tarea');
    }
  }
}
```

### Errores desde Flutter

```dart
// En tu app Flutter

class TaskRepositoryImpl implements TaskRepository {
  final Client client;
  
  @override
  Future<Either<Failure, Task>> createTask(String title) async {
    try {
      final task = await client.tasksEndpoint.createTask(title);
      return Right(task);
      
    } on ServerpodException catch (e) {
      // Manejar según el tipo de error
      if (e.statusCode == 400) {
        // BadRequestException
        return Left(ValidationFailure(e.message));
      } else if (e.statusCode == 404) {
        // NotFoundException
        return Left(NotFoundFailure(e.message));
      } else {
        return Left(ServerFailure(e.message));
      }
    }
  }
}
```

---

## 6. DTOs: Input y Output

### ¿Qué es un DTO?

Un **DTO (Data Transfer Object)** es un objeto que define la estructura de los datos que entran o salen de un endpoint.

```
    DTOs EN SERVERPOD
    ═══════════════════
    
    INPUT DTO                    OUTPUT DTO
    ─────────                   ───────────
    Define qué datos            Define qué datos
    envía el cliente            devuelve el servidor
    
    CreateTaskInput             TaskResponse
    - title (required)          - id
    - description (optional)    - title
                                 - description
                                 - createdAt
```

### Input DTO

```dart
// lib/src/models/create_task_input.dart

class CreateTaskInput {
  final String title;
  final String? description;
  final int? priority;
  
  const CreateTaskInput({
    required this.title,
    this.description,
    this.priority,
  });
  
  static CreateTaskInput fromJson(Map<String, dynamic> json) {
    return CreateTaskInput(
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'priority': priority,
    };
  }
}
```

### Output DTO

```dart
// lib/src/models/task_response.dart

class TaskResponse {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int priority;
  final DateTime createdAt;
  final UserSummaryResponse author;  // DTO anidado
  
  const TaskResponse({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.priority,
    required this.createdAt,
    required this.author,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'author': author.toJson(),
    };
  }
}

// DTO anidado para información parcial del usuario
class UserSummaryResponse {
  final int id;
  final String name;
  
  const UserSummaryResponse({
    required this.id,
    required this.name,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
```

### Usar DTOs en Endpoints

```dart
// lib/src/endpoints/tasks_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  Future<TaskResponse> createTask(Session session, CreateTaskInput input) async {
    final userId = session.auth.authenticatedUser!.id;
    
    // Usar el service para crear la tarea
    final task = _taskService.createTask(input, userId);
    await task.insert(session);
    
    // Obtener el autor para la respuesta
    final author = await User.findById(session, userId);
    
    // Convertir a DTO de respuesta
    return TaskResponse(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      priority: task.priority ?? 0,
      createdAt: task.createdAt,
      author: UserSummaryResponse(
        id: author!.id,
        name: author.displayName,
      ),
    );
  }
  
  Future<List<TaskResponse>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    
    final tasks = await Task.findAll(
      session,
      where: (t) => t.userId.equals(userId),
    );
    
    // Convertir cada tarea a DTO
    return tasks.map((task) => TaskResponse(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: task.isCompleted,
      priority: task.priority ?? 0,
      createdAt: task.createdAt,
      author: UserSummaryResponse(
        id: userId,
        name: session.auth.authenticatedUser!.email,
      ),
    )).toList();
  }
}
```

---

## 7. Ejemplo Completo de CRUD

### Estructura Completa del CRUD

```
    lib/src/
    ├── endpoints/
    │   └── tasks_endpoint.dart
    ├── services/
    │   └── task_service.dart
    ├── models/
    │   ├── create_task_input.dart
    │   ├── update_task_input.dart
    │   └── task_response.dart
    └── exceptions/
        └── app_exceptions.dart
```

### Implementación Completa

```dart
// ═══════════════════════════════════════════════════════════════
// lib/src/exceptions/app_exceptions.dart
// ═══════════════════════════════════════════════════════════════

class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

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

```dart
// ═══════════════════════════════════════════════════════════════
// lib/src/models/create_task_input.dart
// ═══════════════════════════════════════════════════════════════

class CreateTaskInput {
  final String title;
  final String? description;
  final int? priority;
  
  const CreateTaskInput({
    required this.title,
    this.description,
    this.priority,
  });
  
  static CreateTaskInput fromJson(Map<String, dynamic> json) {
    return CreateTaskInput(
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: json['priority'] as int?,
    );
  }
}
```

```dart
// ═══════════════════════════════════════════════════════════════
// lib/src/models/update_task_input.dart
// ═══════════════════════════════════════════════════════════════

class UpdateTaskInput {
  final int id;
  final String? title;
  final String? description;
  final bool? isCompleted;
  final int? priority;
  
  const UpdateTaskInput({
    required this.id,
    this.title,
    this.description,
    this.isCompleted,
    this.priority,
  });
  
  static UpdateTaskInput fromJson(Map<String, dynamic> json) {
    return UpdateTaskInput(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool?,
      priority: json['priority'] as int?,
    );
  }
}
```

```dart
// ═══════════════════════════════════════════════════════════════
// lib/src/services/task_service.dart
// ═══════════════════════════════════════════════════════════════

import '../models/create_task_input.dart';
import '../models/update_task_input.dart';
import '../exceptions/app_exceptions.dart';

class TaskService {
  // ─────────────────────────────────────────────────────────
  // VALIDACIONES
  // ─────────────────────────────────────────────────────────
  
  void validateCreateInput(CreateTaskInput input) {
    if (input.title.trim().isEmpty) {
      throw const ValidationException('El título es requerido');
    }
    
    if (input.title.length > 100) {
      throw const ValidationException('El título es demasiado largo');
    }
    
    if (input.description != null && input.description!.length > 500) {
      throw const ValidationException('La descripción es demasiado larga');
    }
    
    if (input.priority != null && (input.priority! < 1 || input.priority! > 5)) {
      throw const ValidationException('La prioridad debe estar entre 1 y 5');
    }
  }
  
  void validateUpdateInput(UpdateTaskInput input, Task existingTask) {
    if (input.title != null) {
      if (input.title!.trim().isEmpty) {
        throw const ValidationException('El título no puede estar vacío');
      }
      if (input.title!.length > 100) {
        throw const ValidationException('El título es demasiado largo');
      }
    }
    
    if (input.description != null && input.description!.length > 500) {
      throw const ValidationException('La descripción es demasiado larga');
    }
  }
  
  void validateOwnership(Task task, int userId) {
    if (task.userId != userId) {
      throw const UnauthorizedException('No tienes permiso para modificar esta tarea');
    }
  }
  
  // ─────────────────────────────────────────────────────────
  // OPERACIONES DE NEGOCIO
  // ─────────────────────────────────────────────────────────
  
  Task createTask(CreateTaskInput input, int userId) {
    validateCreateInput(input);
    
    return Task(
      title: input.title.trim(),
      description: input.description?.trim(),
      priority: input.priority ?? 1,
      isCompleted: false,
      userId: userId,
      createdAt: DateTime.now(),
    );
  }
  
  Task updateTask(UpdateTaskInput input, Task existingTask, int userId) {
    validateOwnership(existingTask, userId);
    validateUpdateInput(input, existingTask);
    
    // Aplicar actualizaciones
    if (input.title != null) {
      existingTask.title = input.title.trim();
    }
    if (input.description != null) {
      existingTask.description = input.description.trim();
    }
    if (input.isCompleted != null) {
      existingTask.isCompleted = input.isCompleted!;
    }
    if (input.priority != null) {
      existingTask.priority = input.priority;
    }
    
    return existingTask;
  }
  
  void deleteTask(Task task, int userId) {
    validateOwnership(task, userId);
  }
}
```

```dart
// ═══════════════════════════════════════════════════════════════
// lib/src/endpoints/tasks_endpoint.dart
// ═══════════════════════════════════════════════════════════════

import 'package:serverpod/serverpod.dart';
import '../services/task_service.dart';
import '../models/create_task_input.dart';
import '../models/update_task_input.dart';
import '../exceptions/app_exceptions.dart';

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  @override
  bool get requireAuth => true;
  
  // ═══════════════════════════════════════════════════════════
  // READ - Obtener todas las tareas del usuario
  // ═══════════════════════════════════════════════════════════
  
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    
    return await Task.findAll(
      session,
      where: (t) => t.userId.equals(userId),
      orderBy: [Order(Task().createdAt, descending: true)],
    );
  }
  
  // ═══════════════════════════════════════════════════════════
  // READ - Obtener una tarea por ID
  // ═══════════════════════════════════════════════════════════
  
  Future<Task?> getTask(Session session, int taskId) async {
    final task = await Task.findById(session, taskId);
    
    if (task == null) {
      return null;
    }
    
    final userId = session.auth.authenticatedUser!.id;
    _taskService.validateOwnership(task, userId);
    
    return task;
  }
  
  // ═══════════════════════════════════════════════════════════
  // CREATE - Crear nueva tarea
  // ═══════════════════════════════════════════════════════════
  
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    final userId = session.auth.authenticatedUser!.id;
    
    try {
      final task = _taskService.createTask(input, userId);
      await task.insert(session);
      return task;
      
    } on ValidationException catch (e) {
      throw BadRequestException(e.message);
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // UPDATE - Actualizar tarea existente
  // ═══════════════════════════════════════════════════════════
  
  Future<Task> updateTask(Session session, UpdateTaskInput input) async {
    final userId = session.auth.authenticatedUser!.id;
    
    try {
      final existingTask = await Task.findById(session, input.id);
      
      if (existingTask == null) {
        throw NotFoundException('Tarea no encontrada');
      }
      
      final updatedTask = _taskService.updateTask(input, existingTask, userId);
      await updatedTask.update(session);
      
      return updatedTask;
      
    } on ValidationException catch (e) {
      throw BadRequestException(e.message);
    } on NotFoundException catch (e) {
      throw NotFoundException(e.message);
    } on UnauthorizedException catch (e) {
      throw ForbiddenException(e.message);
    }
  }
  
  // ═══════════════════════════════════════════════════════════
  // DELETE - Eliminar tarea
  // ═══════════════════════════════════════════════════════════
  
  Future<void> deleteTask(Session session, int taskId) async {
    final userId = session.auth.authenticatedUser!.id;
    
    try {
      final task = await Task.findById(session, taskId);
      
      if (task == null) {
        throw NotFoundException('Tarea no encontrada');
      }
      
      _taskService.deleteTask(task, userId);
      await task.delete(session);
      
    } on NotFoundException catch (e) {
      throw NotFoundException(e.message);
    } on UnauthorizedException catch (e) {
      throw ForbiddenException(e.message);
    }
  }
}
```

---

## 8. Logging y Monitoreo

### Sistema de Logs de Serverpod

```dart
// Logging básico en endpoint
class TasksEndpoint extends Endpoint {
  Future<Task> createTask(Session session, CreateTaskInput input) async {
    session.logger.info('Creando tarea: ${input.title}');
    
    try {
      final task = await _taskService.createTask(input, userId);
      await task.insert(session);
      
      session.logger.info('Tarea creada exitosamente: ${task.id}');
      return task;
      
    } catch (e) {
      session.logger.error('Error creando tarea', source: e);
      rethrow;
    }
  }
}
```

### Tipos de Logs

| Método | Uso |
|--------|-----|
| `session.logger.debug()` | Información de debug |
| `session.logger.info()` | Información general |
| `session.logger.warn()` | Advertencias |
| `session.logger.error()` | Errores |
| `session.logger.critical()` | Errores críticos |

---

## 📝 Resumen

Después de leer este documento, deberías saber:

- ✅ Cómo crear endpoints en Serverpod
- ✅ Cómo separar la lógica en servicios
- ✅ El sistema de autenticación profesional con 'serverpod_auth'
- ✅ Comunicación en tiempo real con Streams
- ✅ Cómo proteger endpoints con `requireAuth`
- ✅ Validaciones y manejo de errores
- ✅ DTOs de entrada y salida
- ✅ Implementar CRUD completo
- ✅ Logging y monitoreo

---

## 🎯 Próximo Paso

Continúa con [06-DI-DEPENDENCY-INJECTION.md](./06-DI-DEPENDENCY-INJECTION.md) para aprender sobre inyección de dependencias en el backend.
