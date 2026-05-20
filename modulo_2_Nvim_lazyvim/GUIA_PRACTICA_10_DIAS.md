# Guía Práctica: de VSCode a LazyVim en 10 días

Aprendé haciendo. Cada día son **5-10 minutos** de ejercicios. Abrí LazyVim (`nvim`) y seguí estos pasos.

---

## Día 1 — Tu primer paseo (5 min)

Abrí Neovim y probá esto:

```vim
nvim                   " Abrir LazyVim
<space>                " Presioná ESPACIO → ves el menú Which-Key
<space> + e            " Abrí/cerrá el explorador de archivos
j/k                    " Navegar arriba / abajo
<Enter>                " Abrir archivo
<space> + ff           " Buscar archivos (como Ctrl+P en VSCode)
:q + Enter             " Cerrar
```

**Objetivo del día**: Saber abrir/cerrar LazyVim, navegar archivos y usar el explorador.

---

## Día 2 — Navegar como en VSCode (5 min)

Abrí cualquier proyecto y practicá esto:

| Acción | LazyVim | Como en VSCode |
|--------|---------|----------------|
| Buscar archivos | `<space> ff` | `Ctrl+P` |
| Buscar texto en archivos | `<space> sg` | `Ctrl+Shift+F` |
| Archivos recientes | `<space> fr` | `Ctrl+R` |
| Buffers abiertos | `<space> ,` | `Ctrl+Tab` |
| Explorador | `<space> e`  | `Ctrl+B` |
| Guardar | `Ctrl+S` | `Ctrl+S` |

**Objetivo del día**: Sentir que navegás tan rápido como en VSCode.

---

## Día 3 — Editar más rápido que VSCode (10 min)

Creá un archivo nuevo (`<space> ff` → nombre inventado) y escribí:

```js
const name = "Juan";
const age = 25;
function greet(person) {
  return "Hola " + person;
}
```

**Ejercicio 1**: Cambiá "Juan" por "María"
1. Poné el cursor sobre "Juan"
2. Presioná `ci"` → se borra "Juan" y entrás a Insert mode
3. Escribí "María" y presioná `Esc`

**Ejercicio 2**: Cambiá `name` por `username`
1. Cursor sobre `name`
2. `ciw` → se borra `name`
3. Escribí `username`, `Esc`

**Ejercicio 3**: Borrá toda la línea de `age`
1. Cursor en cualquier parte de la línea de `age`
2. `dd` → borra la línea completa

**Ejercicio 4**: Copiá la función `greet`
1. Cursor sobre la palabra `function`
2. `yip` → copia todo el párrafo (yank inner paragraph)
3. Movete al final y `p` → pega

**Ejercicio 5**: Usá el punto (`.`)
1. `ci"` sobre cualquier string, cambiá el texto, `Esc`
2. Movete a otro string
3. Presioná `.` → repite la acción automágicamente

**Objetivo del día**: Entender que `operador + texto objeto` es más rápido que seleccionar con mouse.

---

## Día 4 — Git sin mouse (5 min)

Abrí un proyecto con Git y practicá:

```vim
<space> + gg  " Abre LazyGit (interfaz completa tipo VSCode Source Control)
```

**Dentro de LazyGit:**
| Tecla | Acción |
|-------|--------|
| `s` | Stage archivo |
| `u` | Unstage archivo |
| `c` | Hacer commit (escribí mensaje, Enter) |
| `p` | Push |
| `q` | Salir de LazyGit |

**Sin abrir LazyGit:**
```vim
<space> + gs  " Ver status rápido
<space> + gd  " Ver diff
<space> + gl  " Ver log
<space> + gb  " Git blame
<space> + gB  " Abrir en GitHub
```

**Objetivo del día**: Hacer todo el workflow de Git sin tocar el mouse.

---

## Día 5 — LSP (Intellisense total) (5 min)

Abrí un archivo Dart o TypeScript y probá:

| Acción | LazyVim | Como en VSCode |
|--------|---------|----------------|
| Ir a definición | `gd` | `F12` |
| Buscar referencias | `gr` | `Shift+F12` |
| Ver documentación | `K` | Hover |
| Code actions | `<space> ca` | `Ctrl+.` |
| Renombrar | `<space> cr` | `Ctrl+Shift+R` |
| Organizar imports | `<space> co` | `Ctrl+Shift+O` |
| Formatear | `<space> cf` | `Ctrl+Shift+I` |

**Ejercicio**:
1. Poné el cursor sobre una función y presioná `gd` → te lleva a la definición
2. Presioná `Ctrl+o` → volvés atrás
3. Poné el cursor sobre una variable y presioná `gr` → muestra referencias
4. Presioná `K` sobre una función → ves la documentación
5. Cambiá el nombre de una variable con `<space> cr`

```vim
]d  /  [d   " Siguiente/anterior error
<space> xx  " Ver todos los errores (Trouble)
```

**Objetivo del día**: Usar el LSP sin pensar, como si fuera VSCode.

---

## Día 6 — Debugging (10 min)

### Para Flutter/Dart:

```vim
<space> db  " Poner/quitar breakpoint en la línea actual
<space> dc  " Iniciar debug (corre la app y se detiene en breakpoints)
<space> do  " Step Over (ejecuta línea, no entra en funciones)
<space> di  " Step Into (entra en la función)
<space> dO  " Step Out (sale de la función actual)
<space> du  " Mostrar/ocultar la UI de debug
<space> dq  " Detener debug

" La UI de debug se ve así:
" ┌──────────────────────────────┐
" │ Variables │ Breakpoints      │
" │ Stacks    │ Watches          │
" └──────────────────────────────┘
" ┌──────────────────────────────┐
" │ REPL / Console               │
" └──────────────────────────────┘
```

### Para TypeScript/Next.js:

```vim
<space> db  " Breakpoint
<space> dc  " Elegí "Next.js: Debug" o "Debug Current File"
```

**Objetivo del día**: Poner breakpoints y debuggear como en VSCode.

---

## Día 7 — Multi-cursor y texto objects (5 min)

### Multi-cursor (como Ctrl+D en VSCode):

Seleccioná una palabra y:
```vim
Ctrl + D  " Selecciona la siguiente ocurrencia igual
Ctrl + X  " Salta esta ocurrencia, busca la siguiente
Ctrl + P  " Deselecciona la última
Esc       " Sale de multi-cursor
```

**Ejercicio**: Tené un archivo con varias veces la palabra "color":
1. Cursor sobre "color"
2. `Ctrl+D` → selecciona la primera
3. `Ctrl+D` de nuevo → selecciona la segunda
4. Seguí hasta tener todas seleccionadas
5. Escribí el nuevo valor → cambian todas a la vez
6. `Esc` para salir

### Más texto objects (ampliando el Día 3):

```vim
ci(   " Cambia dentro de paréntesis ()
ci{   " Cambia dentro de llaves {}
ci[   " Cambia dentro de corchetes []
di"   " Borra dentro de comillas dobles
ca"   " Cambia incluyendo las comillas
yi[   " Copia dentro de corchetes
da(   " Borra incluyendo los paréntesis
```

**Objetivo del día**: Editar múltiples ocurrencias a la vez y dominar texto objects.

---

## Día 8 — Terminal + Tests (5 min)

### Terminal integrada:

```vim
<space> ft  " Abre terminal flotante
<space> fT  " Abre terminal en split vertical
Ctrl + /    " Atajo rápido (como Ctrl+ñ en VSCode)

" Dentro de la terminal:
exit + Enter  " Cerrar terminal
```

### Tests con Flutter:

```vim
<space> tt  " Correr el test más cercano al cursor
<space> tf  " Correr todo el archivo de test
<space> tn  " Correr test bajo el cursor específicamente
<space> ts  " Ver resumen de tests
```

### Tests con TypeScript:

