# Guía: Uso Inteligente de IA en Desarrollo Backend con Serverpod

> Equilibrio entre la asistencia de IA y la escritura manual de código para mantener tus habilidades técnicas sharp

---

## Tabla de Contenidos

1. [Filosofía: Por Qué Buscar el Balance](#1-filosofía)
2. [El Framework AIDR Adaptado](#2-framework-aidr)
3. [Boilerplate vs Lógica Crítica en Backend](#3-boilerplate-vs-lógica-crítica)
4. [Estrategias por Capa de Serverpod](#4-estrategias-por-capa)
5. [Guía de Prompts Optimizados](#5-guía-de-prompts)
6. [Caso de Uso Completo: Feature de Reservas Backend](#6-caso-de-uso)
7. [Testing Híbrido Backend](#7-testing-híbrido)
8. [Checklist Diario de Referencia Rápida](#8-checklist-diario)

---

## 1. Filosofía: Por Qué Buscar el Balance

### El Problema de Depender 100% de IA

```
❌ Dependencia Total de IA          ✅ Balance Inteligente
──────────────────────              ─────────────────────
• Escribes código sin              • Entiendes el código
  entenderlo                         que escribes
• No reconoces errores              • Detectas errores
  básicos                            rápidamente
• Esperas que IA resuelva          • Usas IA como
  todo                               asistente
• Pierdes habilidades              • Mantienes y mejoras
  de debugging                       habilidades
• Ansiedad cuando IA               • Funcionas sin IA
  falla o no está disponible         cuando es necesario
```

### Por Qué Mantener la Práctica Manual en Backend

| Razón | Impacto a Largo Plazo |
|-------|----------------------|
| **Memoria muscular** | Escribir código forma patrones mentales que IA no puede reemplazar |
| **Depuración efectiva** | Entiendes errores porque conoces la sintaxis y arquitectura |
| **Decisiones arquitectónicas** | Sabes cuándo usar un Service vs直接在 Endpoint |
| **Seguridad** | Entiendes vulnerabilidades potenciales en tu API |
| **Performance** | Conoces las implicaciones de las consultas a BD |
| **Mantenimiento** | Entiendes código legacy sin documentación |

### La Regla del 70/30 en Backend

> **70% IA / 30% Manual** es el balance ideal para proyectos backend reales

```
┌─────────────────────────────────────────────────────────┐
│  Distribución Sugerida del Tiempo en una Feature Backend │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   IA (70%)                   Manual (30%)               │
│   ┌──────────────┐           ┌──────────────┐           │
│   │ • Estructura │           │ • Lógica de  │           │
│   │ • Scaffold   │           │   negocio    │           │
│   │ • Models YAML│           │ • Validaciones│          │
│   │ • Templates  │           │ • Edge cases │           │
│   │ • Tests base │           │ • Debugging  │           │
│   │ • Documentación│         │ • Decisiones │           │
│   │ • CRUD básico│           │   arch.      │           │
│   └──────────────┘           └──────────────┘           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 2. El Framework AIDR Adaptado

> Método de 4 pasos para decidir cuándo usar IA y cuándo escribir manualmente en Backend

### El Acrónimo

```
A I D R
│ │ │ │
│ │ │ └── Review: Revisa y valida lo que generó IA
│ │ └──── Decide: Decide qué va a IA y qué haces tú
│ └────── Investigate: Investiga con IA patrones/soluciones
└──────── Analyze: Analiza tú primero el problema
```

### Paso 1: ANALYZE - Análisis Personal (Siempre Primero)

```markdown
Antes de tocar tu teclado o preguntar a IA:

□ ¿Entiendo completamente el problema de negocio?
□ ¿Cuáles son los requisitos funcionales del endpoint?
□ ¿Hay constraints técnicos (performance, seguridad)?
□ ¿Cómo se integra esto con la base de datos?
□ ¿Qué podría fallar? (edge cases, validaciones)
□ ¿Necesito crear algo nuevo o modificar algo existente?
□ ¿Qué tipo de autenticación se requiere?
```

**Ejemplo de análisis mental:**

```
Feature: "Notificaciones push cuando cambia estado de reserva"

Análisis:
├── Problema: El usuario necesita saber cuando su reserva cambia de estado
├── Entidades involucradas: Booking, Notification, User
├── Flujo: BookingUpdated → NotificationService → Push Notification
├── Edge cases:
│   ├── Usuario sin permisos de notificación
│   ├── Rate limiting de notificaciones
│   └── Fallo en envío (retry logic)
└── Decisión: Esto es lógica de negocio → LO HAGO YO
```

### Paso 2: INVESTIGATE - Investigación con IA

```markdown
Investigar con IA es buscar información, NO ejecutar código:

✅ INVESTIGAR con IA:
├── "Patrones para manejo de fechas en Dart con timezone"
├── "Cómo estructurar validaciones en Serverpod Services"
├── "Best practices para authentication con serverpod_auth"
├── "Estrategias de pagination con PostgreSQL"
└── "Comparación entre validación en Endpoint vs Service"

❌ NO INVESTIGUES (esto es DECIDIR):
├── "Crea un TasksEndpoint completo"
├── "Escribe el TaskService para CRUD"
└── "Genera el código del AuthenticationMiddleware"
```

### Paso 3: DECIDE - Decisión de Responsabilidad

```
┌────────────────────────────────────────────────────────────────────┐
│                    MATRIZ DE DECISIÓN PARA SERVERPOD                │
├─────────────────────┬──────────────────┬───────────────────────────┤
│     TAREA           │    ¿IA O MANUAL? │     POR QUÉ               │
├─────────────────────┼──────────────────┼───────────────────────────┤
│ Estructura endpoint │      🤖 IA       │ Boilerplate puro          │
│ Naming endpoints   │      🤖 IA       │ Sugiere convenciones      │
│ Scaffold service   │      🤖 IA       │ Estructura repetitiva     │
│ CRUD básico        │      🤖 IA       │ Patrón conocido           │
│ DTOs (Input/Output)│      🤖 IA       │ Boilerplate con templates │
│ Exceptions custom   │      🤖 IA       │ Estructura repetitiva     │
│ Models YAML        │      🤖 IA       │ Generación automática     │
│ Tests scaffold     │      🤖 IA       │ Setup repetitivo         │
│ Lógica de negocio  │      ✍️ MANUAL   │ Tu diferenciador         │
│ Validaciones negocio│      ✍️ MANUAL   │ Reglas de tu app         │
│ Edge cases         │      ✍️ MANUAL   │ Conocimiento dominio      │
│ Auth logic         │      ✍️ MANUAL   │ Decisiones seguridad      │
│ Queries complejas   │      ✍️ MANUAL   │ Performance               │
│ Migration SQL      │      ✍️ MANUAL   │ Revisar siempre           │
│ Tests de lógica    │      ✍️ MANUAL   │ Aserciones negocio       │
└─────────────────────┴──────────────────┴───────────────────────────┘
```

### Paso 4: REVIEW - Revisión y Validación

```markdown
Después de recibir código de IA, SIEMPRE haz:

□ ¿Entiendo cada línea de este código?
□ ¿Hay algo que no reconocería si me preguntaran?
□ ¿El código sigue las convenciones del proyecto?
□ ¿Maneja todos los edge cases relevantes?
□ ¿Hay security concerns (SQL injection, auth bypass)?
□ ¿El código es maintainable para otros devs?
□ ¿Las variable/function names son descriptivas?
□ ¿Las queries a BD son eficientes?
□ ¿Los tests cubren el happy path y casos de error?

⚠️ SI RESPONDES "NO" A CUALQUIERA → Reescribe esa sección manualmente
```

---

## 3. Boilerplate vs Lógica Crítica en Backend

### Definición: Boilerplate

> Código repetitivo, predecible, que sigue patrones establecidos.

**Características:**
- Estructura conocida y repetitiva
- No requiere conocimiento del dominio
- Fácil de generar y mantener
- Cambios frecuentes pero predecibles

**Ejemplos por capa:**

| Capa | Ejemplos de Boilerplate |
|------|------------------------|
| **Models** | Estructura YAML, fromJson/toJson básicos |
| **Endpoints** | Scaffold de métodos CRUD, manejo de session |
| **Services** | Estructura base, skeleton de métodos |
| **DTOs** | Input/Output classes con serialización |
| **Exceptions** | Clases de errores repetitivas |
| **Tests** | setUp(), tearDown(), arrange sections |

### Definición: Lógica Crítica

> Código que contiene las reglas de negocio, validaciones, y decisiones que definen cómo funciona tu API.

**Características:**
- Diferencia tu API de otras
- Requiere conocimiento del dominio
- Costoso de cambiar después
- Fuente principal de bugs si se hace mal

**Ejemplos por capa:**

| Capa | Ejemplos de Lógica Crítica |
|------|---------------------------|
| **Domain/Service** | Validaciones complejas, reglas de negocio |
| **Data Access** | Queries complejas, joins, optimizaciones |
| **Auth** | Lógica de permisos, roles, token refresh |
| **Validation** | Reglas específicas del negocio |
| **Edge Cases** | Manejo de condiciones límite |

---

## 4. Estrategias por Capa de Serverpod

### Models (YAML + Generados)

```
┌────────────────────────────────────────────────────────────────┐
│                    MODELS LAYER                                 │
├──────────────────────┬───────────────────┬───────────────────┤
│      Componente       │  Responsabilidad  │    Quién lo hace   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Modelo YAML          │ Definir estructura│ 🤖 IA (scaffold)  │
│                      │ Tipos de datos    │ ✍️ TÚ (decidir)   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Índices              │ Optimización BD   │ 🤖 IA + ✍️ TÚ    │
│                      │ (revisar siempre) │ (consultar)       │
├──────────────────────┼───────────────────┼───────────────────┤
│ Relaciones           │ Estructura BD     │ 🤖 IA + ✍️ TÚ    │
│                      │ (validar negocio) │ (decidir)         │
├──────────────────────┼───────────────────┼───────────────────┤
│ Enums                │ Valores fijos     │ 🤖 IA (scaffold) │
│                      │ Lógica de negocio │ ✍️ TÚ (decidir)   │
└──────────────────────┴───────────────────┴───────────────────┘
```

### Endpoints (Capa de Presentación del Backend)

```
┌────────────────────────────────────────────────────────────────┐
│                    ENDPOINTS LAYER                              │
├──────────────────────┬───────────────────┬───────────────────┤
│      Componente       │  Responsabilidad  │    Quién lo hace   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Estructura base      │ Scaffold          │ 🤖 IA (scaffold) │
│                      │ Tipos de sesión   │ ✍️ TÚ              │
├──────────────────────┼───────────────────┼───────────────────┤
│ CRUD básico          │ Create/Read/      │ 🤖 IA (template)  │
│                      │ Update/Delete     │ ✍️ TÚ (revisar)   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Validación params    │ Tipos y null     │ 🤖 IA (básico)   │
│                      │ Reglas negocio   │ ✍️ TÚ (SIEMPRE)   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Manejo de Auth       │ requireAuth       │ ✍️ TÚ (SIEMPRE)  │
│                      │ Permisos específicos│ ✍️ TÚ (SIEMPRE) │
├──────────────────────┼───────────────────┼───────────────────┤
│ Llamadas a Service   │ Delegación        │ 🤖 IA (estructure)│
│                      │ Lógica negocio   │ ✍️ TÚ              │
├──────────────────────┼───────────────────┼───────────────────┤
│ Manejo de errores    │ Try/catch         │ 🤖 IA (template) │
│                      │ Excepciones custom│ ✍️ TÚ (revisar)   │
└──────────────────────┴───────────────────┴───────────────────┘
```

**🎯 Regla de Oro Endpoints:**
> **Las validaciones de negocio y el manejo de autenticación siempre las haces tú.**

### Services (Capa de Dominio del Backend)

```
┌────────────────────────────────────────────────────────────────┐
│                    SERVICES LAYER                               │
├──────────────────────┬───────────────────┬───────────────────┤
│      Componente       │  Responsabilidad  │    Quién lo hace   │
├──────────────────────┼───────────────────┼───────────────────┤
│ Estructura clase     │ Scaffold          │ 🤖 IA (scaffold) │
├──────────────────────┼───────────────────┼───────────────────┤
│ Validaciones negocio │ Reglas específicas│ ✍️ TÚ (SIEMPRE)  │
│                      │ Lógica de dominio │ ✍️ TÚ (SIEMPRE)  │
├──────────────────────┼───────────────────┼───────────────────┤
│ Queries a BD         │ Acceso a datos    │ 🤖 IA (básico)   │
│                      │ Queries complejas │ ✍️ TÚ (SIEMPRE)  │
├──────────────────────┼───────────────────┼───────────────────┤
│ Transformaciones     │ Lógica de mapping │ ✍️ TÚ              │
├──────────────────────┼───────────────────┼───────────────────┤
│ Excepciones          │ Errores de negocio│ ✍️ TÚ (SIEMPRE)  │
└──────────────────────┴───────────────────┴───────────────────┘
```

**🎯 Regla de Oro Services:**
> **Los Services son tu cerebro. Toda la lógica de negocio va aquí.**

---

## 5. Guía de Prompts Optimizados

### Prompts para Estructura de Proyecto

```markdown
# PROMPT 1: Crear estructura de endpoints y services
---

📝 PROMPT BASE:
"Crea la estructura de carpetas para una feature de [NOMBRE] en 
Serverpod. Incluye:
- lib/src/endpoints/
- lib/src/services/
- lib/src/models/
- lib/src/exceptions/

Genera los comandos bash para crear los directorios."

💡 CUÁNDO USARLO:
→ Al inicio de cada nueva feature
→ Para mantener consistencia en el proyecto

📗 EJEMPLO PRÁCTICO:

"Crea la estructura de carpetas para una feature de RESERVAS en 
Serverpod. Incluye:
- lib/src/endpoints/
- lib/src/services/
- lib/src/models/
- lib/src/exceptions/
- models/reservation/
Genera los comandos bash para crear los directorios."
```

```markdown
# PROMPT 2: Generar Model YAML
---

📝 PROMPT BASE:
"Crea un archivo YAML de modelo Serverpod para [NOMBRE] con los siguientes campos:
- [campo1]: [tipo], [opciones]
- [campo2]: [tipo], [opciones]

Incluye:
- Índices apropiados
- Relaciones si aplica"

📗 EJEMPLO PRÁCTICO:

"Crea un archivo YAML de modelo Serverpod para BOOKING con los siguientes campos:
- id: int (auto)
- clientId: int, relation=parent=User
- serviceId: int, relation=parent=Service
- dateTime: DateTime
- status: BookingStatus (enum)
- createdAt: DateTime
- wasOverbooking: bool

Incluye índices apropiados para queries por clientId y dateTime."
```

### Prompts para Boilerplate de Implementación

```markdown
# PROMPT 3: Boilerplate de Endpoint
---

📝 PROMPT BASE:
"Crea una plantilla de Endpoint de Serverpod para [FEATURE].
Solo genera el scaffold, yo implementaré la lógica."

📗 EJEMPLO PRÁCTICO:

"Crea una plantilla de Endpoint de Serverpod para BOOKING.

```dart
class BookingEndpoint extends Endpoint {
  final BookingService _service;
  
  BookingEndpoint(this._service);
  
  // CRUD methods con TODOs
  Future<List<Booking>> getBookings(Session session) async {
    // TODO: Implementar
  }
  
  Future<Booking> createBooking(Session session, CreateBookingInput input) async {
    // TODO: Implementar
  }
}
```

Genera también las clases de input y output DTOs."
```

```markdown
# PROMPT 4: Boilerplate de Service
---

📝 PROMPT BASE:
"Crea el esqueleto de Service para [FEATURE].
Proporciona implementaciones vacías con TODOs."

📗 EJEMPLO PRÁCTICO:

"Crea el esqueleto de Service para BOOKING.

```dart
class BookingService {
  // TODO: Definir dependencias
  
  Booking createBooking(CreateBookingInput input, int userId) {
    // TODO: Implementar validaciones y lógica de negocio
    throw UnimplementedError();
  }
  
  void cancelBooking(int bookingId) {
    // TODO: Implementar lógica de cancelación
    throw UnimplementedError();
  }
}
```

Proporciona implementaciones vacías con comentarios TODO."
```

### Prompts para Testing

```markdown
# PROMPT 5: Scaffold de tests para Service
---

📝 PROMPT BASE:
"Crea el scaffold de tests para el Service [NOMBRE] usando mocks.
Solo genera la estructura, yo escribiré las aserciones."

📗 EJEMPLO PRÁCTICO:

"Crea el scaffold de tests para BookingService usando mocks.
Solo genera la estructura, yo escribiré las aserciones.

Estructura esperada:
- group para BookingService
- setUp con mocks de repositories
- test para caso de éxito
- test para casos de error (slot no disponible, cliente bloqueado)
- Usa Mock classes generadas con mockito"
```

---

## 6. Caso de Uso Completo: Feature de Reservas Backend

### Descripción del Escenario

```
Feature: API de Reservas Backend
├── Endpoint: /booking (CRUD operations)
├── Service: BookingService (lógica de negocio)
├── Model: Booking (YAML)
├── DTOs: CreateBookingInput, BookingResponse
└── Tests: BookingServiceTest, BookingEndpointTest
```

### Paso 1: ANALYZE - Análisis Personal

```markdown
Antes de pedir código a IA, pienso:

1. ¿Qué necesita la API de reservas?
   - CRUD básico de reservas
   - Validación de disponibilidad (double booking prevention)
   - Manejo de estados de reserva
   - Historial de reservas por cliente

2. ¿Qué dependencias necesito?
   - ClientRepository (verificar cliente)
   - ServiceRepository (verificar servicio)
   - Slot availability check

3. ¿Qué puede fallar?
   - Slot no disponible → SlotNotAvailableException
   - Cliente bloqueado → ClientBlockedException
   - Horario fuera de límites → InvalidScheduleException
   - Servicio no existe → NotFoundException

4. Decisión: Esto tiene lógica crítica
   - Validaciones de negocio las hago YO
   - Double booking prevention lo hago YO
   - El scaffold CRUD puede ir a IA
```

### Paso 2: INVESTIGATE - Investigación con IA

```
Prompt usado:
"¿Cuáles son los mejores prácticas para evitar double booking en 
un sistema de reservas con PostgreSQL y Serverpod? Dame ejemplos de
queries y consideraciones de race conditions."
```

### Paso 3: DECIDE + IMPLEMENT - Ejecución Híbrida

#### 🤖 PARTE 1: Scaffold con IA

```markdown
# Le pido a IA:
"Create the complete structure for a Booking feature in Serverpod:

1. models/booking.yaml con:
   - clientId (relation)
   - serviceId (relation)
   - dateTime
   - status (enum)
   - createdAt
   
2. lib/src/endpoints/booking_endpoint.dart scaffold

3. lib/src/services/booking_service.dart scaffold con TODOs

4. lib/src/models/create_booking_input.dart

5. lib/src/exceptions/booking_exceptions.dart

Just create the scaffold with TODOs where logic should be."
```

#### ✍️ PARTE 2: Lógica Crítica (ESCRIBO YO)

```dart
// booking_service.dart - VERSIÓN FINAL (escrito por mí)
class BookingService {
  final ClientRepository _clientRepository;
  final BookingRepository _bookingRepository;
  
  BookingService({
    required ClientRepository clientRepository,
    required BookingRepository bookingRepository,
  })  : _clientRepository = clientRepository,
        _bookingRepository = bookingRepository;

  Booking createBooking(CreateBookingInput input, int userId) {
    // ============================================================
    // LOGICA CRITICA: Validaciones de negocio
    // ============================================================

    // 1. Verificar cliente existe y no está bloqueado
    final client = _clientRepository.findById(input.clientId);
    if (client == null) {
      throw NotFoundException('Cliente no encontrado');
    }
    
    if (client.status == ClientStatus.blocked) {
      throw ClientBlockedException();
    }

    // 2. Verificar servicio existe
    final service = _serviceRepository.findById(input.serviceId);
    if (service == null) {
      throw NotFoundException('Servicio no encontrado');
    }

    // 3. Verificar disponibilidad del slot
    final existingBookings = _bookingRepository.findByDateRange(
      date: input.dateTime,
      duration: service.durationMinutes,
    );
    
    if (_hasOverlap(existingBookings, input.dateTime, service)) {
      throw SlotNotAvailableException();
    }

    // 4. Crear la reserva
    return Booking(
      clientId: input.clientId,
      serviceId: input.serviceId,
      dateTime: input.dateTime,
      status: BookingStatus.confirmed,
      createdAt: DateTime.now(),
      wasOverbooking: _shouldOverbook(existingBookings),
    );
  }

  // ============================================================
  // Métodos privados de lógica crítica
  // ============================================================

  bool _hasOverlap(List<Booking> existing, DateTime newTime, Service service) {
    final newStart = newTime;
    final newEnd = newTime.add(Duration(minutes: service.durationMinutes + service.bufferMinutes));
    
    for (final booking in existing) {
      if (booking.status == BookingStatus.cancelled) continue;
      
      final existingService = _serviceRepository.findById(booking.serviceId);
      final existingEnd = booking.dateTime.add(
        Duration(minutes: existingService.durationMinutes + existingService.bufferMinutes),
      );
      
      // Check overlap
      if (newStart.isBefore(existingEnd) && newEnd.isAfter(booking.dateTime)) {
        return true;
      }
    }
    return false;
  }
  
  bool _shouldOverbook(List<Booking> existing) {
    // Lógica de overbooking estratégico
    return existing.length >= 4; // Más de 4 reservas = 10% overbooking
  }
}
```

---

## 7. Testing Híbrido Backend

### Estrategia de Testing

```
┌────────────────────────────────────────────────────────────────┐
│                    TESTING EN SERVERPOD                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  🤖 IA GENERA:                                                  │
│     • Scaffold de tests                                         │
│     • Mocks y fakes                                             │
│     • Estructura de arrange                                     │
│                                                                  │
│  ✍️ YO ESCRIBO:                                                 │
│     • Test data realistas                                       │
│     • Aserciones de lógica de negocio                           │
│     • Edge cases específicos                                    │
│     • Assertions de validación                                  │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Ejemplo: Tests para BookingService

```dart
// test/src/services/booking_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../booking_service.dart';
import '../booking_repository.dart';
import '../exceptions/booking_exceptions.dart';

@GenerateMocks([BookingRepository, ClientRepository, ServiceRepository])
import 'booking_service_test.mocks.dart';

void main() {
  late BookingService service;
  late MockBookingRepository mockBookingRepo;
  late MockClientRepository mockClientRepo;
  late MockServiceRepository mockServiceRepo;

  setUp(() {
    mockBookingRepo = MockBookingRepository();
    mockClientRepo = MockClientRepository();
    mockServiceRepo = MockServiceRepository();
    
    service = BookingService(
      bookingRepository: mockBookingRepo,
      clientRepository: mockClientRepo,
      serviceRepository: mockServiceRepo,
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // ✍️ TEST DATA: Creados por mí con datos realistas
  // ═══════════════════════════════════════════════════════════════

  final testClient = Client(
    id: 1,
    name: 'Test User',
    email: 'test@example.com',
    status: ClientStatus.active,
  );

  final blockedClient = Client(
    id: 2,
    name: 'Blocked User',
    email: 'blocked@example.com',
    status: ClientStatus.blocked,
  );

  final testService = Service(
    id: 1,
    name: 'Corte de pelo',
    durationMinutes: 45,
    bufferMinutes: 15,
  );

  final testBookingTime = DateTime.now().add(const Duration(days: 2));

  // ═══════════════════════════════════════════════════════════════
  // ✍️ TESTS: Lógica de negocio
  // ═══════════════════════════════════════════════════════════════

  group('BookingService - createBooking', () {
    test('should create booking when all validations pass', () async {
      // arrange
      when(mockClientRepo.findById(1)).thenReturn(testClient);
      when(mockServiceRepo.findById(1)).thenReturn(testService);
      when(mockBookingRepo.findByDateRange(any, any)).thenReturn([]);
      when(mockBookingRepo.insert(any)).thenAnswer((b) async => 1);

      final input = CreateBookingInput(
        clientId: 1,
        serviceId: 1,
        dateTime: testBookingTime,
      );

      // act
      final result = await service.createBooking(input, 1);

      // assert - ✍️ MI ASERCIÓN
      expect(result.clientId, 1);
      expect(result.serviceId, 1);
      expect(result.status, BookingStatus.confirmed);
      expect(result.wasOverbooking, false);
    });

    test('should throw ClientBlockedException when client is blocked', () async {
      // arrange
      when(mockClientRepo.findById(2)).thenReturn(blockedClient);

      final input = CreateBookingInput(
        clientId: 2,
        serviceId: 1,
        dateTime: testBookingTime,
      );

      // act & assert - ✍️ MI ASERCIÓN
      expect(
        () => service.createBooking(input, 2),
        throwsA(isA<ClientBlockedException>()),
      );
    });

    test('should throw SlotNotAvailableException when slot is taken', () async {
      // arrange
      final existingBooking = Booking(
        id: 99,
        clientId: 3,
        serviceId: 1,
        dateTime: testBookingTime,
        status: BookingStatus.confirmed,
        createdAt: DateTime.now(),
      );

      when(mockClientRepo.findById(1)).thenReturn(testClient);
      when(mockServiceRepo.findById(1)).thenReturn(testService);
      when(mockBookingRepo.findByDateRange(any, any))
          .thenReturn([existingBooking]);

      final input = CreateBookingInput(
        clientId: 1,
        serviceId: 1,
        dateTime: testBookingTime,
      );

      // act & assert - ✍️ MI ASERCIÓN
      expect(
        () => service.createBooking(input, 1),
        throwsA(isA<SlotNotAvailableException>()),
      );
    });
  });
}
```

---

## 8. Checklist Diario de Referencia Rápida

```
┌─────────────────────────────────────────────────────────────────┐
│                 CHECKLIST DIARIO DE REFERENCIA                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📋 ANTES DE PEDIR CÓDIGO A IA:                                │
│     □ ¿Analicé el problema primero?                            │
│     □ ¿Identifiqué la lógica crítica?                          │
│     □ ¿Investigué patrones con IA?                             │
│                                                                 │
│  🤖 IA PUEDE GENERAR:                                           │
│     □ Estructura de carpetas                                     │
│     □ Scaffold de Endpoints                                     │
│     □ Template de Services con TODOs                           │
│     □ Model YAML básico                                         │
│     □ DTOs Input/Output                                         │
│     □ Clases de excepciones                                     │
│     □ Scaffold de tests                                         │
│                                                                 │
│  ✍️ YO SIEMPRE ESCRIBO:                                         │
│     □ Validaciones de negocio en Services                       │
│     □ Lógica de autenticación/autorización                      │
│     □ Queries complejas a BD                                     │
│     □ Edge cases y manejo de errores específicos               │
│     □ Aserciones en tests                                       │
│     □ Constants de negocio                                      │
│                                                                 │
│  ✅ DESPUÉS DE RECIBIR CÓDIGO:                                  │
│     □ ¿Entiendo cada línea?                                     │
│     □ ¿Hay security concerns?                                    │
│     □ ¿Maneja todos los edge cases?                             │
│     □ ¿Las queries son eficientes?                              │
│                                                                 │
│  🧪 TESTS:                                                      │
│     □ Happy path                                                 │
│     □ Casos de error                                             │
│     □ Edge cases                                                 │
│     □ Assertions de lógica de negocio                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Resumen de Prompts Clave

```
┌─────────────────────────────────────────────────────────────────┐
│                 CHEAT SHEET DE PROMPTS SERVERPOD               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  📁 ESTRUCTURA                                                  │
│     Prompt 1: Estructura de carpetas                           │
│     Prompt 2: Model YAML                                        │
│                                                                 │
│  🏗️ IMPLEMENTACIÓN                                             │
│     Prompt 3: Endpoint scaffold                                 │
│     Prompt 4: Service scaffold                                  │
│                                                                 │
│  🧪 TESTING                                                     │
│     Prompt 5: Test scaffold para Service                        │
│                                                                 │
│  🔍 DEBUGGING                                                   │
│     Prompt 6: Analizar error                                   │
│     Prompt 7: Analizar código y sugerir mejoras                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Próximos Pasos

1. Revisa los prompts en `🤖 PRÁCTICA - Prompts Optimizados para Serverpod.md`
2. Aplica el framework AIDR en tu próxima feature
3. Usa el checklist para validar tu trabajo
4. Mantén el balance 70/30 IA/Manual

---

*Este documento está basado en la guía original de Flutter y adaptado específicamente para desarrollo backend con Serverpod.*
