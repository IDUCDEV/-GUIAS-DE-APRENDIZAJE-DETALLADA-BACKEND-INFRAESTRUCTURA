# 09 - Configuración para TypeScript/Next.js

Este módulo te enseña a configurar LazyVim específicamente para desarrollo con TypeScript, JavaScript y Next.js.

---

## 1. Habilitar Extra de TypeScript

LazyVim incluye soporte oficial para TypeScript a través del sistema de extras.

### Método 1: Interactivo

```vim
:LazyExtras
```

Busca y selecciona:

- **lang.typescript**: TypeScript/JavaScript estándar
- **lang.typescript.tsgo**: TypeScript con LSP más moderno (tsgo)

### Método 2: Programático

Crea el archivo de extras:

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
```

O usa tsgo (más rápido):

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.lang.typescript.tsgo" },
}
```

---

## 2. Elegir entre vtsls y tsgo

LazyVim usa **vtsls** por defecto, pero puedes usar **tsgo** (más rápido):

### vtsls

- LSP estándar para TypeScript
- Incluye toda la funcionalidad de TypeScript Language Server

### tsgo

- Nueva implementación más rápida
- Mejor rendimiento en proyectos grandes
- Configuración experimental

### Configurar

```lua
-- ~/.config/nvim/lua/config/options.lua
-- Usar tsgo (más rápido)
vim.g.lazyvim_ts_lsp = "tsgo"

-- O usar vtsls (estándar)
vim.g.lazyvim_ts_lsp = "vtsls"
```

---

## 3. Qué Incluye el Extra de TypeScript

El extra de TypeScript incluye:

### 3.1 LSP (ts_ls / vtsls / tsgo)

```lua
{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      vtsls = {
        enabled = true,
        settings = {
          -- configuración
        },
      },
    },
  },
}
```

### 3.2 TreeSitter

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "typescript", "javascript", "tsx", "jsx" },
  },
}
```

### 3.3 Conform (Formatter)

```lua
{
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
    },
  },
}
```

### 3.4 DAP (Debugger)

```lua
{
  "mfussenegger/nvim-dap",
  -- Configuración de debugging
}
```

---

## 4. Instalar Dependencias

### 4.1 Instalar LSP con Mason

```vim
:MasonInstall ts_ls
```

O para tsgo:

```vim
:MasonInstall tsgo
```

### 4.2 Verificar Instalación

```vim
:LspInfo
```

Deberías ver el LSP activo cuando abras un archivo `.ts` o `.js`.

### 4.3 Instalar Prettier

```vim
:MasonInstall prettier
```

---

## 5. Configuración de LSP

### 5.1 Configuración de TypeScript

```lua
-- ~/.config/nvim/lua/plugins/typescript-config.lua
return {
  "neovim/nvim-lspconfig",
  opts = function()
    local lsp = vim.g.lazyvim_ts_lsp or "vtsls"
    return {
      servers = {
        [lsp] = {
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
              updateImportsOnFileMove = { enabled = "always" },
              completeFunctionCalls = true,
              suggest = {
                completeFunctionCalls = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
              updateImportsOnFileMove = { enabled = "always" },
              completeFunctionCalls = true,
            },
          },
        },
      },
    }
  end,
}
```

### 5.2 Inlay Hints

Los inlay hints muestran información de tipos directamente en el código:

```lua
-- ~/.config/nvim/lua/config/options.lua
-- Habilitar inlay hints
vim.lsp.inlay_hint.enable(true)
```

---

## 6. Configuración de Prettier

### 6.1 Configuración de Base

LazyVim incluye conform.nvim que usa Prettier automáticamente para TypeScript/JavaScript.

### 6.2 Personalizar Prettier

```lua
-- ~/.config/nvim/lua/plugins/prettier.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      prettier = {
        command = "prettier",
        args = {
          "--stdin-filepath",
          "$FILENAME",
          "--single-quote",
          "--trailing-comma",
          "all",
          "--tab-width",
          "2",
        },
      },
    },
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      json = { "prettier" },
      css = { "prettier" },
      scss = { "prettier" },
      html = { "prettier" },
      vue = { "prettier" },
      markdown = { "prettier" },
    },
  },
}
```

### 6.3 Configuración de Proyecto

Crea `.prettierrc` en la raíz de tu proyecto:

```json
{
  "semi": true,
  "singleQuote": true,
  "trailingComma": "all",
  "tabWidth": 2,
  "printWidth": 80
}
```

---

## 7. Configuración de ESLint

### 7.1 Instalar ESLint

```vim
:MasonInstall eslint
```

### 7.2 Configuración de ESLint

```lua
-- ~/.config/nvim/lua/plugins/eslint.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {
        settings = {
          workingDirectories = { mode = "auto" },
          format = {
            enable = true,
          },
        },
      },
    },
  },
}
```

---

## 8. Next.js Específico

### 8.1 Configuración para Next.js

```lua
-- ~/.config/nvim/lua/plugins/nextjs.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["typescript-language-server"] = {
        root_dir = require("lspconfig").util.root_pattern("package.json", "tsconfig.json", "next.config.js", "next.config.ts", ".git"),
      },
      tailwindcss = {
        root_dir = require("lspconfig").util.root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js", ".git"),
      },
    },
  },
}
```

### 8.2 Instalar Herramientas Next.js

```bash
cd mi-proyecto-nextjs
npm install
npm install -D @tailwindcss/typography
```

---

## 9. Debugging TypeScript

### 9.1 Configuración DAP

El extra de TypeScript incluye configuración de DAP. Para usarla:

1. Instala Chrome/Edge Remote Debugging Extension
2. Instala la extensión nvim-dap:

```lua
-- ~/.config/nvim/lua/plugins/dap-typescript.lua
return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")

    -- Configuración de JavaScript/TypeScript
    dap.adapters["pwa-node"] = {
      type = "executable",
      command = "node",
      args = { vim.fn.stdpath("data") .. "/lazy/vscode-js-debug/dist/src/bootstrap.js" },
    }

    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug: Current File (Ts-Node)",
        skipFiles = { "<node_internals>/**" },
        runtimeExecutable = "ts-node",
        runtimeArgs = { "--no-warnings", "--inspect", "--input-type", "module", "${file}" },
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug: Next.js",
        runtimeExecutable = "npm",
        runtimeArgs = { "run", "dev" },
        console = "integratedTerminal",
        serverReadyAction = {
          action = "openInBrowser",
          pattern = "started server on",
          urlFilter = "http://localhost:*",
        },
      },
    }
  end,
}
```

### 9.2 Atajos de Debug

| Atajo | Función |
|-------|---------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |
| `<leader>dq` | Stop |

### 9.3 Launch Config para Next.js

Crea `.vscode/launch.json` en tu proyecto:

```json
{
  "configurations": [
    {
      "type": "node-terminal",
      "name": "Next.js: Dev",
      "request": "launch",
      "command": "npm run dev",
      "console": "integratedTerminal"
    }
  ]
}
```

---

## 10. Atajos LSP para TypeScript

### 10.1 Atajos Estándar

| Atajo | Función |
|-------|---------|
| `gd` | Go to Definition |
| `gI` | Go to Implementation |
| `gr` | Find References |
| `K` | Hover |
| `<leader>ca` | Code Action |
| `<leader>cr` | Rename |

### 10.2 Atajos Personalizados

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- TypeScript specific
keymap("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, { desc = "Organize Imports", silent = true })

keymap("n", "<leader>cO", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.fixAll" },
      diagnostics = {},
    },
  })
end, { desc = "Fix All", silent = true })
```

