# Módulo 4: Backend con Serverpod (El Cerebro)

## 3. Lógica de Endpoints

### Objetivos de Aprendizaje

- Implementar endpoints en Serverpod
- Usar el objeto Session para acceder a DB, caché y logs
- Realizar operaciones CRUD
- Validar datos y manejar errores

---

## 3.1 Estructura de un Endpoint

### Concepto

Un endpoint es una función expuesta via RPC que el cliente (Flutter) puede llamar. Cada endpoint contiene la lógica de negocio de tu aplicación.

```dart
// packages/server/lib/src/endpoints/usuario_endpoint.dart

class UsuarioEndpoint extends Endpoint {
  // El endpoint se registra automáticamente
  // Disponible como: client.usuarioEndpoint.metodo()
}
```

### Anatomía de un Endpoint

```dart
class ExampleEndpoint extends Endpoint {
  @override
  Future<TipoRetorno> nombreMetodo(Session session, [Parametros]) async {
    // 1. Obtener datos de la request
    // 2. Validar
    // 3. Procesar (lógica de negocio)
    // 4. Consultar DB si es necesario
    // 5. Retornar resultado
  }
}
```

---

## 3.2 El Objeto Session

### ¿Qué es Session?

Session es el contexto de cada request. Proporciona acceso a:
- Base de datos
- Cache (Redis)
- Autenticación
- Logs

```dart
// Acceder a diferentes servicios desde Session

// Base de datos
final usuarios = await Usuario.db.find(session);

// Cache
await session.cache.set('key', 'value');
final cached = await session.cache.get('key');

// Autenticación
final userId = session.authentication.userId;
final isAdmin = session.hasRole('admin');

// Logging
session.log('Mensaje de info', level: LogLevel.info);
session.logError('Algo falló', exception: e);

// Configuración
final apiKey = session.config['API_KEY'];
```

### Propiedades de Session

```dart
// Propiedades principales
session.id                    // ID único de la request
session.authentication.userId // ID del usuario autenticado
session.callContext           // Información de la llamada
session.method                // Nombre del endpoint

// Base de datos
session.db                    // Acceso directo a la DB (row)

session.log(String message, {LogLevel level = LogLevel.info})
```

---

## 3.3 Operaciones CRUD

### Create (Crear)

```dart
class UsuarioEndpoint extends Endpoint {
  Future<Usuario> crearUsuario(
    Session session, 
    CreateUsuario data
  ) async {
    // Validar que el email no exista
    final existente = await Usuario.db.findFirst(
      session,
      where: (t) => t.email.equals(data.email),
    );
    
    if (existente != null) {
      throw Exception('El email ya está registrado');
    }
    
    // Crear el usuario
    final usuario = data.toInsertable();
    return await usuario.insert(session);
  }
}

// Clase para crear (sin id, timestamps)
class CreateUsuario {
  final String nombre;
  final String email;
  final String passwordHash;
  
  // Constructor
  CreateUsuario({
    required this.nombre,
    required this.email,
    required this.passwordHash,
  });
  
  // Convertir a modelo insertable
  Usuario toInsertable() {
    return Usuario(
      nombre: nombre,
      email: email,
      passwordHash: passwordHash,
      createdAt: DateTime.now(),
    );
  }
}
```

### Read (Leer)

```dart
class UsuarioEndpoint extends Endpoint {
  // Obtener uno por ID
  Future<Usuario?> getUsuario(Session session, int id) async {
    return await Usuario.db.findById(session, id);
  }
  
  // Obtener todos
  Future<List<Usuario>> getTodosUsuarios(Session session) async {
    return await Usuario.db.find(session);
  }
  
  // Buscar con filtros
  Future<List<Usuario>> buscarUsuarios(
    Session session, 
    String? busqueda,
    int? limite,
    int? offset,
  ) async {
    return await Usuario.db.find(
      session,
      where: (t) {
        Expression<bool>? condition;
        
        if (busqueda != null && busqueda.isNotEmpty) {
          condition = t.nombre.like('%$busqueda%') | 
                      t.email.like('%$busqueda%');
        }
        
        return condition;
      },
      limit: limite ?? 20,
      offset: offset ?? 0,
    );
  }
  
  // Contar registros
  Future<int> contarUsuarios(Session session) async {
    return await Usuario.db.count(session);
  }
}
```

