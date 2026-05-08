# 06 - Modes y Conceptos Fundamentales

Neovim usa un sistema de modes que es diferente a los editores tradicionales. Dominar esto es essential para ser productivo.

---

## 1. Modes de Neovim

### 1.1 Modo Normal (`n`)

El modo por defecto. Usado para navegar y ejecutar comandos.

| key | Función |
|-----|---------|
| `i` | Entrar en modo Insert |
| `v` | Entrar en modo Visual |
| `V` | Entrar en modo Visual Line |
| `:` | Entrar en modo Command-Line |

### 1.2 Modo Insert (`i`)

Para insertar texto directamente. Como escribir en un editor normal.

| key | Función |
|-----|---------|
| `Esc` | Volver a Normal |
| `Ctrl+[` | Volver a Normal |

### 1.3 Modo Visual (`v`)

Para seleccionar texto.

| key | Función |
|-----|---------|
| `Esc` | Volver a Normal |
| `c` | Cortar y entrar en Insert |
| `y` | Yanking (copiar) |
| `d` | Eliminar |
| `>` | Indentar |
| `<` | Desindentar |

### 1.4 Modo Visual Line (`V`)

Selecciona líneas completas.

### 1.5 Modo Visual Block (`Ctrl+v`)

Selecciona en modo bloque rectangular.

### 1.6 Modo Command-Line (`:`)

Para ejecutar comandos.

| key | Función |
|-----|---------|
| `Enter` | Ejecutar comando |
| `Esc` | Cancelar |

### 1.7 Modo Terminal (`t`)

Para terminal embebida.

| key | Función |
|-----|---------|
| `Esc` | Volver a Normal |

### 1.8 Modo Replace (`R`)

Reemplaza caracteres al escribir.

---

## 2. Transiciones de Modes

```
Normal → i   : i, a, o, O, I, A, gi, ga
Normal → v   : v, V, Ctrl+v
Normal → :   : :
Normal → t   : Ctrl+t (nueva terminal)
Normal → R   : R, gR
Insert → Esc : Esc, Ctrl+[ (volver a Normal)
Visual → Esc : Esc (volver a Normal)
Terminal → Esc : Esc (volver a Normal)
```

---

## 3. Movimientos Básicos

### 3.1 Movimientos con Teclas

| Comando | Descripción | Equivalente VSCode |
|---------|-------------|-------------------|
| `h` | Izquierda | Flecha izquierda |
| `j` | Abajo | Flecha abajo |
| `k` | Arriba | Flecha arriba |
| `l` | Derecha | Flecha derecha |
| `w` | Inicio de palabra siguiente | Ctrl+Right |
| `b` | Inicio de palabra anterior | Ctrl+Left |
| `e` | Fin de palabra | - |
| `0` | Inicio de línea | Home |
| `$` | Fin de línea | End |

### 3.2 Movimientos de Pantalla

| Comando | Descripción |
|---------|------------|
| `H` | Primera línea visible |
| `M` | Línea media visible |
| `L` | Última línea visible |
| `gg` | Inicio del archivo |
| `G` | Fin del archivo |
| `:123` | Ir a línea 123 |
| `123G` | Ir a línea 123 |

### 3.3 Movimientos por Líneas de Código

| Comando | Descripción |
|---------|------------|
| `{` | Párrafo anterior |
| `}` | Párrafo siguiente |
| `(` | Sentencia anterior |
| `)` | Sentencia siguiente |
| `[[` | Inicio de función anterior |
| `]]` | Inicio de función siguiente |
| `[{` | Inicio de bloque anterior |
| `]}` | Fin de bloque siguiente |

### 3.4 Movimiento con Números

| Comando | Descripción |
|---------|------------|
| `3j` | Abajo 3 líneas |
| `5w` | Adelante 5 palabras |
| `10dd` | Eliminar 10 líneas |
| `3ciw` | Cambio 3 palabras |

---

## 4. Operaciones en Modo Normal

Neovim sigue la sintaxis: **operador + movimiento**.

### 4.1 Operadores

