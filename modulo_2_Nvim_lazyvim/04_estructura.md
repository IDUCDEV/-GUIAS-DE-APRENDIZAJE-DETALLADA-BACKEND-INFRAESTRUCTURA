# 04 - Estructura de Archivos

Entender laestructura de archivos de LazyVim es esencial para personalizar tu configuración. Este módulo te enseña todo lo que necesitas saber.

---

## 1. Árbol General de Directorios

```
~/.config/nvim/
├── init.lua                    # Punto de entrada principal
├── lazy-lock.json            # Lock file de plugins (no editar)
├── lazycache.json           # Cache de plugins
├── README.md              # Tu readme (opcional)
├── lua/
│   ├── config/           # Configuración del usuario
│   │   ├── options.lua   # Opciones de Neovim
│   │   ├── keymaps.lua   # Atajos de teclado
│   │   ├── autocmds.lua # Comandos automáticos
│   │   └── lazy.lua     # Config de lazy.nvim (opcional)
│   ├── plugins/          # Plugins del usuario
│   │   ├── extras.lua   # Extras de lenguajes
│   │   ├── tools.lua   # Herramientas adicionales
│   │   └── ...
│   └── lazyvim/        # Configuración de LazyVim (no editar)
│       └── ...
└── plugin/
    └── plugins.json
```

---

## 2. Archivos de Configuración

### init.lua

Es el punto de entrada principal. No necesitas editarlo si solo quieres agregar plugins o configurar opciones.

```lua
-- ~/.config/nvim/init.lua
-- Bootstrapping lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- ... (el resto se configura automáticamente)
```

### lua/config/options.lua

Opciones de Neovim. Se carga antes de lazy.nvim.

```lua
-- ~/.config/nvim/lua/config/options.lua
-- Opciones básicos
vim.opt.number = true         -- Números de línea
vim.opt.relativenumber = true -- Números relativos
vim.opt.mouse = "a"        -- Soporte de mouse
vim.opt.clipboard = "unnamedplus" -- Clipboard del sistema
```

### lua/config/keymaps.lua

Atajos de teclado personalizados. Se carga en el evento VeryLazy.

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Buscar archivos
keymap("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })
```

### lua/config/autocmds.lua

Comandos automáticos. Se carga en el evento VeryLazy.

```lua
-- ~/.config/nvim/lua/config/autocmds.lua
-- Resaltar texto al hacer yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
```

---

## 3. Sistema de Plugins

### lua/plugins/

Cada archivo en `lua/plugins/` se carga automáticamente. Puedes tener múltiples archivos.

```lua
-- ~/.config/nvim/lua/plugins/mis-plugins.lua
return {
  "autor/nombre-del-plugin",
  -- opciones...
}
```

### Estructura de un Spec

```lua
return {
  -- Obligatorio: autor/plugin
  "autor/nombre-del-plugin",

  -- Opcional: evento que carga el plugin
  -- event = "VeryLazy",
  -- event = { "BufReadPre", "BufNewFile" },
  -- event = "InsertEnter",

  -- Opcional: prioridad (mayor = carga primero)
  -- priority = 100,

  -- Opcional: filetype específico
  -- ft = { "dart", "typescript" },

  -- Opcional: dependencias
  -- dependencies = { "otro/plugin" },

  -- Opcional: opciones del plugin
  -- opts = { ... },

  -- Opcional: configuración
  -- config = function() ... end,

  -- Opcional: keys (keymaps del plugin)
  -- keys = { ... },
}
```

---

## 4. Override de Configuración de LazyVim

### Método 1: crear spec equivalente

```lua
-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = "catppuccin",
  },
}
```

### Método 2: usar opts_extend

```lua
-- ~/.config/nvim/lua/plugins/settings.lua
return {
  "neovim/nvim-lspconfig",
  opts_extend = { "servers.*.keys" },
  opts = {
    -- Configuración adicional
  },
}
```

### Método 3: usar config function

```lua
-- ~/.config/nvim/lua/plugins/config.lua
return {
  "plugin/externo",
  config = function()
    require("plugin").setup({
      -- configuración
    })
  end,
}
```

---

## 5. Orden de Carga

### Orden de Carga de Archivos

1. **init.lua** - Primero
2. **lua/config/options.lua** - Antes de lazy.nvim
3. **lua/config/lazy.lua** - Durante setup de lazy.nvim
4. **lua/plugins/*.lua** - Después de plugins de LazyVim
5. **lua/config/keymaps.lua** - Evento VeryLazy
6. **lua/config/autocmds.lua** - Evento VeryLazy

### Orden de Carga de Plugins

Por defecto:

1. **LazyVim/LazyVim** - Primero (configuración base)
2. Tus plugins en **lua/plugins/** - Después

Puedes cambiar el orden con `priority`:

```lua
return {
  "plugin/importante",
  priority = 1000, -- Se carga antes (mayor número = primero)
}
```

---

## 6. Ejemplos Prácticos

### Ejemplo 1: Agregar un Plugin Simple

```lua
-- ~/.config/nvim/lua/plugins/telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
}
```

### Ejemplo 2: Agregar un Plugin con Configuración

```lua
-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  event = "VeryLazy",
  config = function()
    require("catppuccin").setup({
      flavor = "mocha",
      transparent_background = false,
    })
  end,
}
```

### Ejemplo 3: Modificar Configuración de LazyVim

```lua
-- ~/.config/nvim/lua/plugins/lsp-config.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Agregar dartls
      dartls = {},
      -- Configurar ts_ls
      ts_ls = {
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
            },
          },
        },
      },
    },
  },
}
```

### Ejemplo 4: Deshabilitar un Plugin de LazyVim

```lua
-- ~/.config/nvim/lua/plugins/no-telescope.lua
return {
  "nvim-telescope/telescope.nvim",
  enabled = false,
}
```

### Ejemplo 5: Extender con Extras

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.lang.dart" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
```

---

## 7. Variables de Configuración

### Variables Globales Útiles

```lua
-- Ruta de configuración
vim.fn.stdpath("config")  -- ~/.config/nvim
vim.fn.stdpath("data")  -- ~/.local/share/nvim
vim.fn.stdpath("state") -- ~/.local/state/nvim
vim.fn.stdpath("cache") -- ~/.cache/nvim

-- Directorio de plugins
vim.fn.stdpath("data") .. "/lazy"

-- Info de Neovim
vim.version()
vim.version().major
vim.version().minor
```

---

## 8. No Editar

### Archivos que NO Debes Editar (son sobreescritos)

- `lazy-lock.json` - Se genera automáticamente
- Archivos en `lua/lazyvim/` - Parte de LazyVim

### Para Personalización, Usa

Tu propio directorio `lua/config/` y `lua/plugins/`

---

## 9. Herramientas de Diagnóstico

### Ver Estructura de Carga

```vim
:lua Print(vim.inspect(vim.opt.rtp:get()))
```

### Ver Plugins Activos

```vim
:Lazy
```

### Ver Configuración Cargada

```vim
:lua Print(vim.deepcopy(require("lazy.core.config").plugins))
```

### Tiempo de Inicio

```bash
nvim --startuptime startup.log +qa
cat startup.log
```

---

## Siguiente Paso

El siguiente módulo cubre los **[plugins incluidos](05_plugins.md)** en LazyVim.

---

## Recursos

- [LazyVim Config](https://www.lazyvim.org/configuration)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [Plugin Spec](https://github.com/folke/lazy.nvim?tab=readme-ov-file#plugin-spec)

---

**Última actualización**: 2026