### Update (Actualizar)

```dart
class UsuarioEndpoint extends Endpoint {
  Future<Usuario> actualizarUsuario(
    Session session, 
    int id,
    UpdateUsuario data
  ) async {
    // Obtener usuario actual
    final usuario = await Usuario.db.findById(session, id);
    
    if (usuario == null) {
      throw Exception('Usuario no encontrado');
    }
    
    // Actualizar campos
    if (data.nombre != null) {
      usuario.nombre = data.nombre;
    }
    if (data.avatarUrl != null) {
      usuario.avatarUrl = data.avatarUrl;
    }
    if (data.estaActivo != null) {
      usuario.estaActivo = data.estaActivo;
    }
    
    return await usuario.update(session);
  }
}

class UpdateUsuario {
  final String? nombre;
  final String? avatarUrl;
  final bool? estaActivo;
}
```

### Delete (Eliminar)

```dart
class UsuarioEndpoint extends Endpoint {
  Future<bool> eliminarUsuario(Session session, int id) async {
    // Verificar que existe
    final usuario = await Usuario.db.findById(session, id);
    
    if (usuario == null) {
      return false;
    }
    
    // Eliminar (hard delete)
    await Usuario.db.delete(session, id);
    
    return true;
  }
  
  // Soft delete (recomendado)
  Future<Usuario> desactivarUsuario(Session session, int id) async {
    final usuario = await Usuario.db.findById(session, id);
    
    if (usuario == null) {
      throw Exception('Usuario no encontrado');
    }
    
    usuario.estaActivo = false;
    return await usuario.update(session);
  }
}
```

---

## 3.4 Queries Avanzadas

### Where con Condiciones

```dart
// Encontrar usuarios activos
await Usuario.db.find(
  session,
  where: (t) => t.estaActivo.equals(true),
);

// Encontrar por rango de fechas
await Pedido.db.find(
  session,
  where: (t) => t.createdAt.isBiggerThan(fechaInicio) & 
                t.createdAt.isSmallerThan(fechaFin),
);

// Múltiples condiciones
await Usuario.db.find(
  session,
  where: (t) => 
    (t.rol.equals(UserRole.admin)) & 
    (t.estaActivo.equals(true)),
);
```

### Ordenar Resultados

```dart
// Ordenar por campo
await Usuario.db.find(
  session,
  orderBy: [OrderingItem(field: 'createdAt', order: OrderingOption.desc)],
);

// Múltiples campos
await Pedido.db.find(
  session,
  orderBy: [
    OrderingItem(field: 'estado'),
    OrderingItem(field: 'createdAt', order: OrderingOption.desc),
  ],
);
```

### Joins y Relaciones

```dart
// Obtener usuario con sus pedidos (si está configurada la relación)
// El modelo debe tener definida la relación

final usuario = await Usuario.db.findById(session, 1);

// Acceder a pedidos relacionados
final pedidos = usuario.pedidos;

// O con query específica
await Pedido.db.find(
  session,
  where: (t) => t.usuarioId.equals(usuario.id),
);
```

### Paginación

```dart
class PaginationResult<T> {
  final List<T> items;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;
}

Future<PaginationResult<Usuario>> listarUsuarios(
  Session session, 
  int page, 
  int perPage
) async {
  final offset = (page - 1) * perPage;
  
  final usuarios = await Usuario.db.find(
    session,
    limit: perPage,
    offset: offset,
  );
  
  final total = await Usuario.db.count(session);
  
  return PaginationResult(
    items: usuarios,
    total: total,
    page: page,
    perPage: perPage,
    totalPages: (total / perPage).ceil(),
  );
}
```

---

## 3.5 Transacciones

```dart
// Ejecutar operaciones atómicas
await session.db.transaction((tx) async {
  // 1. Crear pedido
  final pedido = Pedido(
    usuarioId: usuarioId,
    total: total,
    createdAt: DateTime.now(),
  );
  await pedido.insert(tx);
  
  // 2. Para cada item, actualizar stock
  for (final item in items) {
    await tx.execute(
      'UPDATE productos SET stock = stock - ? WHERE id = ?',
      [item.cantidad, item.productoId],
    );
  }
  
  // Si algo falla, se hace rollback automáticamente
});
```

