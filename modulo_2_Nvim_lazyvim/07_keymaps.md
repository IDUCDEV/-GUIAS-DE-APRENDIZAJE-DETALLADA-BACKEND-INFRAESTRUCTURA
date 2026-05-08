# 07 - Keymaps Esenciales

Este módulo proporciona una tabla comparativa completa entre VSCode y LazyVim para que puedas hacer la transición rápidamente.

---

## 1. Leader Keys

### ¿Qué es el Leader?

El **leader** es una tecla prefix que te permite crear atajos personalizados. LazyVim usa:

- **`<leader>`** = `Espacio` (por defecto)
- **`<localleader>`** = `\` (para configuraciones específicas de lenguaje)

### ¿Por qué el Leader?

- Reduce conflictos con teclas existentes
- Permite crear muchos atajos sin interferir
- Es fácil de alcanzar con el pulgar

---

## 2. Explorador de Archivos

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+B` | `<leader>e` | Toggle Explorador |
| `Ctrl+Shift+E` | `<leader>fe` | Explorer en raíz del proyecto |
| Click en archivo | `o` o `Enter` | Abrir archivo |
| `→` | `l` | Expandir carpeta |
| `←` | `h` | Contraer carpeta |
| `Ctrl+Shift+\` | `<leader>\\` | Nuevo archivo |

---

## 3. Búsqueda de Archivos

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+P` | `<leader>ff` | Buscar archivo |
| `Ctrl+Shift+P` | `<leader>fF` | Buscar archivo (cwd) |
| `Ctrl+P` (fuzzy) | `<leader>fg` | Buscar en git files |
| `Ctrl+Shift+F` | `<leader>sg` | Buscar en archivos |
| `Ctrl+Shift+H` | `<leader>sH` | Buscar en help |

### Búsqueda de Contenido en Buffers

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Tab` | `<leader>,` | Buscar en buffers |
| `Ctrl+Shift+F` | `<leader>sb` | Buscar líneas en buffer |

### Más Búsquedas

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| - | `<leader>fc` | Find Config File |
| - | `<leader>fp` | Projects |
| - | `<leader>fr` | Recent |
| - | `<leader>fR` | Recent (cwd) |
| - | `<leader>sr` | Resume búsqueda |

---

## 4. Terminal

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `` Ctrl+` `` | `<leader>ft` | Terminal en raíz |
| `` Ctrl+` `` | `<leader>fT` | Terminal en cwd |
| `Ctrl+Shift+`` | `<c-/>` | Terminal nuevo |

---

## 5. Git

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Shift+G` | `<leader>gs` | Git Status |
| Click en cambio | `<leader>gd` | Git Diff |
| `Ctrl+Shift+G` | `<leader>gl` | Git Log |
| `Alt+Shift+B` | `<leader>gB` | Git Browse |
| - | `<leader>gb` | Git Blame línea |
| - | `<leader>gD` | Git Diff (origin) |
| - | `<leader>gS` | Git Stash |

---

## 6. Pestañas (Tabs) / Buffers

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Tab` | `<leader><tab>` | Buffers |
| `Ctrl+W` | `<leader>wd` | Cerrar ventana |
| `Ctrl+Shift+W` | `<leader>bo` | Cerrar otros buffers |
| - | `<leader>bd` | Eliminar buffer |
| `Ctrl+Tab` | `]b` / `[b` | Siguiente/anterior buffer |
| `Ctrl+Shift+T` | `<leader><tab>n` | Nueva pestaña/tab |

### Navegación de Buffers

| Atajo | Descripción |
|-------|-------------|
| `]b` | Buffer siguiente |
| `[b` | Buffer anterior |
| `<S-h>` | Buffer anterior |
| `<S-l>` | Buffer siguiente |
| `<leader><tab>[` | Pestaña anterior |
| `<leader><tab>]` | Pestaña siguiente |

---

## 7. Barra Lateral de Errores

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `F8` / `Shift+F8` | `]d` / `[d` | Siguiente/anterior error |
| `Ctrl+Shift+M` | `<leader>xx` | Ver todos los errores |
| Hover sobre error | `<leader>cd` | Ver línea del error |

### Navegación de Diagnostics

| Atajo | Descripción |
|-------|-------------|
| `]d` | Siguiente diagnostic |
| `[d` | Diagnostic anterior |
| `]e` | Siguiente error |
| `[e` | Error anterior |
| `]w` | Siguiente warning |
| `[w` | Warning anterior |

---

## 8. LSP Actions

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `F12` | `gd` | Go to Definition |
| `Ctrl+Click` | `gd` | Go to Definition |
| `F12` | `gI` | Go to Implementation |
| `Ctrl+Shift+F12` | `gr` | Find References |
| `Ctrl+.` | `<leader>ca` | Code Action |
| `Ctrl+Shift+R` | `<leader>cr` | Rename |
| Hover | `K` | Hover (mostrar info) |
| `Ctrl+Space` | `gK` | Signature Help |

