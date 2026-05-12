# 11 - Personalización Avanzada

Este módulo te enseña a personalizar LazyVim según tus necesidades específicas.

---

## 1. Colores y Temas

### 1.1 Colores Disponibles

LazyVim viene con dos temas por defecto:

- **TokyoNight** (oscuro)
- **Catppuccin** (variantes)

### 1.2 Cambiar Colorscheme

```lua
-- ~/.config/nvim/lua/config/options.lua
vim.g.colorscheme = "tokyonight"
```

O en configuración de plugins:

```lua
-- ~/.config/nvim/lua/plugins/colorscheme.lua
return {
  "LazyVim/LazyVim",
  opts = {
    colorscheme = "catppuccin",
  },
}
```

### 1.3 Instalar Más Colores

```lua
-- ~/.config/nvim/lua/plugins/colors.lua
return {
  "ellisonleao/gruvbox.nvim",
  "dracula/vim",
  "sainnorge/gruvbox",
}
```

### 1.4 Configuración de Catppuccin

```lua
-- ~/.config/nvim/lua/plugins/catppuccin.lua
return {
  "catppuccin/nvim",
  name = "catppuccin",
  config = function()
    require("catppuccin").setup({
      flavor = "mocha", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
      },
      colors = {
        overlay0 = "#CDD6F4",
        surface1 = "#313244",
        surface2 = "#45475A",
      },
      integrations = {
        treesitter = true,
        lsp_saga = true,
        navic = true,
        neogit = true,
       dap = true,
      },
    })
  end,
}
```

---

## 2. Opciones de Neovim

### 2.1 Opciones Generales

```lua
-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

-- General
opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.termguicolors = true
opt.showmode = false
opt.cursorline = true
opt.signcolumn = "auto"

-- Búsqueda
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.search highlight = true

-- Indentación
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.autoindent = true
opt.smartindent = true
opt.breakindent = true

-- UI
opt.cmdheight = 1
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.colorcolumn = "80"
opt.wrap = true
opt.linebreak = true
opt.breakpoints = true

-- Splits
opt.splitright = true
opt.splitbelow = true

-- Completition
opt.completeopt = { "menu", "menuone", "noinsert" }
opt.wildmenu = true
opt.wildmode = { "longest:full", "full" }

-- Memoria y Performance
opt.updatetime = 200
opt.timeout = true
opt.timeoutlen = 300
opt.redrawtime = 1500

-- Files
opt.hidden = true
opt.autoread = true
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
```

### 2.2 Opciones de UI

```lua
-- UI más limpia
opt.cmdheight = 0
opt.laststatus = 3
opt.signcolumn = "yes:2"
opt.cursorline = true

-- Ocultar mode en statusline (noice lo maneja)
opt.showmode = false
opt.showcmd = false
```

---

## 3. Keymaps Personalizados

### 3.1 Mejorar Navegación

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Mejorar navegación básica
keymap("n", "n", "nzzzv", { desc = "Next search result" })
keymap("n", "N", "Nzzzv", { desc = "Previous search result" })
keymap("n", "J", "mzJ`z", { desc = "Join lines" })
keymap("n", "K", "mzJ`z", { desc = "Join line below" })

-- Window management
keymap("n", "<leader>sv", "<C-w>v", { desc = "Split vertically" })
keymap("n", "<leader>sh", "<C-w>s", { desc = "Split horizontally" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equal splits" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Un-indent" })
keymap("v", ">", ">gv", { desc = "Indent" })

-- Move text
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })
keymap("v", "p", '"_dP', { desc = "Paste without yank" })

-- Center search results
keymap("n", "n", "nzzzv", { desc = "Next search center" })
keymap("n", "N", "Nzzzv", { desc = "Previous search center" })
```

### 3.2 Atajos de Archivo

```lua
-- Quick save/quit
keymap("n", "<leader>w", ":w<CR>", { desc = "Save", silent = true })
keymap("n", "<leader>q", ":q<CR>", { desc = "Quit", silent = true })
keymap("n", "<leader>Q", ":qa!<CR>", { desc = "Force quit all", silent = true })