---

## 3.6 Validaciones y Errores

### Validaciones de Entrada

```dart
class UsuarioEndpoint extends Endpoint {
  Future<Usuario> crearUsuario(
    Session session, 
    CreateUsuario data
  ) async {
    // Validar email
    if (data.email == null || data.email!.isEmpty) {
      throw ValidationException('El email es obligatorio');
    }
    
    if (!_esEmailValido(data.email!)) {
      throw ValidationException('El email no es válido');
    }
    
    // Validar nombre
    if (data.nombre == null || data.nombre!.length < 2) {
      throw ValidationException('El nombre debe tener al menos 2 caracteres');
    }
    
    // Validar password
    if (data.passwordHash == null || data.passwordHash!.length < 8) {
      throw ValidationException('La contraseña debe tener al menos 8 caracteres');
    }
    
    // Continuar con la lógica...
  }
  
  bool _esEmailValido(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}
```

### Manejo de Errores

```dart
class UsuarioEndpoint extends Endpoint {
  Future<Usuario> crearUsuario(
    Session session, 
    CreateUsuario data
  ) async {
    try {
      // Lógica principal
      return await data.insert(session);
    } on DatabaseException catch (e) {
      // Error de base de datos
      session.logError('Error DB', exception: e);
      throw Exception('Error al crear usuario');
    } catch (e) {
      // Error genérico
      session.logError('Error inesperado: $e');
      throw Exception('Ha ocurrido un error inesperado');
    }
  }
}
```

---

## 3.7 Logging

```dart
class UsuarioEndpoint extends Endpoint {
  Future<List<Usuario>> buscarUsuarios(
    Session session, 
    String busqueda
  ) async {
    // Log de entrada
    session.log(
      'Buscando usuarios con: $busqueda',
      level: LogLevel.debug,
    );
    
    try {
      final resultados = await Usuario.db.find(
        session,
        where: (t) => t.nombre.like('%$busqueda%'),
      );
      
      // Log de éxito
      session.log(
        'Encontrados ${resultados.length} usuarios',
        level: LogLevel.debug,
      );
      
      return resultados;
    } catch (e) {
      // Log de error
      session.logError(
        'Error buscando usuarios: $e',
        exception: e,
      );
      rethrow;
    }
  }
}
```

---

## 3.8 Ejercicios Prácticos

### Ejercicio 1: Endpoint de Tareas

```dart
// packages/server/lib/src/endpoints/tarea_endpoint.dart

class TareaEndpoint extends Endpoint {
  // CREATE
  Future<Tarea> crearTarea(Session session, CreateTarea data) async {
    return await data.toInsertable().insert(session);
  }
  
  // READ - uno
  Future<Tarea?> getTarea(Session session, int id) async {
    return await Tarea.db.findById(session, id);
  }
  
  // READ - todos
  Future<List<Tarea>> getTareas(Session session) async {
    return await Tarea.db.find(session);
  }
  
  // READ - por usuario
  Future<List<Tarea>> getTareasUsuario(
    Session session, 
    int usuarioId
  ) async {
    return await Tarea.db.find(
      session,
      where: (t) => t.usuarioId.equals(usuarioId),
    );
  }
  
  // UPDATE
  Future<Tarea> actualizarTarea(
    Session session, 
    int id, 
    UpdateTarea data
  ) async {
    final tarea = await Tarea.db.findById(session, id);
    if (tarea == null) throw Exception('Tarea no encontrada');
    
    if (data.titulo != null) tarea.titulo = data.titulo;
    if (data.completada != null) tarea.completada = data.completada;
    
    return await tarea.update(session);
  }
  
  // DELETE
  Future<bool> eliminarTarea(Session session, int id) async {
    final tarea = await Tarea.db.findById(session, id);
    if (tarea == null) return false;
    
    await Tarea.db.delete(session, id);
    return true;
  }
}
```

### Ejercicio 2: Paginación

