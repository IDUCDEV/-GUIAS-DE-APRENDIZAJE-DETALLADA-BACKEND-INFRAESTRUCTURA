# Testing en Backend con Serverpod

> Aprende a escribir tests unitarios e integración para tu backend Serverpod, aplicando los mismos principios de testing que ya conoces de Flutter.

---

## Tabla de Contenidos

1. [Introducción al Testing en Serverpod](#1-introducción-al-testing-en-serverpod)
2. [Estructura de Tests](#2-estructura-de-tests)
3. [Testing de Servicios (Unit Tests)](#3-testing-de-servicios-unit-tests)
4. [Testing de Endpoints (Integration Tests)](#4-testing-de-endpoints-integration-tests)
5. [Testing con Mocks](#5-testing-con-mocks)
6. [Buenas Prácticas de Testing](#6-buenas-prácticas-de-testing)

---

## 1. Introducción al Testing en Serverpod

### Por Qué Testear tu Backend

```
    BENEFICIOS DEL TESTING EN BACKEND
    ═════════════════════════════════
    
    ✅ Confianza: Sabes que tu API funciona antes de deployar
    ✅ Regression: Cambios no rompen funcionalidades existentes
    ✅ Documentación: Los tests documentan el comportamiento esperado
    ✅ Velocidad: Tests rápidos vs testing manual
    ✅ Bugs baratos: Encontrar bugs en desarrollo es 10x más barato
```

### Herramientas de Testing

| Herramienta | Propósito |
|-------------|-----------|
| `serverpod_test` | Framework de testing de Serverpod |
| `flutter_test` | Testing general de Dart |
| `mocktail` | Crear mocks sin código generado |
| `build_runner` | Generación de código |

### Tipos de Tests

```
    PIRÁMIDE DE TESTS
    ═════════════════
    
                    ▲
                   /E2E\
                  /─────\
                 /INTEG. \
                /─────────\
               /   UNIT    \
              /─────────────\
             ╱               ╲
```

| Nivel | Qué testea | Velocidad | Cantidad |
|-------|-----------|-----------|----------|
| **Unit** | Servicios, lógica pura | ⚡⚡⚡ Rápido | Muchas |
| **Integration** | Endpoints, base de datos | ⚡⚡ Medio | Pocas |
| **E2E** | Flujo completo | ⚡ Lento | Muy pocas |

---

## 2. Estructura de Tests

### Estructura de Carpetas

```
    my_serverpod_project_server/
    ├── test/
    │   ├── unit/                          ← Tests unitarios
    │   │   ├── services/
    │   │   │   ├── task_service_test.dart
    │   │   │   └── user_service_test.dart
    │   │   └── models/
    │   │       └── task_model_test.dart
    │   │
    │   ├── integration/                   ← Tests de integración
    │   │   ├── endpoints/
    │   │   │   ├── tasks_endpoint_test.dart
    │   │   │   └── auth_endpoint_test.dart
    │   │   └── services/
    │   │       └── task_crud_test.dart
    │   │
    │   └── helpers/
    │       ├── mock_services.dart
    │       └── test_data.dart
    │
    └── lib/
        └── src/
            ├── services/
            └── endpoints/
```

### Importaciones en Tests

Serverpod genera archivos de test automáticamente:

```dart
// ✅ CORRECTO: Importar desde generated
import 'package:my_serverpod_server/src/generated/protocol.dart';
import 'serverpod_test_tools.dart';  // No importar serverpod_test directamente

// ❌ INCORRECTO: Importar packages manualmente
import 'package:serverpod_test/serverpod_test.dart';  // Evitar
```

---

## 3. Testing de Servicios (Unit Tests)

### Configuración del Test

```dart
// test/unit/services/task_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_serverpod_server/src/services/task_service.dart';
import 'package:my_serverpod_server/src/models/create_task_input.dart';
import 'package:my_serverpod_server/src/exceptions/app_exceptions.dart';

void main() {
  late TaskService taskService;
  
  setUp(() {
    // Crear instancia del servicio
    // Los unit tests de servicios no necesitan dependencias reales
    taskService = TaskService();
  });
  
  group('TaskService', () {
    group('createTask', () {
      // Tests van aquí
    });
  });
}
```

### Tests de Creación (Éxito)

```dart
group('createTask - éxito', () {
  test('debe crear tarea con título válido', () {
    // Arrange
    const input = CreateTaskInput(
      title: 'Mi tarea',
      description: 'Descripción opcional',
    );
    const userId = 1;
    
    // Act
    final task = taskService.createTask(input, userId);
    
    // Assert
    expect(task.title, 'Mi tarea');
    expect(task.description, 'Descripción opcional');
    expect(task.userId, userId);
    expect(task.isCompleted, false);
    expect(task.createdAt, isNotNull);
  });
  
  test('debe crear tarea sin descripción', () {
    // Arrange
    const input = CreateTaskInput(title: 'Tarea sin descripción');
    const userId = 1;
    
    // Act
    final task = taskService.createTask(input, userId);
    
    // Assert
    expect(task.title, 'Tarea sin descripción');
    expect(task.description, isNull);
  });
  
  test('debe usar prioridad por defecto si no se especifica', () {
    // Arrange
    const input = CreateTaskInput(title: 'Tarea');
    const userId = 1;
    
    // Act
    final task = taskService.createTask(input, userId);
    
    // Assert
    expect(task.priority, 1); // Valor por defecto
  });
});
```

### Tests de Validación (Errores)

```dart
group('createTask - validación', () {
  test('debe lanzar excepción si el título está vacío', () {
    // Arrange
    const input = CreateTaskInput(title: '');
    const userId = 1;
    
    // Act & Assert
    expect(
      () => taskService.createTask(input, userId),
      throwsA(isA<ValidationException>()),
    );
  });
  
  test('debe lanzar excepción si el título solo tiene espacios', () {
    // Arrange
    const input = CreateTaskInput(title: '   ');
    const userId = 1;
    
    // Act & Assert
    expect(
      () => taskService.createTask(input, userId),
      throwsA(isA<ValidationException>()),
    );
  });
  
  test('debe lanzar excepción si el título excede 100 caracteres', () {
    // Arrange
    final longTitle = 'A' * 101;
    final input = CreateTaskInput(title: longTitle);
    const userId = 1;
    
    // Act & Assert
    expect(
      () => taskService.createTask(input, userId),
      throwsA(
        isA<ValidationException>().having(
          (e) => e.message,
          'message',
          contains('100'),
        ),
      ),
    );
  });
  
  test('debe lanzar excepción si la descripción excede 500 caracteres', () {
    // Arrange
    final longDescription = 'A' * 501;
    final input = CreateTaskInput(
      title: 'Tarea',
      description: longDescription,
    );
    const userId = 1;
    
    // Act & Assert
    expect(
      () => taskService.createTask(input, userId),
      throwsA(isA<ValidationException>()),
    );
  });
  
  test('debe lanzar excepción si la prioridad está fuera de rango', () {
    // Arrange
    const input = CreateTaskInput(title: 'Tarea', priority: 6);
    const userId = 1;
    
    // Act & Assert
    expect(
      () => taskService.createTask(input, userId),
      throwsA(isA<ValidationException>()),
    );
  });
});
```

### Tests de Autorización

```dart
group('createTask - autorización', () {
  test('debe asignar el userId correcto a la tarea', () {
    // Arrange
    const input = CreateTaskInput(title: 'Tarea');
    const userId = 42;
    
    // Act
    final task = taskService.createTask(input, userId);
    
    // Assert
    expect(task.userId, userId);
  });
});
```

---

## 4. Testing de Endpoints (Integration Tests)

### Configuración con `withServerpod`

```dart
// test/integration/endpoints/tasks_endpoint_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_test/serverpod_test.dart';
import 'package:my_serverpod_server/src/generated/protocol.dart';
import 'package:my_serverpod_server/src/models/create_task_input.dart';

void main() {
  // withServerpod configura automáticamente:
  // - Base de datos de test (transacciones rollback)
  // - Session de test
  // - Endpoints disponibles
  withServerpod('TasksEndpoint', (sessionBuilder, endpoints) {
    late Session session;
    late TasksEndpoint tasksEndpoint;
    
    setUp(() {
      session = sessionBuilder.build();
      tasksEndpoint = endpoints.tasksEndpoint;
    });
    
    group('TasksEndpoint', () {
      // Tests van aquí
    });
  });
}
```

### Tests de Endpoints (CRUD)

```dart
group('TasksEndpoint - CRUD', () {
  // ─────────────────────────────────────────────────────────
  // CREATE
  // ─────────────────────────────────────────────────────────
  
  test('createTask debe crear tarea exitosamente', () async {
    // Arrange
    final input = CreateTaskInput(title: 'Nueva tarea');
    
    // Act
    final task = await tasksEndpoint.createTask(session, input);
    
    // Assert
    expect(task.title, 'Nueva tarea');
    expect(task.id, isPositive); // ID asignado por la BD
    expect(task.isCompleted, false);
  });
  
  test('createTask debe rechazar título vacío', () async {
    // Arrange
    final input = CreateTaskInput(title: '');
    
    // Act & Assert
    expect(
      () => tasksEndpoint.createTask(session, input),
      throwsA(isA<ServerpodException>()),
    );
  });
  
  // ─────────────────────────────────────────────────────────
  // READ
  // ─────────────────────────────────────────────────────────
  
  test('getTasks debe devolver lista de tareas', () async {
    // Arrange: Crear algunas tareas primero
    await tasksEndpoint.createTask(
      session, 
      CreateTaskInput(title: 'Tarea 1'),
    );
    await tasksEndpoint.createTask(
      session, 
      CreateTaskInput(title: 'Tarea 2'),
    );
    
    // Act
    final tasks = await tasksEndpoint.getTasks(session);
    
    // Assert
    expect(tasks.length, 2);
    expect(tasks[0].title, 'Tarea 1');
    expect(tasks[1].title, 'Tarea 2');
  });
  
  test('getTask debe devolver tarea específica', () async {
    // Arrange
    final created = await tasksEndpoint.createTask(
      session,
      CreateTaskInput(title: 'Tarea específica'),
    );
    
    // Act
    final task = await tasksEndpoint.getTask(session, created.id);
    
    // Assert
    expect(task, isNotNull);
    expect(task!.title, 'Tarea específica');
  });
  
  test('getTask debe lanzar excepción si no existe', () async {
    // Act & Assert
    expect(
      () => tasksEndpoint.getTask(session, 999999),
      throwsA(isA<ServerpodException>()),
    );
  });
  
  // ─────────────────────────────────────────────────────────
  // UPDATE
  // ─────────────────────────────────────────────────────────
  
  test('updateTask debe actualizar título exitosamente', () async {
    // Arrange
    final created = await tasksEndpoint.createTask(
      session,
      CreateTaskInput(title: 'Título original'),
    );
    
    // Act
    final updated = await tasksEndpoint.updateTask(
      session,
      UpdateTaskInput(id: created.id, title: 'Título actualizado'),
    );
    
    // Assert
    expect(updated.title, 'Título actualizado');
    expect(updated.id, created.id); // ID no cambia
  });
  
  test('updateTask debe marcar tarea como completada', () async {
    // Arrange
    final created = await tasksEndpoint.createTask(
      session,
      CreateTaskInput(title: 'Tarea pendiente'),
    );
    expect(created.isCompleted, false);
    
    // Act
    final updated = await tasksEndpoint.updateTask(
      session,
      UpdateTaskInput(id: created.id, isCompleted: true),
    );
    
    // Assert
    expect(updated.isCompleted, true);
  });
  
  // ─────────────────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────────────────
  
  test('deleteTask debe eliminar tarea exitosamente', () async {
    // Arrange
    final created = await tasksEndpoint.createTask(
      session,
      CreateTaskInput(title: 'Tarea a eliminar'),
    );
    
    // Act
    await tasksEndpoint.deleteTask(session, created.id);
    
    // Assert
    expect(
      () => tasksEndpoint.getTask(session, created.id),
      throwsA(isA<ServerpodException>()),
    );
  });
});
```

### Limpieza Automática de Datos

```dart
// withServerpod hace rollback automático después de cada test
// No necesitas tearDown para limpiar la base de datos

withServerpod('TasksEndpoint', (sessionBuilder, endpoints) {
  test('primera tanda de tests', () async {
    await tasksEndpoint.createTask(session, CreateTaskInput(title: 'T1'));
    // La base de datos se limpia automáticamente
  });
  
  test('segunda tanda - datos limpios', () async {
    // No hay datos de tests anteriores
    final tasks = await tasksEndpoint.getTasks(session);
    expect(tasks.length, 0);
  });
});
```

### Configurar Datos en setUp

```dart
withServerpod('TasksEndpoint', (sessionBuilder, endpoints) {
  late Session session;
  late TasksEndpoint tasksEndpoint;
  late User testUser;
  
  setUp(() async {
    session = sessionBuilder.build();
    tasksEndpoint = endpoints.tasksEndpoint;
    
    // Crear usuario de test
    testUser = User(
      email: 'test@test.com',
      name: 'Test User',
    );
    await testUser.insert(session);
  });
  
  test('debe crear tarea para el usuario de test', () async {
    // Arrange
    final input = CreateTaskInput(title: 'Tarea del usuario');
    
    // Act
    final task = await tasksEndpoint.createTask(
      session,
      input,
      userId: testUser.id,
    );
    
    // Assert
    expect(task.userId, testUser.id);
  });
});
```

---

## 5. Testing con Mocks

### Cuándo Usar Mocks

```
    CUÁNDO USAR MOCTS
    ═════════════════
    
    ✅ Usar mocks para:
    - Servicios externos (email, storage)
    - Servicios lentos (integraciones de terceros)
    - Servicios no determinísticos (fecha/hora actual)
    - Dependencias no disponibles en tests
    
    ❌ No usar mocks para:
    - La base de datos (Serverpod ya la maneja)
    - Servicios simples sin dependencias externas
    - Tests de integración reales
```

### Crear Mocks con Mocktail

```dart
// test/helpers/mock_services.dart

import 'package:mocktail/mocktail.dart';
import 'package:my_serverpod_server/src/services/email_service.dart';
import 'package:my_serverpod_server/src/services/notification_service.dart';

class MockEmailService extends Mock implements EmailService {}
class MockNotificationService extends Mock implements NotificationService {}
```

### Tests con Mocks

```dart
// test/unit/services/task_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_serverpod_server/src/services/task_service.dart';
import 'package:my_serverpod_server/src/services/notification_service.dart';
import '../helpers/mock_services.dart';

void main() {
  late TaskService taskService;
  late MockNotificationService mockNotificationService;
  
  setUp(() {
    mockNotificationService = MockNotificationService();
    
    // Crear servicio con mock
    taskService = TaskService(
      notificationService: mockNotificationService,
    );
  });
  
  group('createTask - notificaciones', () {
    test('debe enviar notificación después de crear tarea', () async {
      // Arrange
      const input = CreateTaskInput(title: 'Nueva tarea');
      const userId = 1;
      const userEmail = 'user@test.com';
      
      when(() => mockNotificationService.notifyTaskCreated(
        userEmail,
        any(),
      )).thenAnswer((_) async {});
      
      // Act
      await taskService.createTask(input, userId, userEmail);
      
      // Assert
      verify(() => mockNotificationService.notifyTaskCreated(
        userEmail,
        any(named: 'task'),
      )).called(1);
    });
    
    test('no debe fallar si la notificación falla', () async {
      // Arrange
      const input = CreateTaskInput(title: 'Nueva tarea');
      const userId = 1;
      const userEmail = 'user@test.com';
      
      when(() => mockNotificationService.notifyTaskCreated(
        userEmail,
        any(),
      )).thenThrow(Exception('Error de email'));
      
      // Act & Assert - No debe lanzar
      expect(
        () => taskService.createTask(input, userId, userEmail),
        returnsNormally,
      );
    });
  });
}
```

### Registrar Mocks en Integration Tests

```dart
withServerpod('TasksEndpoint', (sessionBuilder, endpoints) {
  late MockNotificationService mockNotificationService;
  
  setUp(() {
    mockNotificationService = MockNotificationService();
    
    // Registrar mock en el servicio
    // (Esto depende de tu implementación de DI)
  });
  
  test('createTask debe enviar notificación', () async {
    // Arrange
    when(() => mockNotificationService.notifyTaskCreated(
      any(),
      any(),
    )).thenAnswer((_) async {});
    
    // Act
    await endpoints.tasksEndpoint.createTask(
      session,
      CreateTaskInput(title: 'Nueva tarea'),
    );
    
    // Assert
    verify(() => mockNotificationService.notifyTaskCreated(
      any(),
      any(),
    )).called(1);
  });
});
```

---

## 6. Buenas Prácticas de Testing

### Naming Conventions

```dart
group('TaskService.createTask', () {
  group('validación', () {
    test('debe lanzar excepción si título está vacío', () {...});
    test('debe lanzar excepción si título excede límite', () {...});
  });
  
  group('éxito', () {
    test('debe crear tarea con datos válidos', () {...});
    test('debe usar valores por defecto opcionales', () {...});
  });
});
```

### Estructura AAA

```dart
test('debe crear tarea exitosamente', () {
  // Arrange: Preparar datos y dependencias
  const input = CreateTaskInput(title: 'Nueva tarea');
  const userId = 1;
  
  // Act: Ejecutar la acción a probar
  final task = taskService.createTask(input, userId);
  
  // Assert: Verificar el resultado esperado
  expect(task.title, 'Nueva tarea');
  expect(task.userId, userId);
});
```

### Tests Independientes

```dart
// ✅ CORRECTO: Cada test es independiente
test('createTask debe crear tarea', () async {
  final task = await tasksEndpoint.createTask(
    session,
    CreateTaskInput(title: 'T1'),
  );
  expect(task.title, 'T1');
});

test('getTasks debe devolver todas las tareas', () async {
  // No depende de tests anteriores
  // Serverpod limpia la BD automáticamente
  final tasks = await tasksEndpoint.getTasks(session);
  expect(tasks.isNotEmpty, true);
});

// ❌ INCORRECTO: Tests que dependen de orden
test('primero crear tarea', () async {
  // ...
});

test('después obtener tareas', () async {
  // Este test depende del anterior - MAL
});
```

### Cobertura Recomendada

| Componente | Cobertura Mínima |
|------------|------------------|
| **Services** | 90%+ (lógica de negocio crítica) |
| **Endpoints** | 80%+ (validaciones, respuestas) |
| **Models** | 70%+ (serialización) |
| **Excepciones** | 80%+ (todos los casos de error) |

### Checklist de Test

```
    TESTS DE UNIDAD
    ───────────────
    [ ] Tests para casos de éxito
    [ ] Tests para cada tipo de error
    [ ] Tests para valores límite
    [ ] Tests para valores nulos
    [ ] Tests para autorización/permisos

    TESTS DE INTEGRACIÓN
    ─────────────────────
    [ ] Tests CRUD completos
    [ ] Tests de validación de inputs
    [ ] Tests de errores de base de datos
    [ ] Tests de autenticación
    [ ] Tests de transacciones

    TESTS DE MOCKS
    ───────────────
    [ ] Mocks para servicios externos
    [ ] Verificación de llamadas a mocks
    [ ] Comportamiento cuando mock falla
```

---

## 📝 Resumen

Después de leer este documento, deberías saber:

- ✅ La estructura de tests en Serverpod
- ✅ Escribir tests unitarios de servicios
- ✅ Escribir tests de integración de endpoints
- ✅ Usar mocks con mocktail
- ✅ Las mejores prácticas de testing
- ✅ La pirámide de tests y qué testear en cada nivel

---

## 🎯 ¡Felicidades!

Has completado la guía de **Clean Architecture para Backend con Serverpod**. Ahora tienes todas las herramientas para:

1. Entender los conceptos de backend desde tu perspectiva mobile
2. Aplicar Clean Architecture en tu proyecto Serverpod
3. Crear modelos, endpoints y servicios escalables
4. Implementar autenticación y autorizaciones
5. Escribir tests para tu backend

**Próximos pasos recomendados:**

1. Instala Serverpod y crea tu primer proyecto
2. Practica con los ejemplos de esta guía
3. Lee la documentación oficial de Serverpod
4. Únete al Discord de Serverpod para comunidad
5. Implementa tu primera app completa

¡Buena suerte en tu transición a backend!
