# 01 - Introducción a LazyVim

## ¿Por Qué LazyVim?

**LazyVim** es una distribución (distro) de Neovim pre-configurada creada por Folke (el mismo autor de lazy.nvim). Transforma Neovim en un IDE completo sin necesidad de configurar todo desde cero.

### Filosofía

LazyVim ofrece el equilibrio perfecto entre:

- **Configuración Zero**: Funciona out-of-the-box
- **Personalización**: Fácil de extender y modificar
- **Comunidad**:Gran ecosistema de plugins y extras

---

## Comparación: VSCode/Ant gravity vs LazyVim

### Interfaz de Usuario

| Aspecto | VSCode/Ant Gravity | LazyVim |
|---------|------------------|---------|
| Explorador de archivos | Panel lateral | neo-tree o snacks explorer |
| Buscar archivos | `Ctrl+P` | `<leader>ff` |
| Buscar en archivos | `Ctrl+Shift+F` | `<leader>sg` |
| Terminal | Panel inferior | `<leader>ft` |
| Git | Integración visual | lazygit + gitsigns |
| Autocomplete | IntelliSense | Blink.cmp |
| Debugging | VSCode Debugger | nvim-dap |
| Extensiones | Marketplace | lazy.nvim |

### Flujo de Trabajo

| Tarea | VSCode | LazyVim |
|-------|-------|--------|
| Abrir archivo | Click o Ctrl+P | `<leader>ff` |
| Buscar texto | Ctrl+Shift+F | `<leader>sg` |
| Abrir terminal | Ctrl+` | `<leader>ft` |
| Ver errores | Panel problems | `<leader>xx` |
| Formatear | Ctrl+Shift+I | `<leader>cf` |
| Rename | F2 | `<leader>cr` |

---

## Diferencias Conceptuales Clave

### 1. Todo Es Texto

En Neovim/Vim, todo es manipulación de texto. No hay mouse requerido para la mayoría de tareas.

### 2. Modes

Neovim tiene múltiples modos (normal, insert, visual, command-line, etc.). Esto puede parecer estranho al principio, pero una vez que lo dominas, es extremadamente rápido.

### 3. Filosofía "Keystrokes as Unix"

Cada keystroke cuenta. Los atajos de teclado están diseñados para minimizar el movimiento de dedos.

### 4. Editing Modal

En lugar de usar el mouse para seleccionar, usas modos. Por ejemplo, `ciw` (change inside word) es más rápido que seleccionar y escribir.

---

## LazyVim y Tu Stack

### Flutter/Dart

- **dartls**: LSP para Dart/Flutter
- **nvim-treesitter**: Syntax highlighting para Dart
- **flutter-tools.nvim**: Herramientas de Flutter (opcional)
- **neotest-dart**: Testing para Dart

### TypeScript/Next.js

- **vtsls/tsgo**: LSP para TypeScript
- **nvim-treesitter**: Syntax highlighting para TS/JS
- **conform.nvim**: Formateo con Prettier
- **nvim-dap**: Debugging para JavaScript

### Supabase

- **supabase-nvim**: Integración con CLI de Supabase
- **sql**: Soporte para queries SQL

---

## ¿Qué_ofrece LazyVim?

### Features Incluidos

- ✅ Autocomplete (Blink.cmp)
- ✅ LSP (nvim-lspconfig + Mason)
- ✅ Syntax Highlighting (TreeSitter)
- ✅ Fuzzy Finding (snacks/telescope/fzf-lua)
- ✅ Git Integration (gitsigns + lazygit)
- ✅ Terminal Embebido
- ✅ Debugging (nvim-dap)
- ✅ UI Enhancements (statusline, bufferline)
- ✅ Session Management (persistence)

### Extras Disponibles

- 🌐 **lang.typescript**: TypeScript/JavaScript
- 🎯 **lang.dart**: Dart/Flutter
- 🐍 **lang.python**: Python
- 🦀 **lang.rust**: Rust
- 🔷 **lang.go**: Go
- 🧪 **dap.core**: Debugging
- 🤖 **ai.copilot-chat**: Copilot integration
- 📦 Y muchos más...

---

## Conceptos Fundamentales

### Lazy.nvim

Es el gestor de plugins. Instala, actualiza y carga plugins automáticamente.

### Mason.nvim

Gestiona LSPs, formatters y linters. Instala automáticamente herramientas de desarrollo.

### Treesitter

Proporciona syntax highlighting avanzado basado en el AST del código.

### Which-Key

Muestra una popup con los keymaps disponibles cuando presionas una tecla.

---

## Por Qué Elegir LazyVim

### Ventajas

1. **Tiempo de configuración**: Funciona en minutos, no horas
2. **Comunidad activa**: Actualizaciones frecuentes
3. **Documentación excelente**: lazyvim.org
4. **Extras**: Configuraciones pre-hechas para lenguajes
5. **No reinventar la rueda**: Todo lo necesario incluido

### Desventajas

1. **Curva de aprendizaje**: Vim modes requieren práctica
2. **Dependencia**: tied to the distro structure
3. **Personalización limitada**: Puede requerir investigación extra

---

## Siguiente Paso

El siguiente módulo cubre los **[requisitos Previos](02_requisitos.md)** necesarios antes de instalar LazyVim.

---

## Recursos

- [Documentación oficial](https://www.lazyvim.org)
- [GitHub](https://github.com/LazyVim/LazyVim)
- [Discusiones](https://github.com/LazyVim/LazyVim/discussions)

---

**Última actualización**: 2026