-- Quick write
keymap("n", "<leader>W", ":wall<CR>", { desc = "Save all", silent = true })
```

---

## 4. Plugins Personalizados

### 4.1 Agregar Nuevos Plugins

```lua
-- ~/.config/nvim/lua/plugins/nuevo.lua
return {
  "autor/plugin-name",
  event = "VeryLazy",
  config = function()
    require("plugin_name").setup({
      -- configuración
    })
  end,
}
```

### 4.2 Plugins Recomendados Adicionales

```lua
-- ~/.config/nvim/lua/plugins/recommended.lua
return {
  -- Comments mejorados
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gcc", mode = "n" },
      { "gco", mode = "n" },
    },
  },

  -- Editor config
  { "stevearc/editorconfig.nvim", event = "VeryLazy" },

  -- Match pairs
  { "windwp/nvim-autopairs", event = "VeryLazy" },

  -- Color de highlight
  { "NvChad/ui", event = "VeryLazy" },

  -- File explorer mejorado
  { "nvim-neo-tree/neo-tree.nvim", event = "VeryLazy" },
}
```

---

## 5. Eliminar Plugins

### 5.1 Deshabilitar Plugins

```lua
-- ~/.config/nvim/lua/plugins/disable.lua
return {
  -- Disable telescope
  { "nvim-telescope/telescope.nvim", enabled = false },

  -- Disable trouble
  { "folke/trouble.nvim", enabled = false },
}
```

### 5.2 Eliminar Features

```lua
-- Eliminar features específicas
return {
  {
    "neovim/nvim-lspconfig",
    -- Disable algunos servers
    opts_extend = { "servers.*.keys" },
    opts = {
      servers = {
        ts_ls = { enabled = false },
      },
    },
  },
}
```

---

## 6. Configuración de Mason

### 6.1 Lista de Paquetes

```lua
-- ~/.config/nvim/lua/plugins/mason.lua
return {
  "mason-org/mason.nvim",
  opts = {
    ensure_installed = {
      -- LSPs
      "dartls",
      "ts_ls",
      "vtsls",
      "lua_ls",
      "pyright",
      "rust_analyzer",
      "gopls",

      -- Formatters
      "prettier",
      "prettierd",
      "dart_format",
      "stylua",
      "black",
      "shfmt",

      -- Linters
      "eslint",
      "pylint",
      "shellcheck",
    },
  },
}
```

### 6.2 Configuración de UI

```lua
return {
  "mason-org/mason.nvim",
  opts = {
    ui = {
      border = "rounded",
      icon = "✓",
      package = "📦",
    },
  },
}
```

---

## 7. Configuración de LSP

### 7.1 Configuración de Server

```lua
-- ~/.config/nvim/lua/plugins/lsp-custom.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- Agregar servidor
     rust_analyzer = {
        settings = {
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
            },
            checkOnSave = {
              command = "clippy",
            },
          },
        },
      },
    },
  },
}
```

### 7.2 Keymaps de LSP Personalizados

```lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "K", vim.lsp.buf.hover, desc = "Hover" },
        },
      },
    },
  },
}
```

---

## 8. Tema de Iconos

### 8.1 Personalizar Iconos

```lua
-- ~/.config/nvim/lua/plugins/icons.lua
return {
  "LazyVim/LazyVim",
  opts = {
    icons = {
      kind = {
        Text = "󰉢",
        Method = "󰆕",
        Function = "󰊕",
        Constructor = "󰣽",
        Class = "󰠱",
        Interface = "󰵛",
        Module = "󰏗",
        Property = "󰇘",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "󰕳",
        Keyword = "󰌋",
        Snippet = "󰛄",
        File = "󰈙",
        Folder = "󰉋",
      },
      diagnostics = {
        Error = "󰅚",
        Warn = "󰀪",
        Hint = "󰀔",
        Info = "󰋽",
      },
    },
  },
}
```

---

## 9. Configuración de UI

### 9.1 Statusline

```lua
-- ~/.config/nvim/lua/plugins/statusline.lua
return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      theme = "auto",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
  },
}
```

### 9.2 Bufferline

```lua
return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      close_command = "bd",
      diagnostics = "nvim_dap",
      diagnostics_indicator = function(_, _, diag)
        local icons = require("lazyvim.config").icons.diagnostics
        local ret = (diag.error and icons.Error .. diag.error .. " " or "")
          .. (diag.warning and icons.Warn .. diag.warning or "")
        return ret
      end,
    },
  },
}
```

---

## 10. Configuración de Autocmds

### 10.1 Autocmds Personalizados

```lua
-- ~/.config/nvim/lua/config/autocmds.lua
local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Auto-save setup
local autosave = augroup("autosave", { clear = true })

autocmd({ "TextChanged", "InsertLeave" }, {
  group = autosave,
  callback = function()
    if vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Highlight yank
local yank = augroup("yank", { clear = true })
autocmd("TextYankPost", {
  group = yank,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})
```

---

## 11. LazyVim News

### 11.1 Deshabilitar News

```lua
-- ~/.config/nvim/lua/config/options.lua
-- Deshabilitar showing news
vim.g.lazyvim_news = false
```

### 11.2 Configurar News

```lua
return {
  "LazyVim/LazyVim",
  opts = {
    news = {
      lazyvim = true,  -- Show LazyVim news
      neovim = false, -- Hide Neovim news
    },
  },
}
```

---

## 12. Diagnóstico de Personalización

### 12.1 Ver Tiempo de Inicio

```bash
nvim --startuptime startup.log +qa
cat startup.log
```

### 12.2 Ver Carga de Plugins

```vim
:Lazy
```

### 12.3 Ver Configuración

```vim
:lua print(vim.inspect(vim.opt._)))
```

---

## Siguiente Paso

El siguiente módulo cubre los **[comandos útiles](12_comandos.md)**.

---

## Recursos

- [LazyVim Config](https://www.lazyvim.org/configuration)
- [Neovim Options](https://neovim.io/doc/user/options)

---

**Última actualización**: 2026