# Guía Completa de LazyVim para Desarrolladores

## Transición desde VSCode / Ant gravity a Neovim con LazyVim

Esta guía está diseñada para desarrolladores que vienen de VSCode u otros IDEs como Ant gravity y necesitan hacer la transición a **Neovim** usando **LazyVim**. El nivel de detalle es avanzado, pensado para desarrolladores que trabajan con **Flutter/Dart**, **Supabase** y **TypeScript/Node.js/Next.js**.

---

## Tabla de Contenidos

### Módulos Fundamentales

| Módulo | Archivo | Descripción |
|--------|--------|-----------|
| 00 | [README](README.md) | Índice y visión general |
| 01 | [01_introduccion.md](01_introduccion.md) | Qué es LazyVim, diferencias con VSCode |
| 02 | [02_requisitos.md](02_requisitos.md) | Neovim, Git, Nerd Font, terminal, CLI tools |
| 03 | [03_instalacion.md](03_instalacion.md) | Instalación paso a paso completa |
| 04 | [04_estructura.md](04_estructura.md) | Árbol de directorios, archivos config |
| 05 | [05_plugins.md](05_plugins.md) | Plugins incluidos por categoría |
| 06 | [06_modes.md](06_modes.md) | Modes, movimientos, operaciones |
| 07 | [07_keymaps.md](07_keymaps.md) | Tabla comparativa VSCode → LazyVim |

### Módulos de Lenguaje y Framework

| Módulo | Archivo | Descripción |
|--------|--------|-----------|
| 08 | [08_flutter_dart.md](08_flutter_dart.md) | Configuración Flutter/Dart específica |
| 09 | [09_typescript.md](09_typescript.md) | Configuración TypeScript/Next.js |
| 10 | [10_supabase.md](10_supabase.md) | Integración con Supabase |

### Módulos Avanzados

| Módulo | Archivo | Descripción |
|--------|--------|-----------|
| 11 | [11_personalizacion.md](11_personalizacion.md) | Colorscheme, opciones, agregar plugins |
| 12 | [12_comandos.md](12_comandos.md) | Comandos útiles (Lazy, Mason, LSP) |
| 13 | [13_flujo_diario.md](13_flujo_diario.md) | Workflow de desarrollo |
| 14 | [14_debugging.md](14_debugging.md) | Debugging para Flutter y TS |
| 15 | [15_recursos.md](15_recursos.md) | Docs, vídeos, comunidad |

### Material de Referencia

| Archivo | Descripción |
|---------|-------------|
| [quick_reference.md](quick_reference.md) | Tarjeta de referencia rápida |

---

## Cómo Usar Esta Guía

### Secuencia Recomendada

1. **Semana 1**: Módulos 01-04 (Introducción, Requisitos, Instalación, Estructura)
2. **Semana 2**: Módulos 05-07 (Plugins, Modes, Keymaps)
3. **Semana 3**: Módulos 08-10 (Tu stack: Flutter/Dart, TypeScript, Supabase)
4. **Semana 4**: Módulos 11-15 (Personalización, Comandos, Flujo, Debugging)

### Prerrequisitos

- Haber completado la instalación de LazyVim (módulo 03)
- Tener Neovim >= 0.11.2 instalado
- Terminal compatible (kitty, wezterm, alacritty)

---

## Requisitos del Sistema

| Requisito | Versión Mínima |
|-----------|----------------|
| Neovim | 0.11.2 (con LuaJIT) |
| Git | 2.19.0 |
| Nerd Font | v3.0+ |
| Terminal | true color + undercurl |

### Herramientas CLI Requeridas

- **lazygit**: UI de Git
- **ripgrep**: Búsqueda en archivos
- **fd**: Buscador de archivos
- **fzf**: Fuzzy finder
- **curl**: Descargas HTTP

### Para Flutter/Dart

- Flutter SDK >= 3.0
- Dart >= 3.0

### Para TypeScript/Next.js

- Node.js >= 18
- npm >= 9

### Para Supabase

- CLI de Supabase (opcional)
- Acceso a proyecto Supabase

---

## Primeros Pasos

### Si Es Nu Evo en LazyVim

1. Lee el **módulo 01** para entender qué es LazyVim
2. Revisa el **módulo 02** para verificar requisitos
3. Sigue el **módulo 03** para instalar
4. Familiarízate con el **módulo 06** (Modes)
5. Practica los **keymaps esenciales** del **módulo 07**

### Configuración de Tu Stack

1. **Módulo 08**: Configura Flutter/Dart
2. **Módulo 09**: Configura TypeScript/Next.js
3. **Módulo 10**: Configura Supabase

---

## Atajos de Teclado Principales

| Acción | Atajo LazyVim | Equivalente VSCode |
|--------|---------------|-------------------|
| Buscar archivo | `<leader>ff` | `Ctrl+P` |
| Buscar en contenido | `<leader>sg` | `Ctrl+Shift+F` |
| Terminal | `<leader>ft` | `` Ctrl+` `` |
| Git status | `<leader>gs` | `Ctrl+Shift+G` |
| Go to definition | `gd` | `F12` |
| Find references | `gr` | `Shift+F12` |
| Code action | `<leader>ca` | `Ctrl+.` |
| Rename | `<leader>cr` | `F2` |
| Formatear | `<leader>cf` | `Ctrl+Shift+I` |

> **Nota**: `<leader>` es la tecla **espacio** por defecto.

---

## Comandos Esenciales

```vim
:Lazy           " Gestor de plugins
:LazyExtras     " Instalar extras de idiomas
:Mason          " Instalar LSPs/formatters
:LazyHealth     " Verificar instalación
:LspInfo        " Información del LSP activo
```

---

## Estado de la Guía

| 属性 | Valor |
|--------|---------|
| Versión | 1.0 |
| Última actualización | 2026 |
| Compatibilidad | Neovim >= 0.11.2 |
| LazyVim | latest (stable) |

---

## Contribuir

Esta guía es de código abierto. Si encuentras errores o quieres agregar contenido:

1. Haz fork del repositorio
2. Crea un branch para tu cambio
3. Envía un pull request

---

**Enjoy your new Neovim setup!** 🚀

```vim
" Para salir de Neovim cuando sea necesario
:qa!
```