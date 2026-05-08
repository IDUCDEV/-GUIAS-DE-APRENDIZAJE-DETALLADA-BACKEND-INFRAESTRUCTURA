# 14 - Debugging

Este módulo te enseña a configurar y usar el debugging en LazyVim para Flutter/Dart y TypeScript/Next.js.

---

## 1. DAP (Debug Adapter Protocol)

### 1.1 ¿Qué es DAP?

nvim-dap es el Debug Adapter Protocol para Neovim. Permite debugging con breakpoints, examination de variables, call stack, y más.

### 1.2 Plugins Necesarios

```lua
-- ~/.config/nvim/lua/plugins/dap-core.lua
return {
  "mfussenegger/nvim-dap",
}
```

### 1.3 UI para DAP

```lua
-- ~/.config/nvim/lua/plugins/dap-ui.lua
return {
  "rcarriga/nvim-dap-ui",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
}
```

---

## 2. Debugging para Flutter/Dart

### 2.1 Configuración de DAP para Dart

```lua
-- ~/.config/nvim/lua/plugins/dap-dart.lua
return {
  "mfussenegger/nvim-dap",
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
      {
        type = "dart",
        request = "launch",
        name = "Dart: Run",
        program = "${workspaceFolder}/bin/main.dart",
        cwd = "${workspaceFolder}",
      },
      {
        type = "dart",
        request = "attach",
        name = "Flutter: Attach",
        observatoryDebuggerUri = "http://localhost:4000",
      },
    }
  end,
}
```

### 2.2 Instalar dart debug adapter

```bash
dart pub global activate dart_debug_adapter
```

### 2.3 Commands de Debug Flutter

| Atajo | Función |
|-------|---------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |
| `<leader>dl` | Run Last |
| `<leader>dq` | Stop |

### 2.4 DAP UI Commands

```lua
-- Abrir DAP UI
require("dapui").open()

-- Cerrar DAP UI
require("dapui").close()

-- Toggle DAP UI
require("dapui").toggle()
```

---

## 3. Debugging para TypeScript/Next.js

### 3.1 Configuración DAP para TypeScript

```lua
-- ~/.config/nvim/lua/plugins/dap-ts.lua
return {
  "mfussenegger/nvim-dap",
  config = function()
    local dap = require("dap")
    local debugger = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug"

    -- Verificar que existe
    if vim.fn.isdirectory(debugger) == 0 then
      return
    end

    -- Configurar adapter
    dap.adapters["pwa-node"] = {
      type = "executable",
      command = "node",
      args = { debugger .. "/dist/src/bootstrap.js" },
    }

    -- Configuraciones de debug
    dap.configurations.javascript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug: Current File (Ts-Node)",
        skipFiles = { "<node_internals>/**" },
        runtimeExecutable = "ts-node",
        runtimeArgs = { "--no-warnings", "--input-type", "module", "${file}" },
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
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug: Jest",
        skipFiles = { "<node_internals>/**" },
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
        },
        console = "integratedTerminal",
      },
    }
  end,
}
```

### 3.2 Instalar VSCode JS Debug

El debugger se instala automáticamente con Mason:

```vim
:MasonInstall js-debug
```

O manualmente:

```bash
npm install -g @vscode/debugger
```

### 3.3 Commands de Debug

| Atajo | Función |
|-------|---------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |

### 3.4 Launch Config para Next.js

Crea `.vscode/launch.json`:

```json
{
  "configurations": [
    {
      "type": "node-terminal",
      "name": "Next.js: Dev",
      "request": "launch",
      "command": "npm run dev",
      "console": "integratedTerminal"
    },
    {
      "type": "node-terminal",
      "name": "Next.js: Build",
      "request": "launch",
      "command": "npm run build",
      "console": "integratedTerminal"
    },
    {
      "type": "node-terminal",
      "name": "Next.js: Start",
      "request": "launch",
      "command": "npm run start",
      "console": "integratedTerminal"
    }
  ]
}
```

---

## 4. DAP UI

### 4.1 Configuración de UI

```lua
-- ~/.config/nvim/lua/plugins/dap-ui-config.lua
return {
  "rcarriga/nvim-dap-ui",
  config = function()
    require("dapui").setup({
      icons = { expanded = "▾", collapsed = "▸" },
      mappings = {
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
      },
    })
  end,
}
```

