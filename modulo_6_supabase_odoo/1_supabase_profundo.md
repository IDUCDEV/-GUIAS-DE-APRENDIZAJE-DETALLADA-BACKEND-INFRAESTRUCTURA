# Módulo 5: Infraestructura Pro (Supabase + Odoo)

## 1. Supabase Profundo

### Objetivos de Aprendizaje

- Dominar PostgreSQL en Supabase
- Usar Storage para gestión de archivos
- Implementar Realtime para actualizaciones en tiempo real
- Integrar con Flutter

---

## 1.1 ¿Qué es Supabase?

### Concepto

Supabase es una alternativa de código abierto a Firebase. Proporciona:
- Base de datos PostgreSQL
- Autenticación
- Storage (archivos)
- Realtime (suscripciones)
- Edge Functions (serverless)
- API automática

### Autoalojar Supabase

```bash
# Opción 1: Docker Compose (recomendado)
# Clonar el repositorio oficial
git clone --depth 1 https://github.com/supabase/supabase-docker.git
cd supabase-docker

# Configurar
cp .env.example .env
# Editar .env con tus valores

# Levantar servicios
docker compose up -d

# Servicios disponibles:
# - PostgreSQL:5432
# - Kong (API Gateway):8000
# - GoTrue (Auth):9999
# - Storage:5000
# - Realtime:4000
```

---

## 1.2 PostgreSQL Profundo

### Conexión a la Base de Datos

```bash
# Conectar directamente
docker exec -it supabase-db-1 psql -U postgres

# Con SSL (desde tu laptop)
psql "postgresql://postgres:password@tu-servidor:5432/postgres"
```

### Conceptos de PostgreSQL

```
┌─────────────────────────────────────────────────────────────┐
│              ARQUITECTURA POSTGRESQL                        │
│                                                             │
│  Cluster (instancia)                                        │
│  └── Database (base de datos)                              │
│      └── Schema (espacio de nombres)                       │
│          └── Tables, Views, Functions, etc.                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Tablas, Esquemas y Schemas

```sql
-- Ver bases de datos
\l

-- Conectar a una base de datos
\c mi_database

-- Ver esquemas
\dn

-- Schema público (default)
SELECT * FROM public.usuarios;

-- Schema específico
SELECT * FROM storage.buckets;
```

### Tipos de Datos Avanzados

```sql
-- JSON y JSONB (documentos)
CREATE TABLE eventos (
  id SERIAL PRIMARY KEY,
  datos JSONB,
  metadata JSON
);

INSERT INTO eventos (datos) VALUES 
  ('{"tipo": "click", "page": "/home"}');

-- Arrays
CREATE TABLE tags (
  id SERIAL PRIMARY KEY,
  nombre TEXT[],
  descripcion TEXT
);

INSERT INTO tags (nombre) VALUES 
  (ARRAY['flutter', 'dart', 'backend']);

-- UUID
CREATE TABLE pedidos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cliente_id UUID REFERENCES clientes(id),
  total DECIMAL(10,2)
);

-- Timestamps con timezone
CREATE TABLE logs (
  id SERIAL,
  evento TIMESTAMPTZ DEFAULT NOW(),
  mensaje TEXT
);
```

### Funciones y Procedures

```sql
-- Función simple
CREATE OR REPLACE FUNCTION get_usuario_count()
RETURNS INTEGER AS $$
  SELECT COUNT(*) FROM usuarios;
$$ LANGUAGE sql;

-- Función con parámetros
CREATE OR REPLACE FUNCTION buscar_usuarios(
  p_busqueda TEXT,
  p_limite INTEGER DEFAULT 10
)
RETURNS SETOF usuarios AS $$
  SELECT * FROM usuarios
  WHERE nombre ILIKE '%' || p_busqueda || '%'
     OR email ILIKE '%' || p_busqueda || '%'
  LIMIT p_limite;
$$ LANGUAGE sql;

-- Trigger para updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER usuarios_updated_at
  BEFORE UPDATE ON usuarios
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### Índices para Rendimiento

```sql
-- Índice B-tree (búsqueda exacta)
CREATE INDEX idx_usuarios_email ON usuarios(email);

-- Índice único
CREATE UNIQUE INDEX idx_usuarios_email_unique ON usuarios(email);

-- Índice compuesto
CREATE INDEX idx_pedidos_fecha_estado 
  ON pedidos(created_at DESC, estado);

-- Índice para búsqueda de texto
CREATE INDEX idx_productos_search 
  ON productos USING gin(to_tsvector('spanish', nombre || ' ' || descripcion));

-- Índice parcial (solo activos)
CREATE INDEX idx_usuarios_activos 
  ON usuarios(email) WHERE esta_activo = true;
```