### Más LSP Keymaps

| Atajo | Descripción |
|-------|-------------|
| `gD` | Go to Declaration |
| `gy` | Go to Type Definition |
| `<leader>cl` | Lsp Info |
| `<leader>cR` | Rename File |
| `<leader>cA` | Source Action |

---

## 9. Refactoring

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Shift+K` | `<leader>co` | Organizar Imports |
| Extraer a... | `<leader>cR` | Rename File |

---

## 10. Formateo

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Shift+I` | `<leader>cf` | Formatear archivo |
| `Ctrl+S` | `:w` | Guardar |

### Conform.nvim

```vim
:ConformInfo  " Ver formateadores activos
:Conform      " Formatear manualmente
```

---

## 11. Debugging

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `F5` | `<leader>dc` | Continue |
| `F10` | `<leader>dO` | Step Over |
| `F11` | `<leader>di` | Step Into |
| `Shift+F11` | `<leader>do` | Step Out |
| `F9` | `<leader>db` | Toggle Breakpoint |
| - | `<leader>dB` | Breakpoint condition |

### Más Debug

| Atajo | Descripción |
|-------|-------------|
| `<leader>da` | Run with Args |
| `<leader>dC` | Run to Cursor |
| `<leader>dg` | Go to Line |
| `<leader>dl` | Run Last |
| `<leader>dP` | Pause |
| `<leader>dr` | Toggle REPL |
| `<leader>ds` | Session |

---

## 12. Miscellaneous

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+Shift+P` | `<leader>:` | Command Palette |
| `Ctrl+Shift+P` | `<leader>sc` | Command History |
| `Ctrl+P` | `<leader>sr` | Resume búsqueda |
| `Esc` | `Esc` | Clear hlsearch + Escape |

---

## 13. Window Management

### VSCode vs LazyVim

| VSCode | LazyVim | Descripción |
|--------|--------|-------------|
| `Ctrl+\` | `<leader>\|` | Split vertical |
| `Ctrl+Enter` | `<leader>-` | Split horizontal |
| `Ctrl+k` + dirección | `Ctrl+h/j/k/l` | Mover entre ventanas |

### Window Keymaps

| Atajo | Descripción |
|-------|-------------|
| `<leader>-` | Split horizontal |
| `\|` | Split vertical |
| `<leader>wm` | Toggle zoom de ventana |
| `<leader>wd` | Cerrar ventana |
| `<leader>wm` | Toggle Zoom Mode |

---

## 14. Which-Key

**Which-Key** muestra una popup con los keymaps disponibles cuando presionas una tecla.

### Cómo Usar

Solo presiona **`<space>`** o **`\`** para ver todos los keymaps:

```
╭───────────────────────────────────╮
│ leader                             │
│ ├─ , → Buffers                    │
│ ├─ . → Scratch Buffer            │
│ ├─ / → Grep (Root Dir)            │
│ ├─ : → Command History           │
│ ├─ ; → Which-Key                │
│ ├─ f → Find                     │
│ ├─ g → Git                      │
│ └─ ...                         │
╰───────────────────────────────────╯
```

---

## 15. Quick Reference Card

### Atajos Más Usados

| Categoría | Atajo | Función |
|-----------|------|--------|
| **Archivos** | `<leader>ff` | Buscar archivo |
| **Buscar** | `<leader>sg` | Grep en proyecto |
| **Terminal** | `<leader>ft` | Terminal |
| **Git** | `<leader>gs` | Git status |
| **Errores** | `<leader>xx` | Diagnostics |
| **LSP** | `gd` | Go to Definition |
| **LSP** | `gr` | Find References |
| **LSP** | `<leader>ca` | Code Action |
| **LSP** | `<leader>cr` | Rename |
| **Terminar** | `:qa` | Salir |

### Atajos de Navegación

| Atajo | Función |
|-------|---------|
| `h,j,k,l` | Moverse |
| `w,b` | Palabras |
| `0,$` | Inicio/Fin de línea |
| `gg,G` | Inicio/Fin de archivo |
| `/` | Buscar |
| `n,N` | Siguiente/anterior |

### Atajos de Edición

| Atajo | Función |
|-------|---------|
| `dd` | Eliminar línea |
| `dw` | Eliminar palabra |
| `cw` | Cambiar palabra |
| `yw` | Yanking palabra |
| `p` | Pegar |
| `.` | Repetir |

---

## Siguiente Paso

El siguiente módulo cubre la **[configuración para Flutter/Dart](08_flutter_dart.md)**.

---

## Recursos

- [LazyVim Keymaps](https://www.lazyvim.org/keymaps)
- [Which-Key](https://github.com/folke/which-key.nvim)

---

**Última actualización**: 2026