```dart
// Agregar endpoint con paginación
Future<Map<String, dynamic>> getTareasPaginadas(
  Session session, 
  int page, 
  int perPage
) async {
  final offset = (page - 1) * perPage;
  
  final tareas = await Tarea.db.find(
    session,
    orderBy: [OrderingItem(field: 'createdAt', order: OrderingOption.desc)],
    limit: perPage,
    offset: offset,
  );
  
  final total = await Tarea.db.count(session);
  
  return {
    'items': tareas,
    'page': page,
    'perPage': perPage,
    'total': total,
    'totalPages': (total / perPage).ceil(),
  };
}
```

### Ejercicio 3: Testing

```dart
// Probar endpoint manualmente
// Usando curl o desde Flutter:

// GET /api/tareas
// POST /api/tareas (body: {titulo: "Nueva tarea"})
// PUT /api/tareas/1 (body: {completada: true})
// DELETE /api/tareas/1
```

---

## 3.9 Ejemplo Completo: API REST-like con Serverpod

```dart
// Endpoint completo con todas las operaciones CRUD

class ProductoEndpoint extends Endpoint {
  
  // GET /productos
  Future<List<Producto>> getProductos(Session session) async {
    return await Producto.db.find(
      session,
      where: (t) => t.estaActivo.equals(true),
    );
  }
  
  // GET /productos/:id
  Future<Producto?> getProducto(Session session, int id) async {
    return await Producto.db.findById(session, id);
  }
  
  // GET /productos/search?q=...
  Future<List<Producto>> buscarProductos(
    Session session, 
    String query
  ) async {
    return await Producto.db.find(
      session,
      where: (t) => 
        (t.nombre.like('%$query%')) & 
        (t.estaActivo.equals(true)),
      limit: 20,
    );
  }
  
  // POST /productos
  Future<Producto> crearProducto(
    Session session, 
    CreateProducto data
  ) async {
    // Validar
    if (data.precio < 0) {
      throw ValidationException('El precio no puede ser negativo');
    }
    
    return await data.toInsertable().insert(session);
  }
  
  // PUT /productos/:id
  Future<Producto> actualizarProducto(
    Session session, 
    int id, 
    UpdateProducto data
  ) async {
    final producto = await Producto.db.findById(session, id);
    if (producto == null) {
      throw Exception('Producto no encontrado');
    }
    
    if (data.nombre != null) producto.nombre = data.nombre;
    if (data.precio != null) producto.precio = data.precio;
    if (data.stock != null) producto.stock = data.stock;
    
    return await producto.update(session);
  }
  
  // DELETE /productos/:id
  Future<bool> eliminarProducto(Session session, int id) async {
    final producto = await Producto.db.findById(session, id);
    if (producto == null) return false;
    
    await Producto.db.delete(session, id);
    return true;
  }
  
  // GET /productos/categoria/:categoriaId
  Future<List<Producto>> getProductosCategoria(
    Session session, 
    int categoriaId
  ) async {
    return await Producto.db.find(
      session,
      where: (t) => 
        (t.categoriaId.equals(categoriaId)) & 
        (t.estaActivo.equals(true)),
    );
  }
}
```

---

## 3.10 Recursos Adicionales

### Métodos Disponibles en Modelos

```dart
// Todos los modelos generados tienen:
Model.db.find(session)              // Obtener todos
Model.db.findById(session, id)      // Por ID
Model.db.findFirst(session, where) // Primero que cumpla
Model.db.count(session)             // Contar
Model.db.insert(session)            // Crear
Model.update(session)               // Actualizar
Model.delete(session)               // Eliminar
```

### Expresiones de Query

```dart
// Condiciones disponibles
t.campo.equals(valor)
t.campo.notEquals(valor)
t.campo.like('%valor%')
t.campo.isBiggerThan(valor)
t.campo.isSmallerThan(valor)
t.campo.isIn([valores])
t.campo.isNull()
t.campo.isNotNull()

// Combinaciones
(cond1) & (cond2)  // AND
(cond1) | (cond2)  // OR
```

---

## Resumen

En esta guía has aprendido:

- ✅ Estructurar endpoints en Serverpod
- ✅ Usar el objeto Session para DB, cache y logs
- ✅ Implementar operaciones CRUD
- ✅ Queries avanzadas con filtros y ordenamiento
- ✅ Validaciones y manejo de errores
- ✅ Logging

**Siguiente guía:** Gestión de Sesiones y Auth - Autenticación y autorización.