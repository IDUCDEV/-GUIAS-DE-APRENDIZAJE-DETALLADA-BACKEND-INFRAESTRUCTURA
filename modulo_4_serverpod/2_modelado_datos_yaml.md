# Módulo 4: Backend con Serverpod (El Cerebro)

## 2. Modelado de Datos (YAML)

### Objetivos de Aprendizaje

- Crear modelos de datos en YAML
- Definir tipos de campos y validaciones
- Configurar relaciones entre modelos
- Generar tablas de PostgreSQL automáticamente

---

## 2.1 Fundamentos del Modelado

### ¿Por qué YAML?

En Serverpod, los modelos se definen en archivos YAML. Esto permite:
- Definición declarativa de la estructura de datos
- Generación automática de código Dart
- Creación automática de tablas en PostgreSQL
- Tipos compartidos entre cliente y servidor

### Estructura de un Archivo de Modelo

```yaml
# packages/server/lib/src/models/usuario.yaml

class: Usuario
type: database
table: usuarios

fields:
  nombre: String
  email: String
  edad: int?
  activo: bool
  fecha_registro: DateTime
  rol: UserRole

relations:
  pedidos:
    handle: has_many
```

---

## 2.2 Tipos de Datos

### Tipos Primitivos

```yaml
# Tipos básicos disponibles
fields:
  # Strings
  nombre: String              # VARCHAR (por defecto)
  bio: String(1000)           # Con longitud máxima
  email: String              # INDEX automático
  
  # Números
  edad: int                  # INTEGER
  precio: double             # DOUBLE PRECISION
  saldo: int                 # BIGINT para dinero (usar int + dividir)
  
  # Boolean
  activo: bool               # BOOLEAN
  
  # Fechas
  fecha_nacimiento: DateTime # TIMESTAMP
  fecha_creacion: DateTime  # Created automatically
  fecha_actualizacion: DateTime # Updated automatically
  
  # Enum
  rol: UserRole              # Enum personalizado
```

### Tipos Especiales

```yaml
fields:
  # Serial (auto-increment)
  id: int                    # Serial, primary key, not null
  
  # UUID
  uuid: Guid                 # UUID único universal
  
  # Binary
  imagen: Blob               # BYTEA
  
  # JSON
  metadata: Json            # JSONB
  
  # List/Array
  tags: List<String>        # TEXT[] (array de strings)
  
  # Foreign Key
  categoria_id: int          # Relación a otra tabla
```

### Tabla de Tipos YAML → PostgreSQL

| YAML | Dart | PostgreSQL |
|------|------|------------|
| `String` | `String` | VARCHAR(512) |
| `String(1000)` | `String` | VARCHAR(1000) |
| `int` | `int` | INTEGER |
| `double` | `double` | DOUBLE PRECISION |
| `bool` | `bool` | BOOLEAN |
| `DateTime` | `DateTime` | TIMESTAMP |
| `Blob` | `List<int>` | BYTEA |
| `Json` | `Map<String, dynamic>` | JSONB |
| `Guid` | `Uuid` | UUID |
| `List<String>` | `List<String>` | TEXT[] |

---

## 2.3 Ejemplo: Modelo de Usuario

### Archivo: usuario.yaml

```yaml
# packages/server/lib/src/models/usuario.yaml

class: Usuario
type: database
table: usuarios

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  
  email:
    type: String
    size: 255
    unique: true
    notNull: true
  
  passwordHash:
    type: String
    size: 255
    notNull: true
  
  nombre:
    type: String
    size: 100
    notNull: true
  
  avatarUrl:
    type: String?
    size: 500
  
  biografia:
    type: String?
    size: 1000
  
  fechaNacimiento:
    type: DateTime?
  
  rol:
    type: UserRole
    default: user
  
  estaActivo:
    type: bool
    default: true
  
  ultimoAcceso:
    type: DateTime?
  
  createdAt:
    type: DateTime
    autoInsert: true
  
  updatedAt:
    type: DateTime
    autoInsert: true
    autoUpdate: true

indexes:
  email_unique:
    type: unique
    fields: [email]
  
  created_at_index:
    type: btree
    fields: [createdAt]
```

---

## 2.4 Enums

### Definir un Enum

```yaml
# packages/server/lib/src/models/user_role.yaml

enum: UserRole
values:
  - user
  - admin
  - moderator
  - premium

# Genera enum en Dart:
enum UserRole { user, admin, moderator, premium }
```

