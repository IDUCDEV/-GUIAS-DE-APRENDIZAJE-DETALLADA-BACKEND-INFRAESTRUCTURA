# 10 - Integración con Supabase

Este módulo te enseña a integrar LazyVim con Supabase para el desarrollo de aplicaciones con backend-as-a-service.

---

## 1. Herramientas de Supabase

### 1.1 CLI de Supabase

El CLI de Supabase proporciona:

- **Local Development**: Servidor local de Supabase
- **Database Migrations**: Gestión de la base de datos
- **Edge Functions**: Funciones serverless
- **Auth**: Autenticación local
- **Storage**: Storage local

### 1.2 Instalar CLI

```bash
# Con npm
npm install -g supabase

# Con Homebrew
brew install supabase/tap/supabase

# Linux/macOS
curl -fsSL https://github.com/supabase/cli/releases/download/v1.100.0/supabase_linux_amd64.tar.gz | tar -xz
sudo mv supabase /usr/local/bin/
```

### 1.3 Verificar Instalación

```bash
supabase --version
```

---

## 2. Configuración de SQL en Neovim

### 2.1 Plugins Recomendados

```lua
-- ~/.config/nvim/lua/plugins/supabase.lua
return {
  -- Resaltado de SQL
  { "mattn/vim-sql-syntax", ft = { "sql", "postgresql" } },

  -- Comandos SQL
  {
    "kristijanhusak/vim-dadbod",
    ft = { "sql", "postgresql", "mysql" },
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
    },
  },
}
```

### 2.2 Dadbod Configuration

```lua
-- ~/.config/nvim/lua/config/dadbod.lua
return {
  "kristijanhusak/vim-dadbod",
  opts = {
    hostname = "localhost",
    password = "",
  },
}
```

---

## 3. Conexión a Supabase

### 3.1 Variables de Entorno

Crea un archivo `.env` en la raíz de tu proyecto:

```
SUPABASE_DB_URL=postgresql://postgres:[password]@localhost:54322/postgres
SUPABASE_API_URL=http://localhost:54321
```

### 3.2 Connectar a Base de Datos

```bash
# Iniciar Supabase local
supabase start

# O usar Docker
supabase start --use-docker
```

### 3.3 Conectar con Dadbod

```vim
" Conectar a Supabase local
:DB postgresql://postgres:postgres@localhost:54322/postgres

" O conectar a producción
:DB postgresql://[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres
```

---

## 4. SQL Editing en Neovim

### 4.1 Comandos Básicos

```vim
" Abrir archivo SQL
:e queries.sql

" Ejecutar consulta
:DB

" Ejecutar rango visual
:'<,'>DB

" Guardar historial
:DBHistory
```

### 4.2 Atajos

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- SQL
keymap("n", "<leader>db", ":DB<CR>", { desc = "Execute SQL", silent = true })
keymap("v", "<leader>db", ":'<,'>DB<CR>", { desc = "Execute SQL selection", silent = true })
```

---

## 5. SQL con LSP

### 5.1 Instalar LSP de PostgreSQL

```vim
:MasonInstall pgsql_ls
```

### 5.2 Configuración LSP

```lua
-- ~/.config/nvim/lua/plugins/pgsql.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      pgsql_ls = {
        settings = {
          pgsql = {
            -- configuración
          },
        },
      },
    },
  },
}
```

---

## 6. Migrations

### 6.1 Crear Migration

```bash
# Nueva migration
supabase migration new nombre_de_migration
```

### 6.2 Aplicar Migrations

```bash
# Aplicar todas las migrations
supabase db reset

# Aplicar hasta una migración específica
supabase migration repair <version>
```

### 6.3 Ver Estado

```bash
# Ver estado de migrations
supabase migration list
```

---

## 7. Edge Functions

### 7.1 Crear Edge Function

```bash
supabase functions new mi-funcion
```

### 7.2 Estructura de Edge Function

```typescript
// supabase/functions/mi-funcion/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "@supabase/supabase-js.ts"

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
)

serve(async (req) => {
  const { data, error } = await supabase.from("tabla").select("*")

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 500 })
  }

  return new Response(JSON.stringify({ data }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

### 7.3 Desarrollar Local

```bash
# Servir funciones localmente
supabase functions serve

# Con hot reload
supabase functions serve --no-verify-jwt
```

---

## 8. Autenticación

### 8.1 Configuración de Auth

El CLI de Supabase incluye un servidor de auth local. Para probarlo:

```bash
# Iniciar con auth
supabase start
```

### 8.2 Testing Auth

```bash
# Crear usuario de prueba
supabase auth sign-up email@ejemplo.com password123

# Iniciar sesión
supabase auth sign-in email@ejemplo.com password123
```

---

## 9. Integración con Flutter

### 9.1 Configuración Flutter

Cuando usas Flutter con Supabase, la integración es vía código:

```dart
// lib/supabase_client.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://[project].supabase.co',
    anonKey: '[anon-key]',
  );
  
  runApp(MyApp());
}
```

### 9.2 LSP para Dart

El LSP de Dart ya está configurado en módulos anteriores.

---

## 10. Queries Útiles

### 10.1 Queries Comunes

```sql
-- Obtener todas las tablas
SELECT tablename 
FROM pg_catalog.pg_tables 
WHERE schemaname = 'public';

-- Obtener columnas de una tabla
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'nombre_tabla';

-- Ver foreign keys
SELECT
    tc.table_name, 
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

### 10.2 Query para Stats

```sql
-- Ver tamaño de tablas
SELECT 
    relname,
    pg_size_pretty(pg_total_relation_size(relid))
FROM pg_catalog.pg_class
WHERE relkind = 'r'
ORDER BY pg_total_relation_size(relid) DESC
LIMIT 10;
```

---

## 11. Atajos para Supabase

### 11.1 Atajos de Comandos

```bash
# Iniciar Supabase local
supabase start

# Detener Supabase local
supabase stop

# Estado
supabase status

# Resetear base de datos
supabase db reset

# Deployar funciones
supabase functions deploy

# Ver logs
supabase functions logs
```

### 11.2 Atajos en Neovim

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Supabase
keymap("n", "<leader>ss", ":DB<CR>", { desc = "Execute SQL", silent = true })
keymap("n", "<leader>sl", ":DBHistory<CR>", { desc = "SQL History", silent = true })
```

---

## 12. Solución de Problemas

### 12.1 No Conecta a Base de Datos

```bash
# Verificar que Supabase está corriendo
supabase status

# Reiniciar
supabase stop && supabase start
```

### 12.2 Error de Puerto

```bash
# Usar puerto diferente
supabase start -p 54321
```

### 12.3 Migration Falla

```bash
# Ver estado
supabase migration list

# Resetear
supabase db reset
```

---

## Siguiente Paso

El siguiente módulo cubre la **[personalización avanzada](11_personalizacion.md)**.

---

## Recursos

- [Supabase CLI](https://github.com/supabase/cli)
- [vim-dadbod](https://github.com/kristijanhusak/vim-dadbod)
- [Supabase Docs](https://supabase.com/docs)

---

**Última actualización**: 2026