### 4.2 Abrir/Cerrar UI

```vim
:DapUiToggle  " Toggle UI
:DapUiOpen  " Abrir
:DapUiClose " Cerrar
```

### 4.3 Atajos

```lua
-- keymaps
keymap("n", "<leader>du", ":DapUiToggle<CR>", { desc = "Toggle DAP UI" })
keymap("n", "<leader>du", ":DapUiToggle<CR>", { desc = "Toggle DAP UI" })
keymap("v", "<leader>du", ":DapUiToggle<CR>", { desc = "Toggle DAP UI" })
```

---

## 5. Breakpoints

### 5.1 Tipos de Breakpoints

| Atajo | Tipo |
|-------|------|
| `<leader>db` | Regular |
| `<leader>dB` | Conditional |
| `:DapBreakpointFunction <nombre>` | Function |

### 5.2 Breakpoint Commands

```vim
:DapBreakpointRemove 1    " Remove breakpoint 1
:DapBreakpointRemove all " Remove todos
:DapBreakpointToggle    " Toggle
```

### 5.3 Conditional Breakpoint

```lua
-- Crear conditional breakpoint
require("dap").breakpoint({
  condition = "b == 0",
  log_message = "b is 0",
})
```

---

## 6. Inspección de Variables

### 6.1 DAP UI Variables

- **Variables panel**: Muestra variables locales y globals
- **Watches panel**: Muestra expresiones watched
- **Call Stackpanel**: Muestra el call stack

### 6.2 Comandos

```vim
:DapRepl       " Abrir REPL
:DapScopes    " Ver scopes
:DapVariables " Ver variables
```

---

## 7. Advanced Debugging

### 7.1 Debug con Logs

```lua
-- Log points
require("dap").set_log_level("DEBUG")
```

### 7.2 Debug Remote

```dart
// Dart
import 'package:flutter/foundation.dart' as foundation;

foundation.debugPrintStack();
```

### 7.3 Performance Profiling

```dart
// Dart
Stopwatch sw = Stopwatch()..start();
// code to profile
sw.stop();
print(sw.elapsedMicroseconds);
```

---

## 8. Flutter Debug Specific

### 8.1 Flutter DevTools

```bash
flutter pub global activate devtools
devtools
```

### 8.2 Debug Flags

```dart
// main.dart
void main() {
  runApp(MyApp());
}

// Enable debug mode
if (kDebugMode) {
  // debug code
}
```

### 8.3 Hot Reload vs Hot Restart

| Command | Atajo | Función |
|---------|-------|--------|
| Hot Reload | `R` en flutter console | Recarga cambios |
| Hot Restart | `R` en flutter console | Reinicia app |

---

## 9. Troubleshooting

### 9.1 DAP No Funciona

1. Verifica que el debugger está instalado:
```vim
:Mason
```

2. Verifica la configuración:
```vim
:DapShow
```

3. Revisa los logs:
```vim
:DapShowLog
```

### 9.2 Breakpoints No Funcionan

1. Verifica que el archivo está en el workspace correcto
2. Usa el path correcto para el programa

### 9.3 Variables No Se Muestran

Asegúrate de que DAP UI está abierto:
```vim
:DapUiOpen
```

---

## 10. Atajos de Debug

### Quick Reference

| Atajo | Función |
|-------|--------|
| `<leader>dc` | Continue |
| `<leader>db` | Toggle Breakpoint |
| `<leader>dB` | Conditional Breakpoint |
| `<leader>dO` | Step Over |
| `<leader>di` | Step Into |
| `<leader>do` | Step Out |
| `<leader>dl` | Run Last |
| `<leader>dq` | Stop |
| `<leader>dp` | Pause |
| `<leader>dr` | Toggle REPL |
| `<leader>ds` | Session |
| `<leader>da` | Run with Args |
| `<leader>dC` | Run to Cursor |
| `<leader>du` | DAP UI |

---

## Siguiente Paso

El siguiente módulo cubre los **[recursos](15_recursos.md)**.

---

## Recursos

- [nvim-dap](https://github.com/mfussenegger/nvim-dap)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui)
- [dart-debug-adapter](https://github.com/sidlatau/nvim-dart-debug-adapter)

---

**Última actualización**: 2026