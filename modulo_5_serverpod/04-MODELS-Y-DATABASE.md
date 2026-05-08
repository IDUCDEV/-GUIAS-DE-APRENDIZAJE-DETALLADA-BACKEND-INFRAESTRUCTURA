# Models y Base de Datos en Serverpod

> Aprende cómo Serverpod maneja los modelos de datos, el ORM y las migraciones de base de datos.

---

## Tabla de Contenidos

1. [Introducción a los Modelos](#1-introducción-a-los-modelos)
2. [Definición de Modelos en YAML](#2-definición-de-modelos-en-yaml)
3. [Tipos de Datos](#3-tipos-de-datos)
4. [Relaciones entre Modelos](#4-relaciones-entre-modelos)
5. [Índices y Constraints](#5-índices-y-constraints)
6. [Migraciones de Base de Datos](#6-migraciones-de-base-de-datos)
7. [Serialización Automática](#7-serialización-automática)
8. [Ejemplo Práctico Completo](#8-ejemplo-práctico-completo)

---

## 1. Introducción a los Modelos

### ¿Qué es un Modelo en Serverpod?

En Serverpod, un **modelo** es la definición de una entidad que se almacenará en PostgreSQL. A diferencia de Flutter donde defines clases Dart manualmente, en Serverpod defines modelos en archivos **YAML** y el código se genera automáticamente.

```
    FLUTTER (Mobile)                      SERVERPOD (Backend)
    ══════════════════                    ════════════════════
    
    Entity (puro Dart)                  Model (YAML → Dart)
    ─────────────────                    ────────────────────
    class User {                         task.yaml:
      final int id;      ──────────→     class: Task
      final String name;                  table: tasks
    }                                    fields:
                                          title: String
                                          isCompleted: bool
    
    Model (con serialización)            Model Generado
    ─────────────────────                ─────────────────
    class UserModel extends User {        class Task extends TableRow {
      factory UserModel.fromJson() {        int id;
      }                                    String title;
      Map toJson() {}                      bool isCompleted;
    }                                      ...
                                         }
```

### Beneficios del Sistema de Modelos de Serverpod

| Beneficio | Descripción |
|-----------|-------------|
| **Type-safety** | El código generado es 100% Dart tipado |
| **DRY** | Define una vez, genera en todas partes |
| **Migraciones automáticas** | Serverpod gestiona los cambios de esquema |
| **ORM integrado** | Acceso a datos sin escribir SQL manual |
| **Serialización automática** | Conversión JSON ↔ objetos automática |

---

## 2. Definición de Modelos en YAML

### Estructura Básica de un Archivo YAML

```yaml
# models/task.yaml

class: Task                    # Nombre de la clase Dart
table: tasks                  # Nombre de la tabla en PostgreSQL (plural)

fields:                       # Campos de la tabla
  title: String(100)          # String con longitud máxima de 100
  description: String?        # ? significa nullable
  isCompleted: bool           # Booleano
  createdAt: DateTime         # Fecha y hora
  priority: int, defaultValue=0  # Con valor por defecto
```

### Archivos Generados

Cuando ejecutas `serverpod generate`, se generan múltiples archivos:

```
    models/
    ├── task.yaml                           ← Tú lo escribes
    │
    └── generated/
        ├── protocol.dart                   ← AUTO-GENERADO
        │   ├── class Task extends TableRow
        │   ├── Métodos de acceso a BD
        │   └── Tipos serializables
        │
        └── protocol copy.dart              ← Backup (no editar)
```

---

## 3. Tipos de Datos

### Tipos Primitivos Soportados

| Tipo YAML | Tipo Dart | Descripción | Ejemplo |
|-----------|-----------|-------------|---------|
| `String` | `String` | Texto | `'Hola mundo'` |
| `int` | `int` | Enteros | `42`, `-10` |
| `double` | `double` | Decimales | `3.14` |
| `bool` | `bool` | true/false | `true` |
| `DateTime` | `DateTime` | Fecha y hora | `2024-01-15T10:30:00` |
| `Uuid` | `Uuid` | Identificador único | `550e8400-e29b-...` |
| `Duration` | `Duration` | Duración | `Duration(hours: 2)` |

### String con Restricciones

```yaml
# Longitud máxima
title: String(100)

# String largo (TEXT en vez de VARCHAR)
content: String, long

# String de solo texto (sin emojis)
name: String, onlyText
```

### Campos Opcionales (Nullable)

```yaml
# Nullable (puede ser null)
description: String?

# Nullable con valor por defecto cuando es null
nickname: String?, defaultValue=null
```

### Valores por Defecto

```yaml
# Valor por defecto booleano
isActive: bool, defaultValue=true

# Valor por defecto numérico
priority: int, defaultValue=0

# Valor por defecto de fecha
createdAt: DateTime, defaultValue=now

# Valor por defecto de string
status: String, defaultValue='pending'
```

### Ejemplos Completos

```yaml
# models/user.yaml
class: User
table: users
fields:
  # Campos requeridos
  email: String(100), unique
  passwordHash: String
  name: String(50)
  
  # Campos opcionales
  avatarUrl: String?
  bio: String?
  
  # Campos con valores por defecto
  isVerified: bool, defaultValue=false
  role: String, defaultValue='user'
  
  # Timestamps
  createdAt: DateTime, defaultValue=now
  updatedAt: DateTime
```

```yaml
# models/product.yaml
class: Product
table: products
fields:
  name: String(100)
  description: String, long  # TEXT en vez de VARCHAR
  price: double
  stock: int, defaultValue=0
  sku: String(50), unique
  isAvailable: bool, defaultValue=true
  createdAt: DateTime, defaultValue=now
```

---

## 4. Relaciones entre Modelos

### Tipos de Relaciones

Serverpod soporta tres tipos de relaciones:

| Relación | Descripción | Ejemplo |
|----------|-------------|---------|
| **Parent** | Uno a muchos (inversa) | many Tasks → one User |
| **Child** | Uno a muchos (directa) | User → many Tasks |
| **Many-to-Many** | Muchos a muchos | Posts ↔ Tags |

### Relación Uno a Muchos (Parent-Child)

```
    ┌─────────────────┐         ┌─────────────────┐
    │      User       │         │      Task       │
    ├─────────────────┤         ├─────────────────┤
    │ id (PK)         │ 1    *  │ id (PK)         │
    │ name            │─────────│ userId (FK)     │
    │ email           │         │ title           │
    └─────────────────┘         │ isCompleted     │
                                └─────────────────┘
    
    Un User tiene muchas Tasks
    Una Task pertenece a un User
```

**Definición YAML:**

```yaml
# models/user.yaml
class: User
table: users
fields:
  email: String(100), unique
  name: String(50)
  tasks: List<Task>, relation=children  # Relación inversa
```

```yaml
# models/task.yaml
class: Task
table: tasks
fields:
  title: String(100)
  userId: int, relation=parent=User     # Foreign Key
```

### Acceso a Relaciones en Código

```dart
// Crear tarea para un usuario
final user = await User.findById(session, userId);
final task = Task(
  title: 'Nueva tarea',
  userId: userId,  // Se guarda la FK automáticamente
);
await task.insert(session);

// Obtener tareas de un usuario
final tasks = await Task.findAll(
  session,
  where: (t) => t.userId.equals(userId),
);

// Acceder al padre desde el hijo
final task = await Task.findById(session, taskId);
final user = await task.user.load(session);  // Carga el usuario

// Acceder a los hijos desde el padre
final user = await User.findById(session, userId);
final tasks = await user.tasks.load(session);  // Carga las tareas
```

### Relación Muchos a Muchos

```
    ┌─────────────────┐         ┌─────────────────────┐         ┌─────────────────┐
    │     Post        │         │   PostTag (tabla     │         │      Tag        │
    ├─────────────────┤         │    pivote)          │         ├─────────────────┤
    │ id (PK)         │ 1     * ├─────────────────────┤    * 1 │ id (PK)         │
    │ title           │─────────│ postId (FK)         │─────────│ name            │
    │ content         │         │ tagId (FK)         │         │ color           │
    └─────────────────┘         └─────────────────────┘         └─────────────────┘
```

**Definición YAML:**

```yaml
# models/post.yaml
class: Post
table: posts
fields:
  title: String(100)
  content: String, long
  tags: List<Tag>, relation=manyToMany
```

```yaml
# models/tag.yaml
class: Tag
table: tags
fields:
  name: String(30), unique
  color: String(7)  # Hex color
```

```yaml
# models/post_tag.yaml (tabla pivote - se genera automáticamente)
# Serverpod genera esto automáticamente con manyToMany
```

---

## 5. Índices y Constraints

### Índices para Búsquedas Rápidas

```yaml
# models/task.yaml
class: Task
table: tasks
indexes:
  task_user_id_idx:           # Nombre del índice
    fields: userId            # Campo(s) a indexar
    type: btree               # Tipo de índice
  
  task_status_created_idx:    # Índice compuesto
    fields: isCompleted, createdAt
    type: btree
```

### Índices Únicos

```yaml
# Para campos únicos, simplemente usa unique
class: User
table: users
fields:
  email: String(100), unique  # Crea índice único automáticamente
  username: String(30), unique
```

### Constraints Personalizados

```yaml
# models/order.yaml
class: Order
table: orders
fields:
  status: String(20), defaultValue='pending'
  totalAmount: double
  paidAmount: double
```

```dart
// En el Service, valida constraints de negocio
class OrderService {
  void validateOrder(Order order) {
    if (order.paidAmount > order.totalAmount) {
      throw ValidationException('El monto pagado no puede ser mayor al total');
    }
  }
}
```

---

## 6. Migraciones de Base de Datos

### ¿Qué son las Migraciones en Serverpod v3?

Las migraciones son el mecanismo para evolucionar el esquema de tu base de datos (tablas, columnas, índices) de forma segura y versionada. En Serverpod v3, el sistema es **declarativo**: tú defines el modelo en YAML y Serverpod calcula qué cambios son necesarios en la base de datos.

```
    FLUJO DE MIGRACIÓN V3
    ══════════════════════
    
    1. Cambias un .yaml en /models
    2. Ejecutas 'serverpod create-migration'
    3. Serverpod compara el estado actual vs el nuevo
    4. Genera archivos de definición y scripts SQL
    5. Aplicas los cambios con 'serverpod run'
```

### Comandos Principales

| Comando | Propósito |
|---------|-----------|
| `serverpod create-migration` | Genera una nueva migración basada en cambios de modelos |
| `serverpod create-migration --force` | Fuerza la creación incluso si hay advertencias |
| `serverpod run --role maintenance` | Aplica migraciones pendientes y sale |
| `serverpod run` | Aplica migraciones y arranca el servidor |

### Estructura de una Migración

Cuando creas una migración, se genera una carpeta en `migrations/{PROYECTO}/`:

```
    migrations/my_project/
    └── 20240320120000_add_task_priority/
        ├── definition.yaml      ← Estado completo de la DB tras la migración
        ├── migration.yaml       ← Cambios específicos realizados
        └── migration.sql        ← El script SQL real que se ejecutará
```

### Ejemplo: Añadir un Campo

Si añades `priority: int` a `Task`, la migración generará un SQL similar a:

```sql
-- database/migrations/20240320120000_add_task_priority/migration.sql

ALTER TABLE "tasks" ADD COLUMN "priority" integer DEFAULT 0 NOT NULL;
```

### Resolución de Conflictos (Breaking Changes)

Si realizas un cambio que podría causar pérdida de datos (ej. borrar una columna o cambiar un tipo de dato), Serverpod te avisará:

```bash
# Serverpod detecta un cambio peligroso:
$ serverpod create-migration
> Warning: Migration involves deleting a column 'description' from table 'tasks'.
> Use --force to proceed.
```

### Buenas Prácticas de Producción

1. **Nunca edites los archivos SQL/YAML manuales** a menos que seas un experto en PostgreSQL.
2. **Revisa siempre el `migration.sql`** antes de aplicarlo en un entorno real.
3. **Commit de migraciones**: Los archivos generados en la carpeta `migrations/` **DEBEN** subirse al control de versiones (Git) junto con tus cambios de código.
4. **Entornos compartidos**: Cuando trabajas en equipo, si alguien sube una migración, tú debes ejecutar `serverpod run` para sincronizar tu base de datos local.

---

## 7. Serialización Automática (Protocol)

### Cómo Funciona

Serverpod genera automáticamente código para convertir entre:

```
    Dart Object  ←→  JSON  ←→  PostgreSQL Row
```

### Clases Generadas

```dart
// En models/generated/protocol.dart (AUTO-GENERADO)

class Task extends TableRow {
  int id;
  String title;
  String? description;
  bool isCompleted;
  DateTime createdAt;
  int userId;
  
  // Constructor
  Task({
    this.id = 0,  // 0 = no persisted
    required this.title,
    this.description,
    this.isCompleted = false,
    DateTime? createdAt,
    required this.userId,
  }) : createdAt = createdAt ?? DateTime.now();
  
  // Serialización para comunicación cliente-servidor
  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      isCompleted: json['isCompleted'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as int,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'userId': userId,
    };
  }
}
```

### Tipos Especiales de Serialización

#### DateTime

```yaml
# El DateTime se serializa como ISO8601 string
fields:
  createdAt: DateTime, defaultValue=now
```

```dart
// Se convierte automáticamente
final json = task.toJson();
// {'createdAt': '2024-01-15T10:30:00.000Z'}

// Y viceversa
final task = Task.fromJson(json);
```

#### Enum

```yaml
# models/enums/priority.yaml
enum: Priority
values:
  - low
  - medium
  - high
  - urgent
```

```dart
// Se genera automáticamente
enum Priority {
  low,
  medium,
  high,
  urgent;
  
  String toJson() => name;
  
  static Priority fromJson(String json) {
    return Priority.values.firstWhere((e) => e.name == json);
  }
}
```

#### List

```yaml
# models/user.yaml
class: User
table: users
fields:
  name: String
  roles: List<String>  # Lista de strings
```

```dart
// Las listas se serializan como arrays JSON
final user = User(
  name: 'John',
  roles: ['admin', 'editor'],
);

final json = user.toJson();
// {'name': 'John', 'roles': ['admin', 'editor']}
```

---

## 8. Ejemplo Práctico Completo

### Sistema de Blog Completo

#### Estructura de Modelos

```
    models/
    ├── user.yaml
    ├── post.yaml
    ├── comment.yaml
    ├── enums/
    │   └── post_status.yaml
    └── generated/
        └── protocol.dart
```

#### Modelo User

```yaml
# models/user.yaml

class: User
table: users
fields:
  email: String(100), unique
  username: String(30), unique
  passwordHash: String
  displayName: String(50)
  bio: String?, long
  avatarUrl: String?
  isVerified: bool, defaultValue=false
  role: String, defaultValue='user'
  createdAt: DateTime, defaultValue=now
  updatedAt: DateTime

indexes:
  user_email_idx:
    fields: email
    type: btree
  
  user_username_idx:
    fields: username
    type: btree
```

#### Enum de Status

```yaml
# models/enums/post_status.yaml

enum: PostStatus
values:
  - draft
  - published
  - archived
  - deleted
```

#### Modelo Post

```yaml
# models/post.yaml

class: Post
table: posts
fields:
  authorId: int, relation=parent=User
  title: String(200)
  slug: String(250), unique
  content: String, long
  excerpt: String?, long
  coverImageUrl: String?
  status: PostStatus, defaultValue=draft
  publishedAt: DateTime?
  viewCount: int, defaultValue=0
  createdAt: DateTime, defaultValue=now
  updatedAt: DateTime
  comments: List<Comment>, relation=children
  author: User, relation=parent=User

indexes:
  post_author_idx:
    fields: authorId
    type: btree
  
  post_status_published_idx:
    fields: status, publishedAt
    type: btree
  
  post_slug_idx:
    fields: slug
    type: btree, unique
```

#### Modelo Comment

```yaml
# models/comment.yaml

class: Comment
table: comments
fields:
  postId: int, relation=parent=Post
  authorId: int, relation=parent=User
  parentId: int?                       # Para comentarios anidados
  content: String, long
  isApproved: bool, defaultValue=true
  createdAt: DateTime, defaultValue=now

indexes:
  comment_post_idx:
    fields: postId
    type: btree
  
  comment_author_idx:
    fields: authorId
    type: btree
  
  comment_parent_idx:
    fields: parentId
    type: btree
```

### Uso de los Modelos en el Endpoint

```dart
// lib/src/endpoints/post_endpoint.dart

class PostsEndpoint extends Endpoint {
  final PostService _postService;
  
  PostsEndpoint(this._postService);
  
  @override
  bool get requireAuth => false;  // Lectura pública
  
  Future<List<Post>> getPublishedPosts(Session session, {int limit = 20, int offset = 0}) async {
    final posts = await Post.findAll(
      session,
      where: (p) => p.status.equals(PostStatus.published.name),
      orderBy: [Order(Desc(Post().publishedAt))],
      limit: limit,
      offset: offset,
    );
    
    return posts;
  }
  
  @override
  bool get requireAuth => true;  // Requiere autenticación
  
  Future<Post> createPost(Session session, CreatePostInput input) async {
    final userId = session.auth.authenticatedUser!.id;
    
    // Validar con el servicio
    final post = _postService.createPost(input, userId);
    
    // Guardar en base de datos
    await post.insert(session);
    
    return post;
  }
  
  Future<List<Post>> getUserPosts(Session session) async {
    final userId = session.auth.authenticatedUser!.id;
    
    return await Post.findAll(
      session,
      where: (p) => p.authorId.equals(userId),
      orderBy: [Order(Desc(Post().createdAt))],
    );
  }
}
```

### Uso en Flutter

```dart
// lib/features/posts/data/datasources/post_remote_datasource.dart

class PostRemoteDataSource {
  final Client client;
  
  PostRemoteDataSource(this.client);
  
  Future<List<Post>> getPublishedPosts({int page = 0}) async {
    const pageSize = 20;
    return await client.postsEndpoint.getPublishedPosts(
      limit: pageSize,
      offset: page * pageSize,
    );
  }
  
  Future<Post> createPost({
    required String title,
    required String content,
    String? excerpt,
  }) async {
    final input = CreatePostInput(
      title: title,
      content: content,
      excerpt: excerpt,
    );
    
    return await client.postsEndpoint.createPost(input);
  }
}
```

---

## 📝 Resumen

Después de leer este documento, deberías saber:

- ✅ Cómo definir modelos en archivos YAML
- ✅ Todos los tipos de datos soportados por Serverpod
- ✅ Cómo crear relaciones entre modelos (uno a muchos, muchos a muchos)
- ✅ Cómo funcionan los índices y constraints
- ✅ El sistema de migraciones de Serverpod
- ✅ Cómo funciona la serialización automática
- ✅ Un ejemplo completo de sistema de blog

---

## 🎯 Próximo Paso

Continúa con [05-ENDPOINTS-Y-SERVICIOS.md](./05-ENDPOINTS-Y-SERVICIOS.md) para aprender a crear endpoints, autenticación y servicios.