---

## 11. Snippets para TypeScript

### 11.1 Snippets Include

LazyVim incluye snippets básicos para TypeScript y React.

### 11.2 Snippets Útiles

```json
{
  "React Functional Component": {
    "prefix": "rfc",
    "body": [
      "import React from 'react'",
      "",
      "interface ${1:Component}Props {",
      "  $2",
      "}",
      "",
      "export const ${1:Component}: React.FC<${1:Component}Props> = ({ $3 }) => {",
      "  return ($4)",
      "}",
    ]
  },
  "useState": {
    "prefix": "us",
    "body": [
      "const [$1, set${1/(.*)/${1:/}] = useState<$2>($3)",
      "$0"
    ],
    "description": "useState hook"
  },
  "useEffect": {
    "prefix": "ue",
    "body": [
      "useEffect(() => {",
      "  $1",
      "}, [$2])$0"
    ],
    "description": "useEffect hook"
  }
}
```

---

## 12. Problemas Comunes

### 12.1 Autocomplete No Funciona

1. Verifica que blink.cmp esté instalado
2. Asegúrate de tener las capabilities configuradas
3. Revisa `:LspInfo`

### 12.2 LSP No Inicia

1. Verifica que el archivo esté en el workspace correcto
2. Ejecuta `:LspInfo` para ver el estado
3. Revisa que el servidor esté instalado con `:Mason`

### 12.3 Errors No Se Muestran

1. Ejecuta `:lua vim.lsp.start_client()` para iniciar manualmente
2. Revisa los logs con `:LspLog`

### 12.4 No Encuentra el Módulo

1. Verifica que `tsconfig.json` existe
2. Ejecuta `npm install` en el proyecto
3. Revisa la configuración de `moduleResolution`

---

## Siguiente Paso

El siguiente módulo cubre la **[integración con Supabase](10_supabase.md)**.

---

## Recursos

- [Lang.typescript Extra](https://www.lazyvim.org/extras/lang/typescript)
- [tsgo](https://github.com/gveda/tsgo)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap)

---

**Última actualización**: 2026