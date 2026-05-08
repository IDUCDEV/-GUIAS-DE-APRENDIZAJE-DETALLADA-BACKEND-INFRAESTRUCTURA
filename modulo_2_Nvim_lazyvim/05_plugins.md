# 05 - Plugins Incluidos

LazyVim viene con un conjunto de plugins pre-configurados. Este módulo te enseña qué plugins incluye y cómo usarlos.

---

## 1. Plugins por Categoría

### 1.1 Coding (Autocomplete, Snippets, Pares)

| Plugin | Función | Atajo Importante |
|--------|---------|-----------------|
| **blink.cmp** | Autocomplete/IntelliSense | `Tab` / `Ctrl+Space` |
| **mini.pairs** | AutoPairs automático | Auto |
| **mini.ai** | Texto objetos extendidos | `ciw`, `da(`, etc. |
| **mini.surround** | Surround handling | `gsd`, `gsf` |
| **vim-vsnip** | Snippets | Auto |

### 1.2 LSP (Language Server Protocol)

| Plugin | Función |
|--------|---------|
| **nvim-lspconfig** | Cliente LSP base |
| **mason.nvim** | Gestor de LSPs/formatters |
| **mason-lspconfig.nvim** | Integración LSP-Mason |

### 1.3 TreeSitter (Syntax Highlighting)

| Plugin | Función |
|--------|---------|
| **nvim-treesitter** | Syntax highlighting avanzado |

### 1.4 Editor (Explorer, Fuzzy Find, Git)

| Plugin | Función | Atajo |
|--------|--------|-------|
| **snacks.nvim** | Utilidades UI, file finder | `<leader>f/` |
| **fzf-lua** | Fuzzy finder | `<leader>ff` |
| **gitsigns** | Git signs en el gutter | Auto |
| **lazygit** | UI de Git | `<leader>gg` |
| **trouble.nvim** | Diagnostics list | `<leader>xx` |

### 1.5 UI (Statusline, Bufferline)

| Plugin | Función |
|--------|---------|
| **noice.nvim** | UI de mensajes |
| **bufferline.nvim** | Buffer tabs |
| **lualine** | Statusline |
| **indentscope** | Indent guides |

### 1.6 Util (Sesiones, Herramientas)

| Plugin | Función |
|--------|---------|
| **persistence.nvim** | Session persistence |
| **nvim-spectre** | Search and replace |
| **nvim-dap** | Debugger |

---

## 2. Blink.cmp (Autocomplete)

### Características

- Autocomplete moderno y rápido
- Soporte para LSP, snippets, y más
- Completions asíncronos

### Atajos

| Atajo | Modo | Función |
|------|------|--------|
| `Tab` | Insert | Siguiente suggestion |
| `Shift+Tab` | Insert | Suggestion anterior |
| `Enter` | Insert | Accept suggestion |
| `Ctrl+Space` | Insert | Toggle autocomplete |
| `Ctrl+n` | Insert | Siguiente |
| `Ctrl+p` | Insert | Anterior |

### Configuración

```lua
-- ~/.config/nvim/lua/plugins/blink.lua
return {
  "Saghen/blink.cmp",
  opts = {
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    cmdline = {
      enabled = true,
    },
  },
}
```

---

## 3. Mini.pairs (AutoPairs)

### Características

- Inserta automáticamente el carácter de cierre
- Detecta y maneja casos especiales
- Funciona con paréntesis, corchetes, etc.

### Configuración

