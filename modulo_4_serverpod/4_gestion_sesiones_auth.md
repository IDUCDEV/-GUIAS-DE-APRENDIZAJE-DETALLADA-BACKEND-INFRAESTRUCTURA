# Módulo 4: Backend con Serverpod (El Cerebro)

## 4. Gestión de Sesiones y Auth

### Objetivos de Aprendizaje

- Configurar autenticación en Serverpod
- Implementar login/registro de usuarios
- Usar authorization scopes para controlar acceso
- Proteger endpoints sensibles

---

## 4.1 Sistema de Autenticación

### Concepto

Serverpod tiene un sistema de autenticación integrado que maneja:
- Registro de usuarios
- Login/logout
- Sesiones con tokens
- Refresh de tokens
- Roles y permisos

### Configuración Inicial

```yaml
# config/generator.yaml

type: serverpod
authenticationKey: tu_clave_secreta

# Habilitar autenticación
auth:
  enabled: true
  user:
    # Modelo de usuario para auth
    table: usuarios
    # Campos del modelo
    emailField: email
    passwordHashField: passwordHash
    # Campo para validar que el usuario está activo
    activeField: estaActivo

# Sesiones
session:
  # Duración de la sesión en segundos (24 horas)
  duration: 86400
  # Cookie name
  cookieName: sp_session

# Scopes (roles/permisos)
scopes:
  - name: admin
    description: Administrador del sistema
  - name: user
    description: Usuario estándar
  - name: premium
    description: Usuario premium
```

---

## 4.2 Registro de Usuarios

### Implementar Endpoint de Registro

```dart
// packages/server/lib/src/endpoints/auth_endpoint.dart

class AuthEndpoint extends Endpoint {
  Future<AuthResult> registerUser(
    Session session, 
    String email, 
    String password
  ) async {
    // Validar que el email no exista
    final existente = await Usuario.db.findFirst(
      session,
      where: (t) => t.email.equals(email),
    );
    
    if (existente != null) {
      throw Exception('El email ya está registrado');
    }
    
    // Validar password (mínimo 8 caracteres)
    if (password.length < 8) {
      throw Exception('La contraseña debe tener al menos 8 caracteres');
    }
    
    // Hash de la contraseña
    final passwordHash = _hashPassword(password);
    
    // Crear usuario
    final usuario = Usuario(
      email: email,
      passwordHash: passwordHash,
      nombre: email.split('@').first,
      rol: UserRole.user,
      estaActivo: true,
      createdAt: DateTime.now(),
    );
    
    await usuario.insert(session);
    
    // Iniciar sesión automáticamente
    return await _createSession(session, usuario);
  }
  
  String _hashPassword(String password) {
    // Usar bcrypt o argon2 en producción
    // Ejemplo simple (NO usar en producción):
    return sha256.convert(utf8.encode(password)).toString();
  }
  
  Future<AuthResult> _createSession(Session session, Usuario usuario) async {
    // Generar token de sesión
    final token = await session.auth.createSession(
      userId: usuario.id,
    );
    
    return AuthResult(
      userId: usuario.id,
      token: token,
      expiresAt: DateTime.now().add(Duration(hours: 24)),
    );
  }
}
```

---

## 4.3 Login

### Implementar Endpoint de Login

```dart
class AuthEndpoint extends Endpoint {
  Future<AuthResult> loginUser(
    Session session, 
    String email, 
    String password
  ) async {
    // Buscar usuario por email
    final usuario = await Usuario.db.findFirst(
      session,
      where: (t) => t.email.equals(email),
    );
    
    if (usuario == null) {
      throw Exception('Credenciales incorrectas');
    }
    
    // Verificar que está activo
    if (!usuario.estaActivo) {
      throw Exception('La cuenta está desactivada');
    }
    
    // Verificar contraseña
    final passwordHash = _hashPassword(password);
    if (usuario.passwordHash != passwordHash) {
      throw Exception('Credenciales incorrectas');
    }
    
    // Actualizar último acceso
    usuario.ultimoAcceso = DateTime.now();
    await usuario.update(session);
    
    // Crear sesión
    return await _createSession(session, usuario);
  }
}
```

### Logout

```dart
class AuthEndpoint extends Endpoint {
  Future<void> logoutUser(Session session) async {
    // Invalidar la sesión actual
    await session.auth.invalidateSession();
  }
}
```

---

## 4.4 Proteger Endpoints

### Sin Anotación (público)

```dart
// Este endpoint es accesible sin autenticación
class PublicEndpoint extends Endpoint {
  Future<String> getPublicData(Session session) async {
    return 'Datos públicos';
  }
}
```

### Con Anotación @protected