| Operador | Descripción |
|----------|------------|
| `d` | Delete (cortar) |
| `y` | Yank (copiar) |
| `c` | Change (borrar y entrar en insert) |
| `p` | Pegar después |
| `P` | Pegar antes |
| `gU` | Uppercase |
| `g~` | Toggle case |
| `gL` | Lowercase |
| `>` | Indentar |
| `<` | Desindentar |
| `=` | Formatear |
| `!` | Filtrar por comando externo |

### 4.2 Operaciones Comunes

| Comando | Descripción |
|---------|------------|
| `dd` | Eliminar línea completa |
| `dw` | Eliminar palabra |
| `cw` | Cambio palabra |
| `yw` | Yank palabra |
| `ciw` | Cambio inside word |
| `di"` | Delete inside quotes |
| `ci"` | Change inside quotes |
| `yi"` | Yank inside quotes |
| `dap` | Delete around paragraph |
| `yip` | Yank inside paragraph |
| `gUiw` | Uppercase inside word |
| `g~aw` | Toggle case around word |

### 4.3 Operaciones con Movimiento

| Comando | Descripción |
|---------|------------|
| `d$` | Delete hasta fin de línea |
| `d0` | Delete hasta inicio de línea |
| `dfx` | Delete hasta carácter x |
| `dtx` | Delete hasta carácter x (exclusivo) |
| `c$` | Change hasta fin de línea |
| `y$` | Yank hasta fin de línea |

---

## 5. Texto Objetos

Los texto objetos te permiten seleccionar estructuras de código.

### 5.1 Texto Objetos de Paréntesis

| Texto Objeto | Descripción |
|--------------|------------|
| `i(` o `ib` | Inside ( ... ) |
| `a(` o `ab` | Around ( ... ) |
| `i[` | Inside [ ... ] |
| `a[` | Around [ ... ] |
| `i{` | Inside { ... } |
| `a{` | Around { ... } |
| `i<` | Inside < ... > |
| `a<` | Around < ... > |

### 5.2 Texto Objetos de Comillas

| Texto Objeto | Descripción |
|--------------|------------|
| `i"` | Inside "..." |
| `a"` | Around "..." |
| `i'` | Inside '...' |
| `a'` | Around '...' |
| `` i` `` | Inside `...` |
| `` a` `` | Around `...` |

### 5.3 Texto Objetos de Palabras

| Texto Objeto | Descripción |
|--------------|------------|
| `iw` | Inside word |
| `aw` | Around word |
| `iW` | Inside WORD |
| `aW` | Around WORD |

### 5.4 Texto Objetos de Oraciones

| Texto Objeto | Descripción |
|--------------|------------|
| `ip` | Inside paragraph |
| `ap` | Around paragraph |
| `is` | Inside sentence |
| `as` | Around sentence |

---

## 6. Repetidores

### 6.1 Comando Punto

Repite el último comando.

| Comando | Descripción |
|---------|------------|
| `.` | Repetir último comando |
| `;` | Repetir última búsqueda de carácter |
| `,` | Repetir última búsqueda inversa |

### 6.2 Búsquedas

| Comando | Descripción |
|---------|------------|
| `n` | Siguiente match |
| `N` | Match anterior |
| `*` | Buscar palabra bajo cursor (forward) |
| `#` | Buscar palabra bajo cursor (backward) |

---

## 7. Registros

Los registros almacenan texto copiado.

### 7.1 Registros Comunes

| Registro | Descripción |
|-----------|------------|
| `"` | Registro por defecto |
| `0` | Último yank |
| `1` | Último delete |
| `-` | Delete pequeño |
| `.` | Último insert |
| `%` | Nombre del archivo actual |
| `:` | Último comando |

### 7.2 Usar Registros

```vim
" Pegar desde registro
"ap

" Yanked a registro
"ayw

" Ver contenido de registros
:reg
```

### 7.3 Macros

| Comando | Descripción |
|---------|------------|
| `qa` | Iniciar grabación de macro a |
| `q` | Detener grabación |
| `@a` | Reproducir macro a |
| `@@` | Repetir última macro |
| `10@a` | Repetir 10 veces |

---

## 8. Marks (Marcadores)

Los marks guardan posiciones en el archivo.

### 8.1 Marks de Letras