### Usar Enum en Modelo

```yaml
# packages/server/lib/src/models/usuario.yaml

fields:
  rol:
    type: UserRole
    default: user
```

### Ejemplo de Uso en Código

```dart
// En endpoint
final usuarios = await Usuario.db.findByRole(
  session, 
  role: UserRole.admin,
);

// Filtrar por enum
final admins = await Usuario.db.find(
  session,
  where: (t) => t.rol.equals(UserRole.admin),
);
```

---

## 2.5 Relaciones entre Modelos

### Tipos de Relaciones

```
┌─────────────────────────────────────────────────────────────┐
│                 RELACIONES EN SERVERPOD                    │
│                                                             │
│  One-to-One:                                                │
│  usuario <──► perfil                                         │
│  (Un usuario tiene un perfil)                              │
│                                                             │
│  One-to-Many:                                               │
│  categoria <──► productos                                   │
│  (Una categoría tiene muchos productos)                    │
│                                                             │
│  Many-to-Many:                                              │
│  usuario <──► cursos                                        │
│  (Un usuario puede estar en muchos cursos)                │
│  (Un curso puede tener muchos usuarios)                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### One-to-Many (has_many)

```yaml
# Modelo: Categoria
# packages/server/lib/src/models/categoria.yaml

class: Categoria
type: database
table: categorias

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  
  nombre:
    type: String
    size: 100
    notNull: true
  
  descripcion:
    type: String?
  
  estaActiva:
    type: bool
    default: true

relations:
  productos:
    handle: has_many
    foreignKey: categoriaId

---

# Modelo: Producto
# packages/server/lib/src/models/producto.yaml

class: Producto
type: database
table: productos

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  
  nombre:
    type: String
    size: 200
    notNull: true
  
  precio:
    type: int  # En centavos
    notNull: true
  
  categoriaId:
    type: int
    relation: has_many(categoria)

relations:
  categoria:
    handle: belongs_to
```

### One-to-One

```yaml
# Modelo: Usuario
class: Usuario
type: database
fields:
  # ...

relations:
  perfil:
    handle: has_one

---

# Modelo: Perfil
class: Perfil
type: database
fields:
  usuarioId:
    type: int
    relation: has_one

  biografia:
    type: String?

  sitioWeb:
    type: String?

relations:
  usuario:
    handle: has_one
```

### Many-to-Many (many_many)

```yaml
# Modelo: Estudiante
class: Estudiante
type: database
fields:
  nombre:
    type: String
    notNull: true
  
  email:
    type: String
    unique: true

relations:
  cursos:
    handle: many_many
    table: inscripciones
    via: estudianteId

---

# Modelo: Curso
class: Curso
type: database
fields:
  titulo:
    type: String
    notNull: true
  
  descripcion:
    type: String?

relations:
  estudiantes:
    handle: many_many
    table: inscripciones
    via: cursoId
```

---

## 2.6 Validaciones

### Validaciones en YAML

```yaml
# packages/server/lib/src/models/producto.yaml

class: Producto
type: database
table: productos

fields:
  nombre:
    type: String
    size: 200
    notNull: true  # Obligatorio
  
  precio:
    type: int
    notNull: true
  
  stock:
    type: int
    default: 0
  
  sku:
    type: String
    size: 50
    unique: true
  
  estaActivo:
    type: bool
    default: true

validations:
  nombre_min_length:
    field: nombre
    type: minLength
    minLength: 3
  
  nombre_max_length:
    field: nombre
    type: maxLength
    maxLength: 200
  
  precio_positivo:
    field: precio
    type: min
    min: 0
```

### Validaciones Personalizadas en Código

```dart
// En el endpoint, antes de guardar
class ProductoEndpoint extends Endpoint {
  Future<Producto> crearProducto(
    Session session, 
    CreateProducto data
  ) async {
    // Validación personalizada
    if (data.nombre.length < 3) {
      throw ValidationException(
        'El nombre debe tener al menos 3 caracteres'
      );
    }
    
    if (data.precio < 0) {
      throw ValidationException(
        'El precio no puede ser negativo'
      );
    }
    
    // Validar SKU único
    final existente = await Producto.db.findFirst(
      session,
      where: (t) => t.sku.equals(data.sku),
    );
    
    if (existente != null) {
      throw ValidationException('El SKU ya existe');
    }
    
    return await data.insert(session);
  }
}
```

---

## 2.7 Generación de Código

### Ejecutar Generación

```bash
cd packages/server