```lua
-- ~/.config/nvim/lua/plugins/minipairs.lua
return {
  "nvim-mini/mini.pairs",
  opts = {
    modes = { insert = true, command = true, terminal = false },
    skip_next = [=[[%w%%%'%[%"%.%`%$]],
    skip_unbalanced = true,
  },
}
```

---

## 4. Mini.ai (Texto Objetos)

### Texto Objetos Disponibles

| Texto Objeto | Descripción | Ejemplo |
|-------------|-------------|--------|
| `iw` | Inner word | `ciw` |
| `aw` | A word | `caw` |
| `i(` | Inner parens | `ci(` |
| `a(` | A parens | `ca(` |
| `i[` | Inner brackets | `ci[` |
| `i{` | Inner braces | `ci{` |
| `i"` | Inner quotes | `ci"` |
| `i'` | Inner single quotes | `ci'` |
| `if` | Inner function | `cif` |
| `af` | A function | `caf` |
| `ic` | Inner class | `cic` |
| `ac` | A class | `cac` |

### Usar Texto Objetos

```vim
" Cambiar dentro de parens
ci(

" Eliminar palabra completa
caw

" Cambiar función
cif
```

---

## 5. Snacks.nvim (Utilidades)

### Características

- Dashboard bonito
- Explorador de archivos
- Notificaciones
- Widgets útiles

### Keymaps Principales

| Atajo | Función |
|-------|--------|
| `<leader>/` | Grep (Root Dir) |
| `<leader>ff` | Find Files (Root Dir) |
| `<leader>fe` | Explorer Snacks |
| `<leader>fr` | Recent Files |
| `<leader>sg` | Grep (Root Dir) |
| `<leader>,` | Buffers |
| `<leader>n` | Notification History |

---

## 6. FZF-Lua (Fuzzy Finder)

### Características

- Búsqueda fuzzy ultra rápida
- Integración con git
- Preview de archivos

### Keymaps Principales

| Atajo | Función |
|-------|--------|
| `<leader>ff` | Find Files |
| `<leader>fF` | Find Files (cwd) |
| `<leader>fg` | Git Files |
| `<leader>fr` | Recent Files |
| `<leader>sg` | Grep |
| `<leader>sG` | Grep (cwd) |
| `<leader>,` | Buffers |

---

## 7. Gitsigns (Git)

### Características

- Signs en el gutter para cambios
- Modo de staging interactivo
- Preview de changes

### Keymaps Principales

| Atajo | Función |
|-------|--------|
| `<leader>gs` | Git Status |
| `<leader>gd` | Git Diff (hunks) |
| `<leader>gD` | Git Diff (origin) |
| `<leader>gl` | Git Log |
| `<leader>gb` | Git Blame línea |

### Comandos

```vim
:Sgit
:Gitsigns stage_hunk
:Gitsigns reset_hunk
:Gitsigns stage_buffer
:Gitsigns preview_hunk
```

---

## 8. LazyGit (Git UI)

### Características

- UI de Git en terminal
- staging interactivo
- Diff viewing
- Branch management

### Atajo

```vim
<leader>gg  " Abrir lazygit
```

### Comandos en LazyGit

| Key | Función |
|-----|--------|
| `p` | Push |
| `P` | Pull |
| `c` | Commit |
| `s` | Stage |
| `u` | Unstage |
| `q` | Quit |

---

## 9. Trouble.nvim (Diagnostics)

### Características

- Lista de errores/warnings
- Referencias
- Definiciones
- Quickfix list

### Keymaps

| Atajo | Función |
|-------|--------|
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer Diagnostics |
| `<leader>xL` | Location List |
| `<leader>xQ` | Quickfix List |

### Navegación

| Key | Función |
|-----|--------|
| `]q` | Siguiente trouble |
| `[q` | Anterior trouble |
| `q` | Cerrar |

---

## 10. Mason.nvim (Gestor de Herramientas)

### Características

- Instala LSPs automáticamente
- Instala formatters
- Instala linters

### Atajo

```vim
:Mason
```

### Comandos

| Comando | Función |
|---------|--------|
| `:Mason` | Abrir Manager |
| `:MasonInstall <pkg>` | Instalar paquete |
| `:MasonUninstall <pkg>` | Desinstalar paquete |
| `:MasonUpdate` | Actualizar |

### Paquetes Recomendados

```lua
-- LSPs
dartls           " Dart
ts_ls            " TypeScript
lua_ls           " Lua
pyright          " Python
rust_analyzer    " Rust
gopls            " Go

" Formatters
prettier        " General
dart_format     " Dart
stylua          " Lua
black           " Python
shfmt           " Shell

" Linters
eslint         " JavaScript/TypeScript
pylint         " Python
```

---

## 11. Nvim-dap (Debugger)

### Características

- Debugger UI
- Breakpoints
- Variables inspection
- Call stack

### Atajos

| Atajo | Función |
|-------|--------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>do` | Step Out |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>dl` | Run Last |
| `<leader>dq` | Stop |
| `<leader>dr` | Toggle REPL |
| `<leader>ds` | Session |

---

## 12. Persistence.nvim (Sesiones)

### Características

- Guarda sesiones automáticamente
- Restaura sesiones al iniciar
- Multiple sesiones

### Atajos

| Atajo | Función |
|-------|--------|
| `<leader>qs` | Restore Session |
| `<leader>ql` | Restore Last Session |
| `<leader>qd` | Don't Save Current Session |

### Comandos

```vim
:mksession  " Guardar sesión
:source    " Cargar sesión
```

---

## 13. Agregar Plugins Recomendados

### Para Flutter/Dart

```lua
-- ~/.config/nvim/lua/plugins/flutter.lua
return {
  "akinsho/flutter-tools.nvim",
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

### Para TypeScript

No necesitas agregar nada, ya está incluido en el extra de TypeScript.

### Para General

```lua
-- ~/.config/nvim/lua/plugins/general.lua
return {
  -- Comments mejorados
  { "numToStr/Comment.nvim", event = "VeryLazy" },

  -- Editor config
  { "stevearc/editorconfig.nvim", event = "VeryLazy" },

  -- Match pairs
  { "windwp/nvim-autopairs", event = "VeryLazy" },
}
```

---

## Siguiente Paso

El siguiente módulo cubre los **[modes y conceptos fundamentales](06_modes.md)** de Neovim.

---

## Recursos

- [LazyVim Plugins](https://www.lazyvim.org/plugins)
- [Blink.cmp](https://github.com/Saghen/blink.cmp)
- [Mason](https://github.com/mason-org/mason.nvim)

---

**Última actualización**: 2026