# 12 - Comandos Útiles

Este módulo proporciona una referencia completa de los comandos más útiles en LazyVim.

---

## 1. Comandos de LazyVim

### 1.1 Gestión de Plugins

| Comando | Descripción |
|---------|-----------|
| `:Lazy` | Abrir gestor de plugins |
| `:Lazy sync` | Sincronizar plugins |
| `:Lazy update` | Actualizar plugins |
| `:Lazy clean` | Limpiar plugins no usados |
| `:Lazy install` | Instalar plugins |
| `:Lazy log` | Ver logs |
| `:Lazy profile` | Perfil de rendimiento |
| `:Lazy debug` | Modo debug |

### 1.2 Comandos Extras

| Comando | Descripción |
|---------|-----------|
| `:LazyExtras` | Gestor de Extras |
| `:LazyExtras!` | Actualizar extras |

### 1.3 Verificación

| Comando | Descripción |
|---------|-----------|
| `:LazyHealth` | Verificar salud de LazyVim |
| `:LazyHealth cmp` | Verificar autocomplete |
| `:LazyHealth lsp` | Verificar LSP |

---

## 2. Comandos de Mason

### 2.1 Gestor de Paquetes

| Comando | Descripción |
|---------|-----------|
| `:Mason` | Abrir Manager |
| `:MasonInstall <pkg>` | Instalar paquete |
| `:MasonUninstall <pkg>` | Desinstalar paquete |
| `:MasonUninstallAll` | Desinstalar todos |
| `:MasonUpdate` | Actualizar |
| `:MasonUpdateAll` | Actualizar todos |

### 2.2 Instalar Paquetes Recomendados

```vim
" LSPs
:MasonInstall dartls
:MasonInstall ts_ls
:MasonInstall vtsls
:MasonInstall lua_ls
:MasonInstall pyright
:MasonInstall rust_analyzer
:MasonInstall gopls

" Formatters
:MasonInstall prettier
:MasonInstall dart_format
:MasonInstall stylua
:MasonInstall black
:MasonInstall shfmt

" Linters
:MasonInstall eslint
:MasonInstall pylint
:MasonInstall shellcheck
```

---

## 3. Comandos de LSP

### 3.1 Información

| Comando | Descripción |
|---------|-----------|
| `:LspInfo` | Información del LSP activo |
| `:LspLog` | Ver logs del LSP |
| `:LspInstallLog` | Ver logs de instalación |
| `:LspRestart` | Reiniciar LSP |

### 3.2 Acciones

| Comando | Descripción |
|---------|-----------|
| `:LspStart <server>` | Iniciar LSP |
| `:LspStop <server>` | Detener LSP |
| `:LspStopAll` | Detener todos los LSP |

---

## 4. Comandos de Buffer

### 4.1 Basic Commands

| Comando | Descripción |
|---------|-----------|
| `:w` o `:write` | Guardar archivo |
| `:wa` o `:wall` | Guardar todos |
| `:q` o `:quit` | Cerrar archivo |
| `:qa` o `:qall` | Cerrar todos |
| `:qa!` o `:qall!` | Forzar cierre |
| `:bd` | Eliminar buffer |
| `:bd!` | Forzar eliminar buffer |
| `:bdelete` | Eliminar buffer |

### 4.2 buffer Navigation

| Comando | Descripción |
|---------|-----------|
| `:bnext` o `]b` | Buffer siguiente |
| `:bprevious` o `[b` | Buffer anterior |
| `:bfirst` | Primer buffer |
| `:blast` | Último buffer |
| `:buffer N` | Ir a buffer N |
| `:buffers` | Listar buffers |

### 4.3buffer Special

| Comando | Descripción |
|---------|-----------|
| `:sbuffer N` | Split buffer N |
| `:vert sbuffer N` | VSplit buffer N |

---

## 5. Comandos de Ventana

### 5.1 Splits