```dart
// Este endpoint requiere autenticación
class ProtectedEndpoint extends Endpoint {
  @protected
  Future<List<Usuario>> getPrivateData(Session session) async {
    // Solo usuarios autenticados pueden acceder
    return await Usuario.db.find(session);
  }
}
```

### Con Roles Específicos

```dart
class AdminEndpoint extends Endpoint {
  @Role(roles: [UserRole.admin])
  Future<void> adminOnlyAction(Session session) async {
    // Solo admins pueden ejecutar esto
  }
}

class PremiumEndpoint extends Endpoint {
  @Role(roles: [UserRole.premium, UserRole.admin])
  Future<List<Producto>> getPremiumProducts(Session session) async {
    // Solo premium o admin
    return await Producto.db.find(session);
  }
}
```

### Proteger con Scopes

```yaml
# config/generator.yaml - Agregar scopes
scopes:
  - name: admin
    description: Acceso total
  - name: user
    description: Usuario básico
  - name: premium
    description: Funciones premium
```

```dart
class PremiumEndpoint extends Endpoint {
  @Scope(['premium', 'admin'])
  Future<List<Producto>> getPremiumContent(Session session) async {
    return await Producto.db.find(
      session,
      where: (t) => t.esPremium.equals(true),
    );
  }
}
```

---

## 4.5 Obtener Usuario Autenticado

### Desde Session

```dart
class UsuarioEndpoint extends Endpoint {
  // Obtener el usuario actual (el que hizo la request)
  Future<Usuario?> getCurrentUser(Session session) async {
    final userId = session.authentication.userId;
    if (userId == null) return null;
    
    return await Usuario.db.findById(session, userId);
  }
  
  // Actualizar perfil del usuario actual
  Future<Usuario> updateCurrentUser(
    Session session, 
    UpdateUsuario data
  ) async {
    final userId = session.authentication.userId;
    if (userId == null) {
      throw Exception('No autenticado');
    }
    
    final usuario = await Usuario.db.findById(session, userId);
    if (usuario == null) {
      throw Exception('Usuario no encontrado');
    }
    
    // Actualizar campos
    if (data.nombre != null) usuario.nombre = data.nombre;
    if (data.avatarUrl != null) usuario.avatarUrl = data.avatarUrl;
    
    return await usuario.update(session);
  }
}
```

---

## 4.6 Middleware de Autenticación

### Verificar Acceso en Cada Request

```dart
// packages/server/lib/src/middleware/auth_middleware.dart

class AuthMiddleware extends Middleware {
  @override
  Future<MiddlewareResponse> handle(
    Session session,
    MiddlewareCall call,
  ) async {
    // Verificar si el endpoint requiere autenticación
    final endpoint = call.endpoint;
    final requiresAuth = _requiresAuthentication(endpoint);
    
    if (requiresAuth) {
      // Verificar que hay sesión activa
      final userId = session.authentication.userId;
      
      if (userId == null) {
        return MiddlewareResponse(
          statusCode: 401,
          body: {'error': 'No autenticado'},
        );
      }
      
      // Agregar información del usuario a la sesión
      session.set('currentUserId', userId);
    }
    
    // Continuar con el request
    return await call.next();
  }
  
  bool _requiresAuthentication(Object endpoint) {
    // Aquí verificas las anotaciones del endpoint
    // Ejemplo simplificado:
    final method = endpoint.toString();
    return !method.contains('public');
  }
}
```

---

## 4.7 Tokens y Refresh

### Configuración de Tokens

```yaml
# config/generator.yaml

auth:
  enabled: true
  tokens:
    # Duración del access token (1 hora)
    accessTokenDuration: 3600
    # Duración del refresh token (30 días)
    refreshTokenDuration: 2592000
    # Longitud del token
    tokenLength: 32
```

### Implementar Refresh

```dart
class AuthEndpoint extends Endpoint {
  Future<AuthResult> refreshToken(
    Session session, 
    String refreshToken
  ) async {
    try {
      // Validar refresh token
      final userId = await session.auth.validateRefreshToken(refreshToken);
      
      if (userId == null) {
        throw Exception('Token inválido');
      }
      
      // Obtener usuario
      final usuario = await Usuario.db.findById(session, userId);
      if (usuario == null || !usuario.estaActivo) {
        throw Exception('Usuario no válido');
      }
      
      // Generar nuevo access token
      return await _createSession(session, usuario);
    } catch (e) {
      throw Exception('Error al refresh token: $e');
    }
  }
}
```

---

## 4.8 Ejemplo: Flujo Completo de Auth

### Desde Flutter

