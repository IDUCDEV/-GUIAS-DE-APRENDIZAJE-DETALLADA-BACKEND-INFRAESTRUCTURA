# 03 - Instalación Paso a Paso

Esta guía te lleva a través del proceso completo de instalación de LazyVim, desde el backup hasta la verificación.

---

## 1. Backup de Configuración Existente

Antes de instalar LazyVim, haz backup de tu configuración actual de Neovim.

### Directorios a Respaldar

```bash
# Neovim config
mv ~/.config/nvim{,.bak}

# Datos de Neovim (opcional pero recomendado)
mv ~/.local/share/nvim{,.bak}
mv ~/.local/state/nvim{,.bak}
mv ~/.cache/nvim{,.bak}
```

### Verificar el Backup

```bash
ls -la ~/.config/ | grep nvim
# Debe mostrar:
# nvim.bak/
```

### Restaurar Si Es Necesario

```bash
# Si algo sale mal, puedes restaurar:
rm -rf ~/.config/nvim
mv ~/.config/nvim.bak ~/.config/nvim
```

---

## 2. Clonar el Starter Template

### Clonar el Starter de LazyVim

```bash
git clone https://github.com/LazyVim/starter ~/.config/nvim
```

### Verificar la Descarga

```bash
ls -la ~/.config/nvim/
# Debe mostrar archivos como:
# init.lua
# lazy-lock.json
# lua/
```

---

## 3. Eliminar .git

Después de clonar, elimina la carpeta `.git` para poder crear tu propio repositorio.

```bash
rm -rf ~/.config/nvim/.git
```

### Verificar

```bash
ls -la ~/.config/nvim/
# No debe haber .git
```

### (Opcional) Inicializar Nuevo Repo

```bash
cd ~/.config/nvim
git init
git add .
git commit -m "Initial commit: LazyVim base config"
```

---

## 4. Primer Inicio y Bootstrap

### Iniciar Neovim por Primera Vez

```bash
nvim
```

### Qué Ocurre Automáticamente

En el primer inicio, LazyVim automáticamente:

1. **Instala lazy.nvim** (el gestor de plugins)
2. **Descarga la configuración base de LazyVim**
3. **Instala todos los plugins configurados**
4. **Configura el entorno**

Este proceso puede tomar varios minutos dependiendo de tu conexión a internet.

### Output Esperado

Deberías ver algo como:

```
╭──────────────────────────────────────────────────────╮
│ 💤 lazy.nvim                                          │
│                                                      │
│  - Bootstrapping from: folke/lazy.nvim       │
│  - Plugins: 238                                     │
│  - Doing Diff for: ~/.config/nvim                 │
│                                                      │
╰──────────────────────────────────────────────────────╯
```

### No Te Asustes

- Es normal que tarde varios minutos
- Verás actualizaciones de progreso
- No cierres Neovim hasta que termine

---

## 5. Verificación Post-Instalación

### Comando de Salud

Una vez instalado, verifica que todo esté correcto:

```vim
:LazyHealth
```

### Output Esperado

```
✓ health#lazy#startup
  - OK

✓ health#lazy#plugins
  - OK

✓ health#lazy#cache
  - OK

✓ health#lazy#config
  - OK
```

### Problemas Comunes

Si ves errores, consulta la sección de troubleshooting.

---

## 6. Instalar Extras para Tu Stack

LazyVim usa un sistema de **Extras** para configuración específica de lenguajes.

### Método 1: Interactivo

```vim
:LazyExtras
```

Esto abre un menú interactivo donde puedes seleccionar:

- **lang.dart**: Para Flutter/Dart
- **lang.typescript**: Para TypeScript/JavaScript
- **lang.typescript.tsgo**: TypeScript con LSP más rápido
- y muchos más...

Presiona **Enter** sobre el extra que necesitas habilitar.

### Método 2: Programático

Crea un archivo para tus extras:

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  -- Flutter/Dart
  { import = "lazyvim.plugins.extras.lang.dart" },
  
  -- TypeScript/Next.js
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
```

### Método 3: Configuración de init.lua

Edita tu `init.lua` para incluir los extras:

```lua
-- ~/.config/nvim/init.lua

-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Configuración de LazyVim
require("lazy").setup({
  spec = {
    -- LazyVim plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- Tus extras para lenguajes
    { import = "plugins.extras" },

    -- Tus plugins personalizados
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "catppuccin" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

---

## 7. Configurar Herramientas Externas

### Instalar LSPs con Mason

LazyVim incluye Mason para instalar Language Servers:

```vim
:Mason
```

Esto abre un panel con LSPs disponibles. Instala:

#### Para Flutter/Dart

- `dartls` ✓

#### Para TypeScript/JavaScript

- `ts_ls` o `vtsls` ✓
- `eslint` (linter)

#### Para Todos

- `stylua` (Lua formatter)
- `prettier` (general formatter)
- `shfmt` (shell formatter)

### Instalar desde Línea de Comandos

```vim
:MasonInstall dartls
:MasonInstall ts_ls
:MasonInstall eslint
:MasonInstall prettier
```

---

## 8. Reiniciar y Verificar

### Reiniciar Neovim

```vim
:qa
nvim
```

### Verificar que los Plugins Cargan

```vim
:Lazy
```

Deberías ver la lista de plugins instalados.

### Verificar LSP

```vim
:LspInfo
```

Deberías ver los LSPs activos para tus lenguajes.

---

## 9. Troubleshooting

### Los Plugins No Se Instalan

```bash
# Ver errores
nvim --headless +qa

# Forzar sincronización
nvim --headless +Lazy! sync +qa
```

### El LSP No Inicia

```vim
:LspInfo
:MasonInstall <server>
```

### Conflictos de Configuración

```bash
# Ver tiempo de inicio
nvim --startuptime startup.log +qa
cat startup.log
```

### Verificar Versiones

```vim
:version
:lua print(vim.inspect(vim.version()))
```

### Reinstalar from Scratch

```bash
# Backup de tu config personalizada
cp -r ~/.config/nvim/lua/plugins ~/plugins_backup

# Limpiar
rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim

# Reinstalar
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Copiar tu config
cp -r ~/plugins_backup ~/.config/nvim/lua/
```

---

## 10. Personalización Inicial

### Cambiar Colorscheme

LazyVim viene con TokyoNight y Catppuccin. Para cambiarel:

```lua
-- ~/.config/nvim/lua/config/options.lua
vim.g.colorscheme = "catppuccin"
```

O en configuración del plugin:

```lua
-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = "catppuccin",
  },
}
```

### Agregar Tus Propios Atajos

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Mejorar navegación
keymap("n", "n", "nzzzv", { desc = "Next search result" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result" })
```

---

## Siguiente Paso

El siguiente módulo cubre la **[estructura de archivos](04_estructura.md)** de LazyVim.

---

## Recursos

- [LazyVim Instalación](https://www.lazyvim.org/installation)
- [GitHub Starter](https://github.com/LazyVim/starter)
- [LazyExtras](https://www.lazyvim.org/extras)

---

**Última actualización**: 2026