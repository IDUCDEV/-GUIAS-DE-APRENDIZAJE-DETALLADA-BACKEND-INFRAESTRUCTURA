# 13 - Flujo de Trabajo Diario

Este módulo te enseña el flujo de trabajo diario para maximizar tu productividad con LazyVim.

---

## 1. Iniciar un Proyecto

### 1.1 Abrir Proyecto

```bash
# Abrir proyecto
nvim .

# O
cd mi-proyecto && nvim
```

### 1.2 Proyectos Recientes

```vim
<leader>fp  " Projects
<leader>fr  " Recent files
<leader>fR  " Recent (cwd)
```

### 1.3 Session Restore

```vim
<leader>qs  " Restore Session
```

---

## 2. Estructura de Desarrollo

### 2.1 workflow Genérico

1. **Abrir archivo**: `<leader>ff` + nombre de archivo
2. **Buscar en código**: `<leader>sg` + término a buscar
3. **Go to definition**: `gd` (o `gI` para implementación)
4. **Find references**: `gr`
5. **Show documentation**: `K` (hover)
6. **Code actions**: `<leader>ca`
7. **Rename**: `<leader>cr`
8. **Organize imports**: `<leader>co`
9. **Format**: `<leader>cf`
10. **Save**: `:w` o `Ctrl+s`

### 2.2 workflow para Flutter

1. Abrir proyecto
2. `flutter pub get`
3. `<leader>fr` para ejecutar Flutter Run
4. Editar código
5. Hot reload automático
6. `<leader>xx` para ver errores

### 2.3 workflow para TypeScript/Next.js

1. Abrir proyecto
2. `npm install`
3. `<leader>ft` para terminal
4. `npm run dev`
5. `<leader>sg` para buscar
6. `<leader>xx` para diagnostics

---

## 3. Búsqueda Rápida

### 3.1 Buscar Archivos

| Atajo | Uso |
|-------|-----|
| `<leader>ff` | Buscar archivo |
| `<leader>fF` | Buscar en cwd |
| `<leader>fg` | Git files |
| `<leader>fr` | Recientes |

### 3.2 Buscar en Código

| Atajo | Uso |
|-------|-----|
| `<leader>sg` | Grep proyecto |
| `<leader>sG` | Grep cwd |
| `<leader>,` | En buffers |
| `<leader>sb` | Líneas en buffer |

### 3.3 Buscar Special

| Atajo | Uso |
|-------|-----|
| `<leader>sc` | Command history |
| `<leader>s/` | Search history |
| `<leader>sh` | Help pages |
| `<leader>sk` | Keymaps |

---

## 4. Edición Rápida

### 4.1 Movimientos

| Atajo | Función |
|-------|--------|
| `ci"` | Cambiar dentro de comillas |
| `ci(` | Cambiar dentro de parens |
| `ciw` | Cambiar palabra |
| `caw` | Cambiar around word |
| `cip` | Cambiar párrafo |
| `gUiw` | Uppercase palabra |

### 4.2 Yanking

| Atajo | Función |
|-------|--------|
| `yaw` | Yank around word |
| `yip` | Yank párrafo |
| `yap` | Yank around párrafo |
| `yi"` | Yank inside comillas |

### 4.3 Pegar

| Atajo | Función |
|-------|--------|
| `p` | Después |
| `P` | Antes |
| `gp` | Después + cursor |
| `gP` | Antes + cursor |

---

## 5. Navegación de Código

### 5.1 Movimientos LSP

| Atajo | Función |
|-------|--------|
| `gd` | Go to Definition |
| `gD` | Go to Declaration |
| `gI` | Go to Implementation |
| `gr` | References |
| `gy` | Type Definition |

### 5.2 Movimientos de Archivo

| Atajo | Función |
|-------|--------|
| `gg` | Inicio archivo |
| `G` | Fin archivo |
| `{` | Anterior función |
| `}` | Siguiente función |
| `[[` | Anterior clase |
| `]]` | Siguiente clase |

---

## 6. Errores y Warnings

### 6.1 Ver Errors

```vim
<leader>xx  " Diagnostics
<leader>xX  " Buffer Diagnostics
```

### 6.2 Navegar Errors

```vim
]d      " Siguiente error
[d      " Error anterior
]e      " Siguiente
[e      " Warning
]w      " Warning
[w      " Warning
```

---

## 7. Git Workflow

### 7.1 LazyGit