| Comando | Descripción |
|---------|-----------|
| `:sp` o `:split` | Split horizontal |
| `:vsp` o `:vsplit` | Split vertical |
| `:new` | Nueva ventana |
| `:vnew` | Nueva ventana vertical |
| `:tabnew` | Nueva pestaña |

### 5.2 Ventana Navigation

| Comando | Descripción |
|---------|-----------|
| `:close` o `:clo` | Cerrar ventana |
| `:only` o `:onone` | Cerrar otras |
| `:quit` o `:q` | Cerrar |

### 5.3 Movimiento

| Comando | Descripción |
|---------|-----------|
| `Ctrl+w h` | Ventana izquierda |
| `Ctrl+w j` | Ventana abajo |
| `Ctrl+w k` | Ventana arriba |
| `Ctrl+w l` | Ventana derecha |
| `Ctrl+w w` | Siguiente ventana |
| `Ctrl+w p` | Ventana anterior |
| `Ctrl+w q` | Cerrar ventana actual |

---

## 6. Comandos de Búsqueda

### 6.1 Búsqueda Básica

| Comando | Descripción |
|---------|-----------|
| `/` | Buscar hacia adelante |
| `?` | Buscar hacia atrás |
| `*` | Buscar palabra bajo cursor |
| `#` | Buscar palabra hacia atrás |
| `:s/` | Buscar y reemplazar |

### 6.2 Reemplazar

| Comando | Descripción |
|---------|-----------|
| `:s/old/new` | Reemplazar en línea |
| `:s/old/new/g` | Reemplazar todos en línea |
| `:s/old/new/gc` | Con confirmación |
| `:%s/old/new/g` | Reemplazar en archivo |
| `:%s/old/new/gc` | En archivo con confirmación |
| `:'<,'>s/old/new/g` | En selección |

### 6.3 Find and Replace

| Comando | Descripción |
|---------|-----------|
| `:cfindo` | Find hacia abajo |
| `:cfind UP` | Find hacia arriba |

---

## 7. Comandos de Git

### 7.1 LazyGit

| Comando | Descripción |
|---------|-----------|
| `:Git` | Abrir lazygit |
| `:Git` (en archivo) | Diff archivo |

### 7.2 Comandos Rápidos

| Comando | Descripción |
|---------|-----------|
| `:Git add .` | Stage todo |
| `:Git commit -m "msg"` | Commit |
| `:Git push` | Push |
| `:Git pull` | Pull |
| `:Git status` | Status |
| `:Git log` | Log |
| `:Git diff` | Diff |

---

## 8. Comandos de Sesión

### 8.1 Persistence

| Comando | Descripción |
|---------|-----------|
| `:mksession` | Guardar sesión |
| `:mksession!` | Sobrescribir sesión |
| `:source` | Cargar sesión |
| `:Obsession` | Cargar sesión al inicio |

### 8.2 Persistencia Rápida

| Atajo | Descripción |
|-------|-------------|
| `<leader>qs` | Restore Session |
| `<leader>ql` | Restore Last Session |
| `<leader>qd` | Don't Save Current Session |

---

## 9. Comandos de Terminal

### 9.1 Terminal Embebida

| Atajo | Descripción |
|-------|-------------|
| `<leader>ft` | Terminal en raíz |
| `<leader>fT` | Terminal en cwd |

### 9.2 Terminal Commands

| Comando | Descripción |
|---------|-----------|
| `:terminal` o `:te` | Nueva terminal |
| `:tselect` | Seleccionar terminal |
| `:vert terminal` | Terminal vertical |

---

## 10. Comandos de Diagnostic

### 10.1 Diagnostics

| Comando | Descripción |
|---------|-----------|
| `:lua vim.diagnostic.open_float()` | Ver error |
| `:lua vim.diagnostic.goto_prev()` | Error anterior |
| `:lua vim.diagnostic.goto_next()` | Error siguiente |
| `:lua vim.diagnostic.setqflist()` | Quickfix list |

### 10.2 Trouble

| Atajo | Descripción |
|-------|-------------|
| `<leader>xx` | Diagnostics |
| `<leader>xX` | Buffer Diagnostics |
| `<leader>xL` | Location List |
| `<leader>xQ` | Quickfix List |

