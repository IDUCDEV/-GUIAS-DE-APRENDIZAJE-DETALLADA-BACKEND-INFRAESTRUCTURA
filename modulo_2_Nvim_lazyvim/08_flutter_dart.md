# 08 - Configuración para Flutter/Dart

Este módulo te enseña a configurar LazyVim específicamente para desarrollo Flutter y Dart.

---

## 1. Habilitar Extra de Dart

LazyVim incluye soporte oficial para Dart a través del sistema de extras.

### Método 1: Interactivo

```vim
:LazyExtras
```

Busca y selecciona **lang.dart**.

### Método 2: Programático

Crea el archivo de extras:

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.lang.dart" },
}
```

Y agrégalo a tu configuración:

```lua
-- ~/.config/nvim/init.lua
-- ...
{ import = "plugins.extras" },
-- ...
```

---

## 2. Qué Incluye el Extra de Dart

El extra de Dart incluye:

### 2.1 LSP (dartls)

```lua
{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      dartls = {},
    },
  },
}
```

### 2.2 TreeSitter

```lua
{
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = { "dart" },
  },
}
```

### 2.3 Conform (Formatter)

```lua
{
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      dart = { "dart_format" },
    },
  },
}
```

---

## 3. Instalar Dependencies

### 3.1 Instalar Dart LSP con Mason

```vim
:MasonInstall dartls
```

### 3.2 Verificar Instalación

```vim
:LspInfo
```

Deberías ver `dartls` activo cuando abras un archivo `.dart`.

### 3.3 Instalar Más Herramientas

```vim
:MasonInstall dart_format
:MasonInstall flutter
```

---

## 4. Flutter Tools (Opcional)

Para una experiencia más completa (similar a VSCode), puedes agregar **flutter-tools.nvim**.

### Instalación

```lua
-- ~/.config/nvim/lua/plugins/flutter-tools.lua
return {
  "akinsho/flutter-tools.nvim",
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("flutter_tools").setup({
      debugger = {
        enabled = true,
        run_via_dap = true,
      },
      widget_restarts = {
        enabled = true,
      },
      dev_log = {
        enabled = true,
        open_cmd = "tabedit",
      },
      decorations = {
        statusline = {
          enabled = true,
        },
      },
    })
  end,
}
```

### Características de Flutter Tools

- **Hot reload** automático
- **Flutter commands** en Neovim
- **Decorations** en statusline
- **Debugging** con DAP

---

## 5. Comandos de Flutter

### 5.1 Comandos Principales

```vim
" Correr aplicación Flutter
:FlutterRun

" Reiniciar Flutter
:FlutterRestart

" Hot reload
:FlutterHotReload

" Detener aplicación
:FlutterQuit

" Ver logs
:FlutterLog

" Doctor
:FlutterDoctor

" Test
:FlutterTest

" Build
:FlutterBuild
```

### 5.2 Atajos de Teclado

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Flutter
keymap("n", "<leader>fr", ":FlutterRun<CR>", { desc = "Flutter Run", silent = true })
keymap("n", "<leader>fR", ":FlutterRestart<CR>", { desc = "Flutter Restart", silent = true })
keymap("n", "<leader>fq", ":FlutterQuit<CR>", { desc = "Flutter Quit", silent = true })
keymap("n", "<leader>fl", ":FlutterLog<CR>", { desc = "Flutter Log", silent = true })
keymap("n", "<leader>fc", ":FlutterHotReload<CR>", { desc = "Flutter Hot Reload", silent = true })
keymap("n", "<leader>fD", ":FlutterDoctor<CR>", { desc = "Flutter Doctor", silent = true })
keymap("n", "<leader>ft", ":FlutterTest<CR>", { desc = "Flutter Test", silent = true })
```

---

## 6. Testing con Dart

### 6.1 Neotest

Para ejecutar tests, puedes usar **neotest** con el adapter de Dart:

```lua
-- ~/.config/nvim/lua/plugins/neotest-dart.lua
return {
  "nvim-neotest/neotest",
  optional = true,
  dependencies = {
    "sidlatau/neotest-dart",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        ["neotest-dart"] = {
          command = "flutter test",
        },
      },
    })
  end,
}
```

### 6.2 Comandos de Test

```vim
" Correr todos los tests
:Neotest run

" Tests en archivo actual
:Neotest file

" Test más cercano
:Neotest nearest

" Debug test
:Neotest debug

" Summary
:Neotest summary
```

### 6.3 Atajos de Test

```lua
keymap("n", "<leader>tt", ":Neotest run<CR>", { desc = "Run all tests", silent = true })
keymap("n", "<leader>tf", ":Neotest file<CR>", { desc = "Run file tests", silent = true })
keymap("n", "<leader>tn", ":Neotest nearest<CR>", { desc = "Run nearest test", silent = true })
keymap("n", "<leader>ts", ":Neotest summary toggle<CR>", { desc = "Toggle test summary", silent = true })
```

---

## 7. Debugging Flutter

### 7.1 Configuración DAP