```dart
// Registro
final result = await client.auth.register(
  email: 'usuario@example.com',
  password: 'password123',
);

// Guardar token (secure storage)
await secureStorage.write(key: 'token', value: result.token);

// Login
final loginResult = await client.auth.login(
  email: 'usuario@example.com',
  password: 'password123',
);

// Ya可以进行 authenticated requests
final user = await client.usuario.getCurrentUser();

// Logout
await client.auth.logout();
```

### Desde Serverpod

```dart
// packages/server/lib/src/endpoints/auth_endpoint.dart

class AuthEndpoint extends Endpoint {
  // Registrar
  Future<AuthResult> register(
    Session session, 
    String email, 
    String password
  ) async { ... }
  
  // Login
  Future<AuthResult> login(
    Session session, 
    String email, 
    String password
  ) async { ... }
  
  // Logout
  Future<void> logout(Session session) async {
    await session.auth.invalidateSession();
  }
  
  // Obtener usuario actual
  Future<Usuario?> getCurrentUser(Session session) async {
    final userId = session.authentication.userId;
    if (userId == null) return null;
    return await Usuario.db.findById(session, userId);
  }
  
  // Verificar si está autenticado
  Future<bool> isAuthenticated(Session session) async {
    return session.authentication.userId != null;
  }
}
```

---

## 4.9 Seguridad de Contraseñas

### Hash de Contraseñas

```dart
// NO USAR: sha256 directamente (inseguro)
// USAR: bcrypt, argon2, o scrypt

import 'package:crypto/crypto.dart';
import 'dart:convert';

// Helper para hash (NO para producción real)
// En producción usar: package:bcrypt o package:argon2

String hashPassword(String password) {
  // Añadir salt
  final salt = 'tu_salt_unico_para_app';
  final bytes = utf8.encode(password + salt);
  
  // Hash múltiples veces (no es bcrypt, pero es mejor que nada)
  var hash = sha256.convert(bytes);
  for (int i = 0; i < 10000; i++) {
    hash = sha256.convert(hash.bytes);
  }
  
  return hash.toString();
}

bool verifyPassword(String password, String storedHash) {
  final inputHash = hashPassword(password);
  return inputHash == storedHash;
}
```

### Recomendaciones de Seguridad

```
✅ Buenas prácticas:
- Usar bcrypt o argon2
- No almacenar passwords en texto claro
- Implementar rate limiting en login
- Registrar intentos de login fallidos
- Forzar cambio de password periódicamente
- Validar complejidad de password

❌ Evitar:
-sha256 sin salt
- Contraseñas en texto en DB
- No validar fuerza de password
- Sin límite de intentos de login
```

---

## 4.10 Ejercicios Prácticos

### Ejercicio 1: Configurar Auth

```yaml
# config/generator.yaml
auth:
  enabled: true
  user:
    table: usuarios
    emailField: email
    passwordHashField: passwordHash
    activeField: estaActivo
```

### Ejercicio 2: Endpoints de Auth

```dart
// Crear auth_endpoint.dart con:
// - register(email, password)
// - login(email, password)
// - logout()
// - getCurrentUser()
```

### Ejercicio 3: Proteger un Endpoint

```dart
class PedidoEndpoint extends Endpoint {
  // Público - cualquier persona puede ver productos
  Future<List<Producto>> getProductos(Session session) async { ... }
  
  // Protegido - solo usuarios autenticados
  @protected
  Future<List<Pedido>> getMisPedidos(Session session) async { ... }
  
  // Solo admins
  @Role(roles: [UserRole.admin])
  Future<List<Pedido>> getTodosPedidos(Session session) async { ... }
}
```

---

## 4.11 Recursos Adicionales

### Paquetes Recomendados

```yaml
# pubspec.yaml
dependencies:
  # Hash de contraseñas
  crypto: ^3.0.3
  pointycastle: ^3.7.3
  
  # Para producción:
  # bcrypt: ^5.1.0
  # argon2: ^0.1.0
```

### Roles y Permisos

```yaml
# Enum de roles
enum: UserRole
values:
  - user      # Básico
  - moderator # Moderador
  - admin     # Administrador
  - superadmin # Superadmin
```

---

## Resumen

En esta guía has aprendido:

- ✅ Configurar autenticación en Serverpod
- ✅ Implementar registro y login
- ✅ Proteger endpoints con @protected
- ✅ Usar roles con @Role
- ✅ Scopes de autorización
- ✅ Manejo de tokens y sesiones
- ✅ Seguridad de contraseñas

**Fin del Módulo 4** - Ahora tienes un backend completo con Serverpod.

**Siguiente:** Módulo 5: Supabase + Odoo - Infraestrutura Pro.