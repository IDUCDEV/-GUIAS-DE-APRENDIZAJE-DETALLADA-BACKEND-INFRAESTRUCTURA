# Práctica: Prompts Optimizados para Serverpod

> Colección de prompts específicos para desarrollo backend con Serverpod, aplicando el framework AIDR

---

## Tabla de Contenidos

1. [Prompts para Models (YAML)](#1-prompts-para-models-yaml)
2. [Prompts para Endpoints](#2-prompts-para-endpoints)
3. [Prompts para Services](#3-prompts-para-services)
4. [Prompts para DTOs](#4-prompts-para-dtos)
5. [Prompts para Exceptions](#5-prompts-para-exceptions)
6. [Prompts para Testing](#6-prompts-para-testing)
7. [Prompts para Debugging](#7-prompts-para-debugging)
8. [Prompts para Refactoring](#8-prompts-para-refactoring)

---

## 1. Prompts para Models (YAML)

### Prompt 1: Model básico completo

```markdown
# PROMPT

"Crea un archivo YAML de modelo Serverpod para [NOMBRE_ENTIDAD] con:

Campos básicos:
- id: int (auto increment)
- name: String(100)
- description: String?, long
- createdAt: DateTime, defaultValue=now
- updatedAt: DateTime

Relaciones:
- [relación_1]: int, relation=parent=[ModeloPadre]
- [relación_2]: List<[ModeloHijo]>, relation=children

Índices:
- Índice único en [campo_unique]
- Índice compuesto en [campo1, campo2]

Enum si aplica: [nombre_enum] con valores [val1, val2, val3]

Genera el archivo YAML completo y el enum si es necesario."

# EJEMPLO REAL

"Crea un archivo YAML de modelo Serverpod para RESERVATION con:

Campos básicos:
- id: int (auto increment)
- dateTime: DateTime
- status: ReservationStatus
- notes: String?, long
- createdAt: DateTime, defaultValue=now

Relaciones:
- clientId: int, relation=parent=User
- serviceId: int, relation=parent=Service

Enum: ReservationStatus con valores pending, confirmed, cancelled, completed, no_show

Índices:
- Índice en clientId para queries rápidas
- Índice compuesto en dateTime + status

Genera el archivo YAML completo."
```

### Prompt 2: Model con relaciones complejas

```markdown
# PROMPT

"Crea modelos YAML para un sistema de [DOMINIO] con:

1. Modelo principal: [Modelo] con campos [lista]
2. Modelo secundario: [Modelo2] con campos [lista]
3. Relación muchos a muchos entre ellos

Usa la sintaxis de relation=manyToMany de Serverpod.

Incluye:
- Índices apropiados
- Campos de auditoría (createdAt, updatedAt)
- Valores por defecto razonables

Genera todos los archivos YAML."
```

### Prompt 3: Enum para status/estados

```markdown
# PROMPT

"Crea un archivo YAML de enum Serverpod para [NOMBRE_ENUM] con los siguientes valores:

- [valor1]: Descripción breve
- [valor2]: Descripción breve  
- [valor3]: Descripción breve

El enum se usará para [contexto de uso] en el modelo [Modelo].

Genera el archivo YAML del enum."
```

---

## 2. Prompts para Endpoints

### Prompt 4: Scaffold de Endpoint CRUD

```markdown
# PROMPT

"Crea una plantilla de Endpoint de Serverpod para [FEATURE] con operaciones CRUD completas.

Estructura esperada:

```dart
class [Feature]Endpoint extends Endpoint {
  final [Feature]Service _service;
  
  [Feature]Endpoint(this._service);
  
  // READ ALL - Obtener todos
  Future<List<[Model]>> getAll[Features](Session session, {
    int? limit,
    int? offset,
  }) async {
    // TODO: Implementar
  }
  
  // READ ONE - Obtener por ID
  Future<[Model]?> get[Feature]ById(Session session, int id) async {
    // TODO: Implementar
  }
  
  // CREATE - Crear nuevo
  Future<[Model]> create[Feature](Session session, Create[Feature]Input input) async {
    // TODO: Implementar
  }
  
  // UPDATE - Actualizar existente
  Future<[Model]> update[Feature](Session session, Update[Feature]Input input) async {
    // TODO: Implementar
  }
  
  // DELETE - Eliminar
  Future<void> delete[Feature](Session session, int id) async {
    // TODO: Implementar
  }
}
```

Incluye:
- Anotación @Route si es necesario
- Manejo básico de session
- Typed inputs (crea los DTOs de input)
- TODO comments donde yo implementaré la lógica

Genera el archivo completo."
```

### Prompt 5: Endpoint con autenticación

```markdown
# PROMPT

"Crea un Endpoint de Serverpod protegido con autenticación para [FEATURE].

Requisitos:
- Todos los métodos requieren autenticación (@requireAuth)
- El userId viene de session.auth.authenticatedUser!.id
- Incluir validación de ownership (solo usuarios pueden ver/modificar sus propios datos)

```dart
class [Feature]Endpoint extends Endpoint {
  @override
  bool get requireAuth => true;
  
  final [Feature]Service _service;
  
  [Feature]Endpoint(this._service);
  
  // Métodos con auth check...
}
```

Genera el endpoint completo con auth."
```

### Prompt 6: Endpoint con paginación

```markdown
# PROMPT

"Crea un Endpoint de Serverpod para listar [FEATURE] con paginación.

Parámetros:
- limit: int (default 20, max 100)
- offset: int (default 0)
- sortBy: String (campo de ordenamiento)
- sortDesc: bool (default false)

Respuesta:
- List<[Model]> items
- int totalCount
- bool hasMore

Implementación esperada:
- Usar findAll de Serverpod con orderBy y limit/offset
- Contar total con consulta separada
- Retornar paginated response

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final bool hasMore;
}
```

Genera el endpoint completo."
```

---

## 3. Prompts para Services

### Prompt 7: Scaffold de Service con lógica

```markdown
# PROMPT

"Crea el esqueleto de Service para [FEATURE] en Serverpod.

El service debe incluir:

```dart
class [Feature]Service {
  // Dependencias (inyectadas por constructor)
  final [Repo1] _[repo1];
  final [Repo2] _[repo2];
  
  [Feature]Service({
    required [Repo1] [repo1],
    required [Repo2] [repo2],
  });
  
  // ═══════════════════════════════════════════════════════════════
  // MÉTODOS - TODO: Implementar lógica de negocio
  // ═══════════════════════════════════════════════════════════════
  
  [Model] create[Feature](Create[Feature]Input input, int userId) {
    // TODO 1: Validar input (usar _validateInput)
    // TODO 2: Verificar permisos/precondiciones
    // TODO 3: Crear modelo
    // TODO 4: Persistir
    // TODO 5: Retornar resultado
    throw UnimplementedError();
  }
  
  [Model] update[Feature](Update[Feature]Input input, int userId) {
    // TODO: Implementar
    throw UnimplementedError();
  }
  
  void delete[Feature](int id, int userId) {
    // TODO: Implementar
    throw UnimplementedError();
  }
  
  List<[Model]> getAll[Features](int userId, {int? limit, int? offset}) {
    // TODO: Implementar
    throw UnimplementedError();
  }
  
  // ═══════════════════════════════════════════════════════════════
  // VALIDACIONES PRIVADAS
  // ═══════════════════════════════════════════════════════════════
  
  void _validateInput(Create[Feature]Input input) {
    // TODO: Validaciones de negocio
    // throw ValidationException si falla
  }
  
  void _validateOwnership([Model] model, int userId) {
    // TODO: Verificar que userId es dueño del recurso
    // throw UnauthorizedException si no tiene permisos
  }
}
```

Incluye:
- Dependencias como mocks (para testing)
- TODOs bien comentados
- Métodos privados de validación
- Excepciones apropiadas

Genera el archivo completo."
```

### Prompt 8: Service con lógica de negocio compleja

```markdown
# PROMPT

"Crea un Service de Serverpod para [FEATURE] que incluya esta lógica de negocio específica:

[DESCRIBE LA LÓGICA DE NEGOCIO]

Ejemplo de lo que necesito:
- Validación 1: [regla de negocio]
- Validación 2: [regla de negocio]
- Condición 3: [lógica condicional]
- Edge case handling: [cómo manejar]

El service debe:
1. Lanzar excepciones específicas de negocio
2. Incluir logging con session.logger
3. Manejar race conditions apropiadamente
4. Ser testeable con mocks

Genera el service completo con la estructura."
```

---

## 4. Prompts para DTOs

### Prompt 9: Input DTO completo

```markdown
# PROMPT

"Crea un Input DTO de Serverpod para crear [FEATURE].

Estructura:

```dart
class Create[Feature]Input {
  final [tipo] [campo1];
  final [tipo] [campo2]?;
  final [tipo] [campo3];
  
  const Create[Feature]Input({
    required this.[campo1],
    this.[campo2],
    required this.[campo3],
  });
  
  // Constructor fromJson (Serverpod lo genera, pero incluye este para referencia)
  static Create[Feature]Input fromJson(Map<String, dynamic> json) {
    return Create[Feature]Input(
      [campo1]: json['[campo1]'] as [tipo],
      [campo2]: json['[campo2]'] as [tipo]?,
      [campo3]: json['[campo3]'] as [tipo],
    );
  }
  
  // Validación básica (para referencia, la lógica real va en el Service)
  bool isValid() {
    return [campo1] != null && [campo1].isNotEmpty;
  }
}
```

Genera el archivo con todos los campos apropiados para [FEATURE]."
```

### Prompt 10: Update DTO con campos opcionales

```markdown
# PROMPT

"Crea un Update DTO de Serverpod para [FEATURE] donde todos los campos son opcionales (para actualizaciones parciales).

Estructura:

```dart
class Update[Feature]Input {
  final int id; // Siempre requerido
  final String? [campo1];
  final String? [campo2]?;
  final int? [campo3];
  
  const Update[Feature]Input({
    required this.id,
    this.[campo1],
    this.[campo2],
    this.[campo3],
  });
  
  // Verificar si hay algo que actualizar
  bool get hasUpdates => [campo1] != null || [campo2] != null || [campo3] != null;
  
  // Aplicar updates a un modelo existente
  [Model] applyTo([Model] existing) {
    return existing
      ..[campo1] = [campo1] ?? existing.[campo1]
      ..[campo2] = [campo2] ?? existing.[campo2]
      ..[campo3] = [campo3] ?? existing.[campo3];
  }
}
```

Genera el archivo."
```

### Prompt 11: Response DTO con datos relacionados

```markdown
# PROMPT

"Crea un Response DTO de Serverpod para [FEATURE] que incluya datos relacionados.

Estructura:

```dart
class [Feature]Response {
  final int id;
  final String [campo1];
  final [TipoSimple] [campo2];
  
  // Datos relacionados (DTOs anidados)
  final [RelatedModel]Response? [related];
  final List<[AnotherModel]Response> [others];
  
  // Timestamps formateados
  final String createdAtFormatted; // "dd/MM/yyyy HH:mm"
  
  const [Feature]Response({
    required this.id,
    required this.[campo1],
    required this.[campo2],
    this.[related],
    this.[others] = const [],
    required this.createdAtFormatted,
  });
  
  // Factory desde modelo de BD
  factory [Feature]Response.fromModel([Model] model, {Session? session}) {
    return [Feature]Response(
      id: model.id,
      [campo1]: model.[campo1],
      [campo2]: model.[campo2],
      [related]: model.[related] != null 
          ? [RelatedModel]Response.fromModel(model.[related]!) 
          : null,
      createdAtFormatted: _formatDate(model.createdAt),
    );
  }
  
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
```

Genera el archivo completo con los DTOs anidados."
```

---

## 5. Prompts para Exceptions

### Prompt 12: Exceptions de negocio

```markdown
# PROMPT

"Crea las excepciones personalizadas para el módulo de [FEATURE] en Serverpod.

Estructura base:

```dart
// Excepción base del módulo
class [Feature]Exception implements Exception {
  final String message;
  final String? code;
  
  const [Feature]Exception(this.message, {this.code});
  
  @override
  String toString() => message;
}

// Excepciones específicas de negocio
class [Feature]ValidationException extends [Feature]Exception {
  const [Feature]ValidationException(super.message);
}

class [Feature]NotFoundException extends [Feature]Exception {
  const [Feature]NotFoundException(super.message);
}

class [Feature]UnauthorizedException extends [Feature]Exception {
  const [Feature]UnauthorizedException(super.message);
}

class [Feature]ConflictException extends [Feature]Exception {
  const [Feature]ConflictException(super.message);
}

// Excepciones específicas
// [Agregar excepciones específicas del negocio]
```

Lista de excepciones que necesito:
1. [NombreExcepcion1]: cuando [situación]
2. [NombreExcepcion2]: cuando [situación]
3. [NombreExcepcion3]: cuando [situación]

Genera el archivo completo."
```

---

## 6. Prompts para Testing

### Prompt 13: Tests para Service

```markdown
# PROMPT

"Crea el scaffold de tests para [Feature]Service en Serverpod usando mockito.

Estructura esperada:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:my_server/src/services/[feature]_service.dart';
import 'package:my_server/src/repositories/[feature]_repository.dart';
import 'package:my_server/src/exceptions/[feature]_exceptions.dart';

@GenerateMocks([[Feature]Repository])
import '[feature]_service_test.mocks.dart';

void main() {
  late [Feature]Service service;
  late Mock[Feature]Repository mockRepository;
  
  setUp(() {
    mockRepository = Mock[Feature]Repository();
    service = [Feature]Service(repository: mockRepository);
  });
  
  // ═══════════════════════════════════════════════════════════════
  // TEST DATA - ✍️ YO COMPLETARÉ CON DATOS REALISTAS
  // ═══════════════════════════════════════════════════════════════
  
  final validInput = Create[Feature]Input(/* TODO */);
  final test[Feature] = [Model](/* TODO */);
  
  // ═══════════════════════════════════════════════════════════════
  // TESTS - ✍️ YO ESCRIBIRÉ LAS ASERCIONES
  // ═══════════════════════════════════════════════════════════════
  
  group('[Feature]Service', () {
    group('create[Feature]', () {
      test('should create [feature] when input is valid', () async {
        // arrange - TODO: Configurar mocks
        when(mockRepository.create(any)).thenAnswer((_) async => test[Feature]);
        
        // act
        final result = await service.create[Feature](validInput, userId: 1);
        
        // assert - TODO: Mi aserción
        expect(result, isA<[Model]>());
      });
      
      test('should throw [Exception] when [condition]', () async {
        // arrange - TODO: Configurar mock para fallar
        when(mockRepository.create(any)).thenThrow([Exception]Exception());
        
        // act & assert - TODO: Mi aserción
        expect(
          () => service.create[Feature](validInput, userId: 1),
          throwsA(isA<[Exception]>()),
        );
      });
    });
  });
}
```

Incluye:
- Imports necesarios
- Generación de mocks con @GenerateMocks
- Test data como TODOs (yo los completaré)
- Estructura de groups y tests
- Casos: success, validation error, not found, unauthorized, etc.

Genera el archivo completo."
```

### Prompt 14: Tests de integración de Repository

```markdown
# PROMPT

"Crea tests de integración para [Feature]Repository usando fakes en Serverpod.

Estructura esperada:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod/serverpod.dart';

import 'package:my_server/src/models/[feature].yaml.dart';
import 'package:my_server/src/repositories/[feature]_repository.dart';

void main() {
  late Session session;
  late [Feature]Repository repository;
  late Database db;
  
  setUp(() async {
    // Setup de base de datos en memoria para tests
    db = Database(
      connection: MockDatabaseConnection(),
    );
    session = Session(database: db);
    repository = [Feature]Repository();
  });
  
  tearDown(() async {
    await session.close();
  });
  
  // ═══════════════════════════════════════════════════════════════
  // TESTS
  // ═══════════════════════════════════════════════════════════════
  
  group('[Feature]Repository Integration', () {
    test('should insert and retrieve [feature]', () async {
      // arrange
      final [feature] = [Model](
        name: 'Test [Feature]',
        createdAt: DateTime.now(),
      );
      
      // act
      await repository.insert(session, [feature]);
      final retrieved = await repository.findById(session, [feature].id);
      
      // assert
      expect(retrieved?.name, 'Test [Feature]');
    });
    
    test('should return null for non-existent id', () async {
      // act
      final result = await repository.findById(session, 9999);
      
      // assert
      expect(result, isNull);
    });
    
    test('should update existing [feature]', () async {
      // arrange
      final [feature] = await _createTest[Feature](session);
      
      // act
      [feature].name = 'Updated Name';
      await repository.update(session, [feature]);
      final retrieved = await repository.findById(session, [feature].id);
      
      // assert
      expect(retrieved?.name, 'Updated Name');
    });
    
    test('should delete [feature]', () async {
      // arrange
      final [feature] = await _createTest[Feature](session);
      
      // act
      await repository.delete(session, [feature].id);
      final retrieved = await repository.findById(session, [feature].id);
      
      // assert
      expect(retrieved, isNull);
    });
  });
  
  // Helper
  Future<[Model]> _createTest[Feature](Session session) async {
    final [feature] = [Model](
      name: 'Test [Feature]',
      createdAt: DateTime.now(),
    );
    await repository.insert(session, [feature]);
    return [feature];
  }
}
```

Genera el archivo completo."
```

---

## 7. Prompts para Debugging

### Prompt 15: Analizar error

```markdown
# PROMPT

"Estoy recibiendo este error en [ARCHIVO:LÍNEA]:

```
[MENSAJE_COMPLETO_DEL_ERROR]
```

Stack trace:
```
[STACK_TRACE]
```

Contexto:
- Versión de Serverpod: [VERSIÓN]
- Versión de Dart: [VERSIÓN]
- El error ocurre cuando: [DESCRIPCIÓN_DE_CUÁNDO_OCURRE]
- Endpoint/Service involucrado: [NOMBRE]

¿Puedes ayudarme a entender:
1. ¿Qué está causando este error?
2. ¿Cómo solucionarlo paso a paso?
3. ¿Cómo prevenirlo en el futuro?

Sé específico y dame código de ejemplo."
```

### Prompt 16: Analizar query lenta

```markdown
# PROMPT

"Tenemos un problema de performance en [ENDPOINT/SERVICE]. El endpoint tarda [TIEMPO] en responder con [N] registros.

Información:
- Endpoint: [NOMBRE]
- Tiempo actual: [TIEMPO]
- Tiempo objetivo: [TIEMPO]
- Número de registros: [N]
- Query actual:

```dart
[CÓDIGO_DE_LA_QUERY]
```

¿Puedes ayudarme a:
1. Identificar el cuello de botella
2. Sugerir optimizaciones (índices, query restructuring, caching)
3. Proponer una solución con código

Considera:
- Índices en PostgreSQL
- Pagination
- Caching
- Query N+1 problems"
```

---

## 8. Prompts para Refactoring

### Prompt 17: Refactorizar Service grande

```markdown
# PROMPT

"Tengo un Service de Serverpod que está creciendo demasiado y necesita refactoring.

Service actual: [Feature]Service con [N] métodos
Problema: [DESCRIBE_EL_PROBLEMA]

```dart
[CÓDIGO_DEL_SERVICE_ACTUAL]
```

Suggestions que necesito:
1. Extraer métodos a classes separadas si aplica
2. Identificar métodos que podrían ser use cases independientes
3. Mejorar naming de métodos y variables
4. Sugerir patterns (Strategy, Template Method, etc.)

Mantenlo testeable y sigue las convenciones de Serverpod."
```

### Prompt 18: Agregar validaciones

```markdown
# PROMPT

"Quiero agregar validaciones más robustas a [METHOD] en [FEATURE]Service.

Contexto:
- Método actual: [NOMBRE]
- Validaciones actuales: [LISTA]
- Validaciones faltantes: [LISTA]

```dart
[CÓDIGO_ACTUAL_DEL_MÉTODO]
```

Reglas de negocio que necesito validar:
1. [Regla 1]
2. [Regla 2]
3. [Regla 3]

Agrega:
- Métodos de validación privados bien nombrados
- Excepciones específicas para cada tipo de error
- Tests para las nuevas validaciones

Genera el código actualizado."
```

---

## Resumen Rápido

```
┌─────────────────────────────────────────────────────────────────┐
│              CHEAT SHEET DE PROMPTS SERVERPOD                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📁 MODELS                                                       │
│     P1: Model básico completo                                   │
│     P2: Model con relaciones complejas                           │
│     P3: Enum para estados                                       │
│                                                                 │
│  🏗️ ENDPOINTS                                                    │
│     P4: Scaffold CRUD completo                                  │
│     P5: Endpoint con autenticación                              │
│     P6: Endpoint con paginación                                 │
│                                                                 │
│  💼 SERVICES                                                    │
│     P7: Scaffold con lógica                                     │
│     P8: Lógica de negocio compleja                              │
│                                                                 │
│  📦 DTOs                                                        │
│     P9: Input DTO completo                                      │
│     P10: Update DTO con campos opcionales                        │
│     P11: Response DTO con datos relacionados                    │
│                                                                 │
│  ⚠️ EXCEPTIONS                                                  │
│     P12: Exceptions de negocio                                   │
│                                                                 │
│  🧪 TESTING                                                     │
│     P13: Tests para Service                                     │
│     P14: Tests de integración de Repository                      │
│                                                                 │
│  🔍 DEBUGGING                                                   │
│     P15: Analizar error                                         │
│     P16: Analizar query lenta                                   │
│                                                                 │
│  ✨ REFACTORING                                                 │
│     P17: Refactorizar Service grande                             │
│     P18: Agregar validaciones                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

*Este documento complementa la guía principal `🤖 GUÍA - Uso Inteligente de IA en Desarrollo Backend con Serverpod.md`*

*Recuerda: IA genera el scaffold, tú implementas la lógica de negocio.*