| Comando | Descripción |
|---------|------------|
| `ma` | Set mark a en posición actual |
| `'a` | Ir a mark a |
| `` `a `` | Ir a mark a (posición exacta) |
| `:marks` | Listar marks |

### 8.2 Marks Especiales

| Mark | Descripción |
|------|------------|
| `` ` `` | Última posición antes de un salto |
| `'` | Última posición de línea |
| `"` | Última posición al salir |
| `[` | Inicio de último yanked |
| `]` | Fin de último yanked |
| `<` | Inicio de último Visual |
| `>` | Fin de último Visual |

---

## 9. Jumps (Saltos)

### 9.1 Comandos de Jump

| Comando | Descripción |
|---------|------------|
| `Ctrl+o` | Saltar atrás |
| `Ctrl+i` | Saltar adelante |
| `Ctrl+]` | Ir a definición |
| `Ctrl+t` | Volver de definición |

### 9.2 Jump List

```vim
: jumps
```

---

## 10. Buffers y Ventanas

### 10.1 Buffers

| Comando | Descripción |
|---------|------------|
| `:bnext` o `]b` | Buffer siguiente |
| `:bprevious` o `[b` | Buffer anterior |
| `:bd` | Eliminar buffer |
| `:buffer N` | Ir a buffer N |

### 10.2 Ventanas

| Comando | Descripción |
|---------|------------|
| `:sp` | Split horizontal |
| `:vsp` | Split vertical |
| `:vs` | Split vertical |
| `:new` | Nueva ventana |
| `:vnew` | Nueva ventana vertical |

### 10.3 Movimiento entre Ventanas

| Comando | Descripción |
|---------|------------|
| `Ctrl+w h` | Ventana izquierda |
| `Ctrl+w j` | Ventana abajo |
| `Ctrl+w k` | Ventana arriba |
| `Ctrl+w l` | Ventana derecha |
| `Ctrl+w w` | Siguiente ventana |
| `Ctrl+w q` | Cerrar ventana |
| `Ctrl+w o` | Cerrar otras ventanas |

---

## 11. Pegar (Paste)

### 11.1 Comandos de Pegar

| Comando | Descripción |
|---------|------------|
| `p` | Pegar después del cursor |
| `P` | Pegar antes delcursor |
| `gp` | Pegar y mover cursor |
| `gP` | Pegar antes y mover cursor |

### 11.2 Pegar sin Yanked

```vim
" Pegar sin sobrescribir el registro
:put = "texto"
```

---

## 12. Búsqueda y Reemplazo

### 12.1 Búsqueda

| Comando | Descripción |
|---------|------------|
| `/patron` | Buscar forward |
| `?patron` | Buscar backward |
| `n` | Siguiente match |
| `N` | Match anterior |

### 12.2 Reemplazar

| Comando | Descripción |
|---------|------------|
| `:s/old/new` | Reemplazar en línea |
| `:s/old/new/g` | Reemplazar todos en línea |
| `:%s/old/new/g` | Reemplazar en archivo |
| `:%s/old/new/gc` | Con confirmación |

### 12.3 Reemplazo en Selección

```vim
" En modo Visual
:'<,'>s/old/new/g
```

---

## 13. Fórmulas para Dominar Modes

###练习 Ejercicios

1. **Move without arrows**: Usa `hjkly` en lugar de flechas
2. **Use texto objects**: Usa `ci"` en lugar de buscar manualmente
3. **Use counts**: Usa `3dd` en lugar de `dd;dd;dd`
4. **Practice dot command**: Usa `.` para repetir

### Ejercicios Diarios

| Ejercicio | Descripción |
|---------|------------|
| Navegar sin flechas | Usar `hjkly` por defecto |
| Buscar archivos | Usar `ff` en lugar de |
| Y usar texto objects | Usar `ciw`, `ca(`, etc. |
| Usar macros | Grabar y reproducir |

---

## Siguiente Paso

El siguiente módulo cubre los **[keymaps esenciales](07_keymaps.md)** con comparación VSCode → LazyVim.

---

## Recursos

- [Vim Modes Tutorial](https://vimhelp.org/intro.txt.html)
- [Vim Text Objects](https://vimhelp.org/change.txt.html)

---

**Última actualización**: 2026