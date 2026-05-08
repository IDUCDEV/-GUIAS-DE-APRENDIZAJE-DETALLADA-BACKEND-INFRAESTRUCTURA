# Inyección de Dependencias en Serverpod

> Aprende cómo Serverpod maneja la inyección de dependencias y cómo configurar tu propio sistema de DI para servicios.

---

## Tabla de Contenidos

1. [Introducción a la DI en Serverpod](#1-introducción-a-la-di-en-serverpod)
2. [Registro de Servicios](#2-registro-de-servicios)
3. [Inyección en Endpoints](#3-inyección-en-endpoints)
4. [Service Locator Manual](#4-service-locator-manual)
5. [Scoped Sessions](#5-scoped-sessions)
6. [Buenas Prácticas](#6-buenas-prácticas)

---

## 1. Introducción a la DI en Serverpod

### ¿Cómo Funciona?

Serverpod usa un sistema de **inyección de dependencias basado en constructores**. Cuando creas un endpoint, Serverpod automáticamente inyecta las dependencias que declaras en el constructor.

```
    FLUTTER (GetIt)                     SERVERPOD (Constructor DI)
    ═════════════════                  ══════════════════════════
    
    getIt.registerFactory<TaskCubit>(    Endpoint(Service service)
      () => TaskCubit(getIt<TaskRepo>     ↓
    );                             Serverpod detecta el constructor
                                    y resuelve la dependencia
    context.read<TaskCubit>();
```

### Diferencia con Flutter

| Aspecto | Flutter (GetIt) | Serverpod |
|---------|----------------|-----------|
| **Registro** | Manual con `registerFactory` | Automático basado en constructores |
| **Obtención** | `getIt<Service>()` | Se pasa en constructor |
| **Scope** | Global | Por request (Session) |
| **Lazy loading** | Configurable | Por defecto |

---

## 2. Registro de Servicios

### Registro Automático (Predeterminado)

Serverpod automáticamente resuelve las dependencias de los endpoints:

```dart
// Serverpod detecta automáticamente:
// 1. TasksEndpoint necesita TaskService
// 2. Busca TaskService en el scope
// 3. Lo inyecta automáticamente

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);  // ← Serverpod inyecta automáticamente
}

// TaskService puede tener sus propias dependencias
class TaskService {
  final EmailService _emailService;
  final CacheService _cacheService;
  
  TaskService(this._emailService, this._cacheService);
}
```

### Crear Servicios Sin Dependencias

```dart
// lib/src/services/task_service.dart

class TaskService {
  // Este servicio no tiene dependencias
  // Serverpod lo creará automáticamente
  
  List<Task> filterCompleted(List<Task> tasks) {
    return tasks.where((t) => t.isCompleted).toList();
  }
  
  List<Task> filterPending(List<Task> tasks) {
    return tasks.where((t) => !t.isCompleted).toList();
  }
}
```

### Crear Servicios con Dependencias

```dart
// lib/src/services/email_service.dart

class EmailService {
  // Servicio que envía emails
  // También podría inyectar un cliente HTTP, etc.
  
  Future<void> sendTaskCreatedEmail(String email, Task task) async {
    // Lógica para enviar email
  }
}
```

```dart
// lib/src/services/notification_service.dart

class NotificationService {
  final EmailService _emailService;
  
  NotificationService(this._emailService);  // ← Inyección
  
  Future<void> notifyTaskCreated(String email, Task task) async {
    await _emailService.sendTaskCreatedEmail(email, task);
  }
}
```

```dart
// lib/src/services/task_service.dart

class TaskService {
  final NotificationService _notificationService;
  final CacheService _cacheService;
  
  TaskService(
    this._notificationService,
    this._cacheService,
  );
  
  Future<Task> createTask(CreateTaskInput input, int userId) async {
    // Crear tarea...
    await _notificationService.notifyTaskCreated(userEmail, task);
    await _cacheService.invalidate('tasks_$userId');
    return task;
  }
}
```

---

## 3. Inyección en Endpoints

### Patrón Estándar

```dart
// lib/src/endpoints/tasks_endpoint.dart

class TasksEndpoint extends Endpoint {
  // Serverpod inyecta TaskService automáticamente
  final TaskService _taskService;
  
  TasksEndpoint(this._taskService);
  
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    return await _taskService.getTasksForUser(userId);
  }
}
```

### Múltiples Servicios

```dart
// lib/src/endpoints/tasks_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  final AnalyticsService _analyticsService;
  final CacheService _cacheService;
  
  TasksEndpoint(
    this._taskService,
    this._analyticsService,
    this._cacheService,
  );
  
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    
    // Usar cache si está disponible
    final cached = await _cacheService.get<List<Task>>('tasks_$userId');
    if (cached != null) {
      _analyticsService.trackCacheHit('tasks');
      return cached;
    }
    
    final tasks = await _taskService.getTasksForUser(userId);
    await _cacheService.set('tasks_$userId', tasks);
    
    return tasks;
  }
}
```

### Constructor con Parámetros Opcionales

```dart
// Si un servicio tiene dependencias opcionales, usa Optional

import 'package:serverpod/service_protocol.dart';

class TaskService {
  final NotificationService? _notificationService;
  final AnalyticsService _analyticsService;
  
  TaskService({
    NotificationService? notificationService,
    required AnalyticsService analyticsService,
  })  : _notificationService = notificationService,
        _analyticsService = analyticsService;
  
  Future<void> notify(String email, Task task) async {
    // Solo envía notificación si el servicio está disponible
    await _notificationService?.notifyTaskCreated(email, task);
  }
}
```

---

## 4. Service Locator Manual

### Cuándo Usar Service Locator

Para casos donde la inyección por constructor no es suficiente:

- Acceso a servicios desde fuera de endpoints
- Utilidades globales
- Clientes HTTP externos
- Configuración de la aplicación

### Implementación con Service Locator

```dart
// lib/src/utilities/service_locator.dart

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();
  
  final Map<Type, Object> _services = {};
  
  void register<T extends Object>(T service) {
    _services[T] = service;
  }
  
  T get<T extends Object>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service $T not registered');
    }
    return service as T;
  }
  
  void registerLazy<T extends Object>(T Function() factory) {
    _services[T] = LazyService<T>(factory);
  }
}

// Wrapper para inicialización lazy
class LazyService<T> {
  final T Function() _factory;
  T? _instance;
  
  LazyService(this._factory);
  
  T get instance {
    _instance ??= _factory();
    return _instance!;
  }
}
```

### Configuración en main.dart

```dart
// lib/main.dart

import '../utilities/service_locator.dart';

void main(List<String> args) async {
  // 1. Configurar servicios antes de iniciar el servidor
  _configureServices();
  
  // 2. Iniciar el servidor
  await run(args);
}

void _configureServices() {
  final locator = ServiceLocator();
  
  // Registrar servicios
  locator.register<EmailService>(EmailService(
    apiKey: 'your-api-key',
  ));
  
  locator.register<AnalyticsService>(AnalyticsService());
  
  locator.register<CacheService>(CacheService());
  
  // Servicios lazy para inicialización tardía
  locator.registerLazy<StorageService>(() => StorageService(
    bucket: 'my-bucket',
  ));
}
```

### Uso del Service Locator

```dart
// lib/src/services/notification_service.dart

class NotificationService {
  final EmailService _emailService;
  
  NotificationService(this._emailService);
  
  Future<void> sendWelcomeEmail(String email) async {
    await _emailService.send(
      to: email,
      subject: 'Bienvenido',
      body: 'Gracias por registrarte',
    );
  }
}

// En un endpoint que no tiene inyección directa
class OnboardingEndpoint extends Endpoint {
  @override
  bool get requireAuth => false;
  
  Future<void> completeOnboarding(Session session, String email) async {
    final locator = ServiceLocator();
    final notificationService = locator.get<NotificationService>();
    
    await notificationService.sendWelcomeEmail(email);
  }
}
```

---

## 5. Scoped Sessions

### ¿Qué es una Scoped Session?

Una **Scoped Session** es una sesión que existe durante un request y puede almacenar datos específicos de ese request.

```
    REQUEST LIFECYCLE
    ══════════════════
    
    Request llega
          │
          ▼
    ┌─────────────────┐
    │ Session se crea │
    │ (con DI)        │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Endpoint recibe │
    │ la session      │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Session puede   │
    │ almacenar datos │
    │ (cache local)   │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Response se     │
    │ envía           │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Session se      │
    │ destruye        │
    └─────────────────┘
```

### Almacenar Datos en Session

```dart
// lib/src/endpoints/task_endpoint.dart

class TasksEndpoint extends Endpoint {
  final TaskService _taskService;
  final CacheService _cacheService;
  
  TasksEndpoint(this._taskService, this._cacheService);
  
  Future<List<Task>> getTasks(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    
    // Almacenar en session para uso posterior
    session.data['currentUserId'] = userId;
    session.data['requestTime'] = DateTime.now();
    
    // También podemos usar métodos convenientes
    session.set('tasksLoaded', true);
    
    return await _taskService.getTasksForUser(userId);
  }
}
```

### Acceder a Datos de Session

```dart
// lib/src/services/task_service.dart

class TaskService {
  Future<List<Task>> getTasksForUser(int userId) async {
    // Esta lógica no conoce la session
    // Solo trabaja con los datos pasados
    final tasks = await Task.findAll(
      session,  // Necesita la session para acceder a la BD
      where: (t) => t.userId.equals(userId),
    );
    
    return tasks;
  }
}
```

### Middleware de Session

```dart
// lib/src/middleware/session_middleware.dart

class AppSessionMiddleware extends Middleware {
  @override
  Future<FutureOr<Response>?> handleCall(
    Endpoint endpoint,
    Session session,
    JsonApiRequest request,
    void Function(Response) callback,
  ) async {
    // Loguear inicio de request
    session.logger.info('Request started: ${endpoint.name}');
    
    // Marcar tiempo de inicio
    final startTime = DateTime.now();
    
    // Continuar con el request
    callback(Response());
    
    // Calcular duración
    final duration = DateTime.now().difference(startTime);
    session.logger.info('Request completed in ${duration.inMilliseconds}ms');
    
    return null; // Response ya fue enviada via callback
  }
}
```

---

## 6. Buenas Prácticas

### ✅ Hacer: Constructor con Dependencias Finales

```dart
// ✅ CORRECTO
class TaskService {
  final TaskRepository _repository;
  final NotificationService _notifications;
  
  TaskService(
    this._repository,
    this._notifications,
  );
}
```

### ❌ No Hacer: Dependencias Mutables

```dart
// ❌ INCORRECTO
class TaskService {
  TaskRepository _repository;  // mutable
  var _count = 0;              // estado mutable
  
  TaskService(this._repository);
  
  void setRepository(TaskRepository repo) {
    _repository = repo;  // No hacer esto
  }
}
```

### ✅ Hacer: Interfaces para Servicios

```dart
// lib/src/services/interfaces/task_service_interface.dart

abstract class TaskServiceInterface {
  Future<Task> createTask(CreateTaskInput input, int userId);
  Future<List<Task>> getTasksForUser(int userId);
  Future<Task> updateTask(int id, UpdateTaskInput input, int userId);
  Future<void> deleteTask(int id, int userId);
}

// lib/src/services/task_service_impl.dart

class TaskServiceImpl implements TaskServiceInterface {
  // Implementación concreta
}

// lib/src/services/task_service_mock.dart (para testing)

class MockTaskService implements TaskServiceInterface {
  // Mock para testing
}
```

### ✅ Hacer: Inyección de Valores de Configuración

```dart
// lib/src/config/app_config.dart

class AppConfig {
  final int maxTasksPerUser;
  final int taskTitleMaxLength;
  final Duration cacheExpiration;
  
  const AppConfig({
    this.maxTasksPerUser = 100,
    this.taskTitleMaxLength = 100,
    this.cacheExpiration = const Duration(minutes: 5),
  });
}

// Registro
final config = AppConfig(
  maxTasksPerUser: 50,
);

ServiceLocator().register<AppConfig>(config);

// Uso
class TaskService {
  final AppConfig _config;
  
  TaskService(this._config);
  
  void validateTaskLimit(int currentCount) {
    if (currentCount >= _config.maxTasksPerUser) {
      throw ValidationException(
        'Has alcanzado el límite de ${_config.maxTasksPerUser} tareas',
      );
    }
  }
}
```

### Template de Servicio Completo

```dart
// lib/src/services/{feature}_service.dart

import 'package:serverpod/serverpod.dart';
import '../models/{feature}_input.dart';
import '../exceptions/app_exceptions.dart';

/// Servicio de dominio para la gestión de {feature}
///
/// Responsabilidades:
/// - Validaciones de lógica de negocio
/// - Transformaciones de datos
/// - Reglas de autorización
///
/// NO es responsable de:
/// - Acceso directo a HTTP
/// - Serialización/Deserialización
/// - Acceso a la base de datos directamente
class {Feature}Service {
  /// Constructor con todas las dependencias
  /// Serverpod inyecta automáticamente las dependencias en endpoints
  {Feature}Service();
  
  /// Crea una nueva instancia de {Feature}
  {Model} create{Feature}(Create{Feature}Input input, int userId) {
    // 1. Validaciones de negocio
    _validateCreateInput(input);
    
    // 2. Crear el modelo
    final {model} = {Model}(
      name: input.name,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    return {model};
  }
  
  /// Actualiza una {feature} existente
  {Model} update{Feature}(
    {Model} existing,
    Update{Feature}Input input,
    int userId,
  ) {
    // 1. Verificar propiedad
    _validateOwnership(existing, userId);
    
    // 2. Validar input
    _validateUpdateInput(input);
    
    // 3. Aplicar actualizaciones
    if (input.name != null) {
      existing.name = input.name!;
    }
    
    return existing;
  }
  
  /// Elimina una {feature}
  void delete{Feature}({Model} {model}, int userId) {
    _validateOwnership({model}, userId);
  }
  
  // ═══════════════════════════════════════════════════════════
  // MÉTODOS PRIVADOS DE VALIDACIÓN
  // ═══════════════════════════════════════════════════════════
  
  void _validateCreateInput(Create{Feature}Input input) {
    if (input.name.trim().isEmpty) {
      throw const ValidationException('El nombre es requerido');
    }
  }
  
  void _validateUpdateInput(Update{Feature}Input input) {
    if (input.name != null && input.name!.trim().isEmpty) {
      throw const ValidationException('El nombre no puede estar vacío');
    }
  }
  
  void _validateOwnership({Model} {model}, int userId) {
    if ({model}.userId != userId) {
      throw const UnauthorizedException(
        'No tienes permiso para modificar este recurso',
      );
    }
  }
}
```

---

## 📝 Resumen

Después de leer este documento, deberías saber:

- ✅ Cómo Serverpod maneja la inyección de dependencias
- ✅ Registrar servicios con y sin dependencias
- ✅ Inyectar múltiples servicios en endpoints
- ✅ Implementar un service locator manual cuando sea necesario
- ✅ Usar scoped sessions para almacenar datos por request
- ✅ Seguir las mejores prácticas de DI

---

## 🎯 Próximo Paso

Continúa con [07-TESTING-BACKEND.md](./07-TESTING-BACKEND.md) para aprender a escribir tests para tu backend Serverpod.