# Generar código (después de crear/editar modelos)
dart run serverpod generate

# Output esperado:
# ✓ Found 5 model files
# ✓ Generated database model: Usuario
# ✓ Generated database model: Producto
# ✓ Generated database model: Categoria
# ✓ Generated database model: Pedido
# ✓ Generated client library
```

### Archivos Generados

```bash
# Estructura después de generate:
lib/src/
├── models/
│   ├── usuario.dart          # Modelo generado
│   ├── usuario.yaml          # Tu definición
│   ├── producto.dart
│   └── ...
├── endpoints/
│   └── ...
└── generated/
    ├── database/
    │   ├── database.dart      # Métodos de DB
    │   └── table_maps.dart    # Mapeos de tablas
    └── client/
        ├── client.dart        # Cliente RPC
        └── method_lookup.dart # Métodos disponibles
```

---

## 2.8 Ejercicios Prácticos

### Ejercicio 1: Crear Modelo Básico

```yaml
# packages/server/lib/src/models/tarea.yaml

class: Tarea
type: database
table: tareas

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  
  titulo:
    type: String
    size: 255
    notNull: true
  
  descripcion:
    type: String?
  
  completada:
    type: bool
    default: false
  
  fechaVencimiento:
    type: DateTime?
  
  prioridad:
    type: PrioridadTarea
    default: media
  
  createdAt:
    type: DateTime
    autoInsert: true

# Enum
enum: PrioridadTarea
values:
  - baja
  - media
  - alta
```

```bash
# Generar
dart run serverpod generate

# Ver resultado
cat lib/src/models/tarea.dart
```

### Ejercicio 2: Agregar Relaciones

```yaml
# Agregar a Usuario
relations:
  tareas:
    handle: has_many
    foreignKey: usuarioId

# Agregar a Tarea
fields:
  usuarioId:
    type: int
    relation: has_many(usuario)

relations:
  usuario:
    handle: belongs_to
```

### Ejercicio 3: Verificar Base de Datos

```bash
# Después de generate y restart
docker compose exec postgres psql -U postgres -d serverpod

# Ver tablas
\dt

# Ver estructura de tabla
\d tareas
```

---

## 2.9 Modelo Completo: E-commerce

```yaml
# Ejemplo: Modelos para tienda online

---

# usuario.yaml
class: Usuario
type: database
table: usuarios

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  email:
    type: String
    unique: true
    size: 255
  nombre:
    type: String
    size: 150
  passwordHash:
    type: String
    size: 255
  rol:
    type: UserRole
    default: cliente
  createdAt:
    type: DateTime
    autoInsert: true

relations:
  pedidos:
    handle: has_many
  direccion:
    handle: has_one

---

# pedido.yaml
class: Pedido
type: database
table: pedidos

fields:
  id:
    type: int
    autoIncrement: true
    parentId: true
  usuarioId:
    type: int
    relation: has_many(usuario)
  estado:
    type: EstadoPedido
    default: pendiente
  total:
    type: int  # En centavos
  createdAt:
    type: DateTime
    autoInsert: true

relations:
  usuario:
    handle: belongs_to
  items:
    handle: has_many

enum: EstadoPedido
values:
  - pendiente
  - confirmado
  - procesando
  - enviado
  - entregado
  - cancelado
```

---

## 2.10 Recursos Adicionales

### Comandos de Referencia

```bash
# Regenerar modelos
dart run serverpod generate

# Ver modelos generados
ls lib/src/models/

# Ver código de un modelo
cat lib/src/models/usuario.dart
```

### Tipos de Índices

```yaml
indexes:
  mi_indice:
    type: btree        # B-tree (default)
    fields: [email]
  
  unique_index:
    type: unique
    fields: [email]
  
  composite:
    type: btree
    fields: [estado, createdAt]
```

---

## Resumen

En esta guía has aprendido:

- ✅ Definir modelos en YAML
- ✅ Tipos de datos y validaciones
- ✅ Configurar relaciones (has_many, belongs_to, many_many)
- ✅ Enums personalizados
- ✅ Ejecutar generación de código
- ✅ Verificar tablas en PostgreSQL

**Siguiente guía:** Lógica de Endpoints - Implementar la lógica de tu API.