### Consultas Avanzadas

```sql
-- CTEs (Common Table Expressions)
WITH ventas_mes AS (
  SELECT 
    DATE_TRUNC('month', created_at) as mes,
    SUM(total) as total
  FROM pedidos
  WHERE created_at >= '2024-01-01'
  GROUP BY DATE_TRUNC('month', created_at)
)
SELECT * FROM ventas_mes ORDER BY mes;

-- Window Functions
SELECT 
  id,
  total,
  SUM(total) OVER (ORDER BY created_at) as running_total,
  ROW_NUMBER() OVER (ORDER BY created_at) as orden
FROM pedidos;

-- Pivot/CrossTab
SELECT * FROM crosstab(
  'SELECT mes, categoria, SUM(total) FROM ventas GROUP BY mes, categoria'
) AS ct(mes date, tecnologia bigint, servicios bigint);

-- Recursive CTE (jerarquías)
WITH RECURSIVE categoria_tree AS (
  SELECT id, nombre, parent_id, 1 as nivel
  FROM categorias WHERE parent_id IS NULL
  UNION ALL
  SELECT c.id, c.nombre, c.parent_id, ct.nivel + 1
  FROM categorias c
  JOIN categoria_tree ct ON c.parent_id = ct.id
)
SELECT * FROM categoria_tree;
```

---

## 1.3 Storage (Gestión de Archivos)

### Buckets

```sql
-- Crear bucket público
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Crear bucket privado
INSERT INTO storage.buckets (id, name, public)
VALUES ('documentos', 'documentos', false);
```

### Políticas de Acceso

```sql
-- Policy: Cualquier usuario puede ver imágenes públicas
CREATE POLICY "Public images are viewable by everyone"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'imagenes');

-- Policy: Solo el owner puede subir
CREATE POLICY "Users can upload their own avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' 
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- Policy: Solo el owner puede eliminar
CREATE POLICY "Users can delete own avatars"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
```

### Usar desde Flutter

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final storage = Supabase.instance.client.storage;

// Subir archivo
final file = File('path/to/image.jpg');
await storage.from('avatars').upload(
  'user_${userId}/avatar.jpg',
  file,
);

// Obtener URL pública
final url = storage.from('avatars').getPublicUrl('avatar.jpg');

// Descargar archivo
final data = await storage.from('avatars').download('avatar.jpg');
```

---

## 1.4 Realtime (Tiempo Real)

### Suscripciones a Tablas

```dart
// Flutter - escuchar cambios en una tabla
final supabase = Supabase.instance.client;

// Suscribirse a inserts
supabase
  .from('mensajes:channel_id=eq.$channelId')
  .stream(primaryKey: ['id'])
  .listen((List<Map<String, dynamic>> data) {
    // Nuevo mensaje recibido
    print('Nuevo mensaje: ${data.last}');
  });

// Suscribirse a cambios específicos
supabase
  .from('productos')
  .stream(primaryKey: ['id'])
  .where('stock', 'lt', 5)  // Solo productos con poco stock
  .listen((data) {
    // Notificar al admin
  });
```

### Configurar Realtime en PostgreSQL

```sql
-- Habilitar Realtime en una tabla
ALTER TABLE mensajes REPLICA IDENTITY FULL;

-- Ver tablas con Realtime enabled
SELECT * FROM pg_publication_tables;
```

### Broadcast (mensajería instantánea)

```dart
// Channel para comunicación en tiempo real
final channel = supabase.channel('room1');

channel
  .on(
    RealtimeChannelEvent.broadcast,
    ChannelFilter(event: 'cursor-pos'),
    (payload, ref) {
      print('Cursor position: ${payload['x']}, ${payload['y']}');
    },
  )
  .subscribe();

// Enviar mensaje
channel.send(
  type: RealtimeChannelEvent.broadcast,
  event: 'cursor-pos',
  payload: {'x': 100, 'y': 200},
);
```

---

## 1.5 Integración con Flutter

### Configurar Cliente

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://tu-servidor.supabase.co',
    anonKey: 'tu-anon-key',
  );
  
  runApp(const MyApp());
}
```

### Cliente para Serverpod + Supabase