```vim
<leader>gg  " Abrir lazygit
```

### 7.2 Comandos Rápidos

| Atajo | Función |
|-------|--------|
| `<leader>gs` | Status |
| `<leader>gl` | Log |
| `<leader>gd` | Diff |
| `<leader>gc` | Commit |
| `<leader>gp` | Push |
| `<leader>gB` | Browse |

### 7.3 En LazyGit

| Key | Función |
|-----|--------|
| `s` | Stage |
| `u` | Unstage |
| `c` | Commit |
| `p` | Push |
| `q` | Quit |

---

## 8. Terminal

### 8.1 Abrir Terminal

```vim
<leader>ft  " Terminal en raíz
<leader>fT  " Terminal en cwd
```

### 8.2 Comandos

```vim
" Ejecutar comando
:!comando

" Shell interactivo
:!
```

### 8.3 Flutter/Node

```vim
<leader>ft  " Terminal
flutter run
npm run dev
```

---

## 9. Testing

### 9.1 Flutter Tests

```vim
<leader>tt  " Run all tests
<leader>tf  " Run file tests
<leader>tn  " Run nearest test
<leader>ts  " Toggle summary
```

### 9.2 TypeScript Tests

```vim
<leader>tt
npm test
```

### 9.3 DAP Testing

```vim
<leader>dc  " Continue
<leader>db  " Breakpoint
<leader>do  " Step out
<leader>dO  " Step over
<leader>di  " Step into
```

---

## 10. Debugging

### 10.1 DAP Workflow

1. Set breakpoint: `<leader>db`
2. Start: `<leader>dc`
3. Navigate: `<leader>di`, `<leader>dO`, `<leader>do`
4. Inspect variables
5. Continue: `<leader>dc`

### 10.2 Flutter DAP

```vim
<leader>da  " Run with Args
<leader>dB  " Conditional
<leader>dC  " Run to Cursor
<leader>dl  " Run Last
<leader>dP  " Pause
<leader>dr  " Toggle REPL
<leader>ds  " Session
```

---

## 11. Sessions

### 11.1 Guardar Session

```vim
:mksession ~/sessions/project.vim
```

### 11.2 Restaurar Session

```vim
:source ~/sessions/project.vim
```

### 11.3 Persistencia Automática

```vim
<leader>qs  " Restore Session
<leader>ql  " Restore Last
<leader>qd  " Don't Save
```

---

## 12. Guardar y Cerrar

### 12.1 Quick Save

```vim
:w        " Save
:w!       " Force save
:wa       " Save all
```

### 12.2 Cerrar

```vim
:q        " Quit
:q!       " Force quit
:qa       " Quit all
:qa!      " Force quit all
:qa       " Quit all
```

### 12.3 Quick Quit

```
<leader>qq  " Quit all
<leader>q   " Quit
```

---

## 13. Productivity Tips

### 13.1 Keyboard First

No uses el mouse. Todos los atajos están diseñados para usar el teclado.

### 13.2 Use Counts

```vim
3dd      " Eliminar 3 líneas
5w       " Mover 5 palabras
10j      " Mover 10 líneas
```

### 13.3 Use Dot Command

Usa `.` para repetir el último comando.

### 13.4 Macros

Graba secuencias repetitivas:

```vim
qa       " Iniciar grabación
...      " Comandos
q        " Detener

@a        " Reproducir
10@a      " 10 veces
```

---

## 14. Daily Routine

### 14.1 Morning

1. `nvim` - Abrir Neovim (session restaura automáticamente)
2. `<leader>fp` - Buscar proyecto
3. `flutter run` / `npm run dev`

### 14.2 Development

1. `<leader>ff` - Abrir archivo
2. `<leader>sg` - Buscar en código
3. `gd` - Go to definition
4. `<leader>ca` - Code actions
5. `<leader>cf` - Formatear

### 14.3 End of Day

1. `:wa` - Guardar todo
2. `:q` - Cerrar

---

## 15. Atajos de Emergencia

### 15.1 Recuperarse

```vim
:LazyHealth  " Verificar salud
:Lazy      " Ver plugins
:LspInfo   " Ver LSP
```

### 15.2 Resetear

```vim
:e!       " Recargar archivo
:source $MYINITRC  " Recargar config
```

---

## Siguiente Paso

El siguiente módulo cubre el **[debugging](14_debugging.md)**.

---

**Última actualización**: 2026