Abrí terminal (`<space> ft`) y ejecutá:
```bash
npm test
```

**Objetivo del día**: Usar terminal y tests sin salir de Neovim.

---

## Día 9 — Vim avanzado (10 min)

### Macros (la superfórmula):

Las macros graban acciones y las repiten automáticamente.

```vim
qa          " Empieza a grabar en el registro 'a'
  (hacé las acciones que querés repetir)
q           " Para de grabar
@a          " Reproduce la macro una vez
10@a        " Reproduce 10 veces
@@          " Reproduce la última macro
```

**Ejercicio**: Tené un archivo con 10 líneas que empiezan con `// TODO: `:
1. `qa` → empezás a grabar
2. `I` → vas al inicio de la línea en Insert mode
3. `// TODO: ` → escribís el texto
4. `Esc` → volvés a Normal mode
5. `j` → bajás a la siguiente línea
6. `q` → terminás de grabar
7. `9@a` → aplicás la macro a las 9 líneas restantes

### Marks (marcas):

```vim
mm          " Marca la posición actual como 'm'
'm          " Salta a la línea de la marca 'm'
`m          " Salta exactamente a la posición de 'm'
:marks      " Ver todas las marcas
```

### Registros (copiado avanzado):

```vim
"ayw        " Yank (copia) palabra al registro 'a'
"ap         " Pega desde el registro 'a'
:reg        " Ver todos los registros disponibles
"+y         " Copiar al portapapeles del sistema
"+p         " Pegar desde portapapeles del sistema
```

**Objetivo del día**: Automatizar tareas repetitivas con macros y marcas.

---

## Día 10 — Flujo completo: tu día a día

Este es tu workflow real. Abrí tu proyecto y seguí estos pasos:

```vim
" 1. ABRIR EL PROYECTO
cd ~/mi-proyecto && nvim
" O: <space> fp → elegís el proyecto de la lista

" 2. BUSCAR ARCHIVO
<space> ff → nombre del archivo + Enter

" 3. NAVEGAR
gd  → ir a definición
gr  → buscar referencias
Ctrl+o → volver atrás
Ctrl+i → ir adelante

" 4. EDITAR
ciw  → cambiar palabra
ci(  → cambiar dentro de paréntesis
dd   → borrar línea
.    → repetir última acción

" 5. GUARDAR
Ctrl+S

" 6. VER ERRORES
]d   → siguiente error
[ d  → anterior error
<space> xx → ver todos

" 7. GIT
<space> gg  → lazygit
  s → stage, c → commit, p → push, q → salir

" 8. TERMINAL
<space> ft  → terminal flotante
npm run dev → o flutter run, etc.

" 9. TESTS
<space> tt → test más cercano

" 10. CERRAR
:wq  → guardar y cerrar
:qa  → cerrar todo
```

### Resumen de atajos esenciales (imprimí esta tabla)

| Acción | Atajo |
|--------|-------|
| Buscar archivos | `<space> ff` |
| Buscar texto | `<space> sg` |
| Explorador | `<space> e` |
| Terminal | `<space> ft` |
| Guardar | `Ctrl+S` |
| Ir a definición | `gd` |
| Referencias | `gr` |
| Hover | `K` |
| Code action | `<space> ca` |
| Renombrar | `<space> cr` |
| Format | `<space> cf` |
| Git (lazygit) | `<space> gg` |
| Debug start | `<space> dc` |
| Debug breakpoint | `<space> db` |
| Multi-cursor | `Ctrl+D` |
| Mover línea abajo | `Alt+J` |
| Mover línea arriba | `Alt+K` |
| Error siguiente | `]d` |
| Ver errores | `<space> xx` |
| Organizar imports | `<space> co` |
| Which-Key (ayuda) | `<space>` |

---

**Recordá**: Presioná `<space>` en cualquier momento y Which-Key te muestra todos los atajos disponibles.

**¿Duda?**: Abrí Neovim y ejecutá `:Tutor` para el tutorial interactivo de Vim.