```dart
// Combinar ambos (si es necesario)
class ApiClient {
  final ServerpodClient serverpod;
  final SupabaseClient supabase;
  
  ApiClient({
    required this.serverpod,
    required this.supabase,
  });
}

// Usar según necesidad:
// - Serverpod: lógica de negocio, auth personalizado
// - Supabase: storage, realtime, funciones edge
```

---

## 1.6 Respaldo y Restauración

### Backup

```bash
# Backup completo
docker exec -t supabase-db-1 pg_dump -U postgres -d postgres > backup.sql

# Backup con compression
docker exec -t supabase-db-1 pg_dump -U postgres -d postgres | gzip > backup.sql.gz

# Backup de tabla específica
docker exec -t supabase-db-1 pg_dump -U postgres -d postgres -t usuarios > usuarios.sql
```

### Restaurar

```bash
# Restaurar
docker exec -i supabase-db-1 psql -U postgres -d postgres < backup.sql

# Restaurar con gzip
gunzip -c backup.sql.gz | docker exec -i supabase-db-1 psql -U postgres -d postgres
```

---

## 1.7 Ejercicios Prácticos

### Ejercicio 1: Tabla con Relaciones

```sql
-- Crear estructura de blog
CREATE TABLE autores (
  id SERIAL PRIMARY KEY,
  nombre TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT
);

CREATE TABLE articulos (
  id SERIAL PRIMARY KEY,
  autor_id INTEGER REFERENCES autores(id),
  titulo TEXT NOT NULL,
  contenido TEXT,
  publicado BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE comentarios (
  id SERIAL PRIMARY KEY,
  articulo_id INTEGER REFERENCES articulos(id),
  autor TEXT NOT NULL,
  texto TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agregar índices
CREATE INDEX idx_articulos_autor ON articulos(autor_id);
CREATE INDEX idx_comentarios_articulo ON comentarios(articulo_id);
```

### Ejercicio 2: Función con Transacción

```sql
-- Crear función para crear artículo con autor
CREATE OR REPLACE FUNCTION crear_articulo_con_autor(
  p_autor_nombre TEXT,
  p_titulo TEXT,
  p_contenido TEXT
) RETURNS INTEGER AS $$
DECLARE
  v_autor_id INTEGER;
  v_articulo_id INTEGER;
BEGIN
  -- Buscar o crear autor
  SELECT id INTO v_autor_id 
  FROM autores WHERE nombre = p_autor_nombre;
  
  IF v_autor_id IS NULL THEN
    INSERT INTO autores (nombre) VALUES (p_autor_nombre)
    RETURNING id INTO v_autor_id;
  END IF;
  
  -- Crear artículo
  INSERT INTO articulos (autor_id, titulo, contenido)
  VALUES (v_autor_id, p_titulo, p_contenido)
  RETURNING id INTO v_articulo_id;
  
  RETURN v_articulo_id;
END;
$$ LANGUAGE plpgsql;
```

### Ejercicio 3: Realtime en Flutter

```dart
// Escuchar nuevos comentarios
StreamBuilder(
  stream: supabase
    .from('comentarios:articulo_id=eq.${articuloId}')
    .stream(primaryKey: ['id']),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final comentarios = snapshot.data!;
    return ListView.builder(
      itemCount: comentarios.length,
      itemBuilder: (context, index) {
        return CommentTile(data: comentarios[index]);
      },
    );
  },
)
```

---

## 1.8 Recursos Adicionales

### Herramientas de PostgreSQL

```
- pgAdmin: GUI para gestión
- DBeaver: Cliente universal
- TablePlus: GUI moderna
- psql: CLI nativo
```

### Conceptos Clave

```
PostgreSQL:
- Schemas: espacios de nombres
- Extensions: funcionalidades extra (uuid-ossp, pg_trgm, etc.)
- Views: consultas guardadas
- Materialized Views: caché de consultas
- Functions: lógica en DB
- Triggers: acciones automáticas
- Constraints: reglas de validación
- Foreign Data Wrappers: acceder datos externos
```

---

## Resumen

En esta guía has aprendido:

- ✅ Conectar a PostgreSQL de Supabase
- ✅ Tipos de datos avanzados (JSON, arrays, UUID)
- ✅ Funciones y triggers
- ✅ Índices para rendimiento
- ✅ Storage (buckets y políticas)
- ✅ Realtime (suscripciones)
- ✅ Integración con Flutter

**Siguiente guía:** Odoo en Docker - ERP empresarial.