```lua
-- ~/.config/nvim/lua/plugins/dap-flutter.lua
return {
  "mfussenegger/nvim-dap",
  optional = true,
  dependencies = {
    "sidlatau/nvim-dart-debug-adapter",
  },
  config = function()
    local dap = require("dap")

    dap.adapters.dart = {
      type = "executable",
      command = "dart",
      args = { "debug_adapter" },
    }

    dap.configurations.dart = {
      {
        type = "dart",
        request = "launch",
        name = "Flutter: Run",
        program = "${workspaceFolder}/lib/main.dart",
        cwd = "${workspaceFolder}",
        preLaunchTask = "Flutter: Boot",
      },
    }
  end,
}
```

### 7.2 Atajos de Debug

| Atajo | Función |
|-------|---------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |
| `<leader>dq` | Stop |

---

## 8. Configuración LSP Avanzada

### 8.1 Configuración de Dart LS

```lua
-- ~/.config/nvim/lua/plugins/dart-lsp.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      dartls = {
        settings = {
          dart = {
            completeFunctionCalls = true,
            showTodos = true,
            analysisExcludedFolders = {
              ".dart_tool",
              "build",
              ".git",
            },
          },
        },
      },
    },
  },
}
```

### 8.2 Habilitar Dart LS manualmente

Si el LSP no inicia automáticamente:

```lua
-- ~/.config/nvim/lua/config/options.lua
vim.lsp.enable("dartls")
```

---

## 9. Atajos LSP para Dart

### 9.1 Atajos Estándar

| Atajo | Función |
|-------|---------|
| `gd` | Go to Definition |
| `gI` | Go to Implementation |
| `gr` | Find References |
| `K` | Hover |
| `<leader>ca` | Code Action |
| `<leader>cr` | Rename |

### 9.2 Atajos Personalizados

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
local keymap = vim.keymap.set

-- Dart specific
keymap("n", "<leader>co", function()
  vim.lsp.buf.code_action({
    apply = true,
    context = {
      only = { "source.organizeImports" },
      diagnostics = {},
    },
  })
end, { desc = "Organize Imports", silent = true })

keymap("n", "<leader>cO", "<cmd>FlutterReload<CR>", { desc = "Flutter Reload", silent = true })
keymap("n", "<leader>cf", "<cmd>FlutterHotReload<CR>", { desc = "Flutter Hot Reload", silent = true })
keymap("n", "<leader>cd", "<cmd>FlutterDoctor<CR>", { desc = "Flutter Doctor", silent = true })
```

---

## 10. Snippets para Dart

### 10.1 Snippets Include

LazyVim incluye snippets básicos para Dart. Puedes agregar más con **vsnip** o **LSP Snippets**.

### 10.2 Snippets Comunes

```json
{
  "stateless widget": {
    "prefix": "stless",
    "body": [
      "class ${1:Name} extends StatelessWidget {",
      "  @override",
      "  Widget build(BuildContext context) {",
      "    return ${2:Container()},\n  }",
      "}"
    ]
  },
  "stateful widget": {
    "prefix": "stful",
    "body": [
      "class ${1:Name} extends StatefulWidget {",
      "  @override",
      "  State<${1:Name}> createState() => _${1:Name}State();",
      "}",
      "",
      "class _${1:Name}State extends State<${1:Name}> {",
      "  @override",
      "  Widget build(BuildContext context) {",
      "    return ${2:Container()},\n  }",
      "}"
    ]
  },
  "build method": {
    "prefix": "build",
    "body": [
      "@override",
      "Widget build(BuildContext context) {",
      "  return ${1:Container()},\n}",
    ]
  }
}
```

---

## 11. Configuración de Formateo

### 11.1 Formateo Automático

El extra de Dart incluye configurado con `dart_format`. Para formatear:

```vim
:lua require("conform").format()
```

O con el atajo:

```lua
keymap("n", "<leader>cf", ":lua require('conform').format()<CR>", { desc = "Format", silent = true })
```

### 11.2 Configuración de Conform

```lua
-- ~/.config/nvim/lua/plugins/conform-dart.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters = {
      dart_format = {
        command = "dart",
        args = { "format", "--line-length", "120" },
      },
    },
    formatters_by_ft = {
      dart = { "dart_format" },
    },
  },
}
```

---

## 12. Solución de Problemas

### 12.1 Dart LSP No Inicia

```vim
" Verificar estado
:LspInfo

" Habilitar manualmente
:lua vim.lsp.enable("dartls")
```

### 12.2 Análisis No Funciona

```bash
" Verificar que Flutter está en PATH
flutter --version

" Análisis manual
flutter analyze
```

### 12.3 Errores de Configuración

```bash
" Verificar logs
:LspLog

" Limpiar cache de Dart
rm -rf .dart_tool
flutter pub get
```

---

## Siguiente Paso

El siguiente módulo cubre la **[configuración para TypeScript/Next.js](09_typescript.md)**.

---

## Recursos

- [Lang.dart Extra](https://www.lazyvim.org/extras/lang/dart)
- [flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim)
- [neotest-dart](https://github.com/sidlatau/neotest-dart)

---

**Última actualización**: 2026