---

## 11. Comandos de LSP

### 11.1 LSP Actions

| Comando | Descripción |
|---------|-----------|
| `:lua vim.lsp.buf.hover()` | Hover |
| `:lua vim.lsp.buf.definition()` | Go to Definition |
| `:lua vim.lsp.buf.declaration()` | Go to Declaration |
| `:lua vim.lsp.buf.implementation()` | Go to Implementation |
| `:lua vim.lsp.buf.references()` | Find References |
| `:lua vim.lsp.buf.rename()` | Rename |
| `:lua vim.lsp.buf.code_action()` | Code Action |
| `:lua vim.lsp.buf.format()` | Format |

### 11.2 LSP Menus

| Comando | Descripción |
|---------|-----------|
| `:LspMenu` | Menú LSP |

---

## 12. Comandos de Test

### 12.1 Neotest

| Comando | Descripción |
|---------|-----------|
| `:Neotest` | Panel de test |
| `:Neotest run` | Correr tests |
| `:Neotest file` | Test archivo |
| `:Neotest nearest` | Test más cercano |
| `:Neotest summary` | Resumen |
| `:Neotest summary toggle` | Toggle resumen |

### 12.2 DAP Tests

```vim
:lua require("neotest").run()
:lua require("neotest").run_file()
:lua require("neotest").run({ strategy = "dap" })
```

---

## 13. Comandos de DAP

### 13.1 Basic

| Atajo | Descripción |
|-------|-------------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |
| `<leader>dl` | Run Last |
| `<leader>dq` | Stop |

### 13.2 Session

| Atajo | Descripción |
|-------|-------------|
| `<leader>ds` | Session |
| `<leader>dr` | Toggle REPL |

---

## 14. Comandos de Utility

### 14.1 Quickfix

| Comando | Descripción |
|---------|-----------|
| `:copen` | Abrir quickfix |
| `:cclose` | Cerrar quickfix |
| `:cnext` | Siguiente |
| `:cprevious` | Anterior |
| `:clist` | Lista |

### 14.2 Location List

| Comando | Descripción |
|---------|-----------|
| `:lopen` | Abrir location list |
| `:lclose` | Cerrar location |
| `:lnext` | Siguiente |
| `:lprevious` | Anterior |
| `:llist` | Lista |

---

## 15. Comandos de Utilities

### 15.1 File Operations

| Comando | Descripción |
|---------|-----------|
| `:e archivo` | Abrir archivo |
| `:e .` | Explorar directorio |
| `:find patron` | Buscar archivo |
| `:Ex` o `:Explore` | Explorador |
| `:Sexplore` | Explorador horizontal |
| `:Vexplore` | Explorador vertical |

### 15.2 Buffers Files

| Comando | Descripción |
|---------|-----------|
| `:args` | Ver argumentos |
| `:arga archivos` | Agregar argumentos |
| `:argdo` | Aplicar a argumentos |

### 15.3 Jump

| Comando | Descripción |
|---------|-----------|
| `:jumps` | Ver saltos |
| `:marks` | Ver marks |
| `:changes` | Ver cambios |

---

## 16. Comandos de Vim

### 16.1 Vim Basic

| Comando | Descripción |
|---------|-----------|
| `:h` o `:help` | Help |
| `:h tema` | Help de tema |
| `:version` | Versión de Vim |
| `:scriptnames` | Scripts cargados |
| `:set all` | Todas las opciones |
| `:options` | UI de opciones |

### 16.2 Vim Mode

| Comando | Descripción |
|---------|-----------|
| `:normal comando` | Ejecutar en modo normal |
| `:execute código` | Ejecutar código |
| `:lua código` | Ejecutar Lua |
| `:javascript código` | Ejecutar JS |

---

## Siguiente Paso

El siguiente módulo cubre el **[flujo de trabajo diario](13_flujo_diario.md)**.

---

**Última actualización**: 2026