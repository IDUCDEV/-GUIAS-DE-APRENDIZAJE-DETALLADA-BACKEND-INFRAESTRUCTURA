# 15 - Recursos

Este módulo proporciona una colección de recursos adicionales para profundizar en LazyVim y Neovim.

---

## 1. Documentación Oficial

### 1.1 LazyVim

| Recurso | URL |
|--------|-----|
| Web Principal | https://www.lazyvim.org |
| GitHub | https://github.com/LazyVim/LazyVim |
| Docs | https://www.lazyvim.org |
| Keymaps | https://www.lazyvim.org/keymaps |
| Plugins | https://www.lazyvim.org/plugins |
| Extras | https://www.lazyvim.org/extras |

### 1.2 Neovim

| Recurso | URL |
|--------|-----|
| Web | https://neovim.io |
| Docs | https://neovim.io/doc |
| GitHub | https://github.com/neovim/neovim |
| Wiki | https://github.com/neovim/neovim/wiki |

### 1.3 lazy.nvim

| Recurso | URL |
|--------|-----|
| GitHub | https://github.com/folke/lazy.nvim |
| Docs | https://www.lazyvim.org/configuration/lazy.nvim |

---

## 2.Plugins Recomendados

### 2.1 UI Enhancement

| Plugin | Descripción |
|--------|-------------|
| snacks.nvim | Utilidades UI |
| noice.nvim | UI de mensajes |
| bufferline.nvim | Buffer tabs |
| lualine | Statusline |
| which-key | Keymap popup |

### 2.2 Editor

| Plugin | Descripción |
|--------|-------------|
| telescope.nvim | Fuzzy finder |
| fzf-lua | Fuzzy finder alternativo |
| neo-tree.nvim | File explorer |
| vim-visual-multi | Multi-cursor |

### 2.3 LSP & Completition

| Plugin | Descripción |
|--------|-------------|
| blink.cmp | Autocomplete |
| nvim-lspconfig | LSP configs |
| mason.nvim | Gestor de LSPs |
| nvim-cmp | Autocomplete legacy |

### 2.4 Git

| Plugin | Descripción |
|--------|-------------|
| gitsigns | Git signs |
| lazygit | Git UI |
| neogit | Git UI alternativo |
| diffview.nvim | Git diff |

### 2.5 Utilities

| Plugin | Descripción |
|--------|-------------|
| persistence.nvim | Session management |
| nvim-spectre | Search & Replace |
| vim-tmux-navigator | tmux integration |
| yanky.nvim | Yank history |

---

## 3. Comunidades

### 3.1 Online

| Comunidad | URL |
|-----------|-----|
| Reddit r/neovim | https://reddit.com/r/neovim |
| Reddit r/lazyvim | https://reddit.com/r/lazyvim |
| Discord | https://discord.gg/2Z8chdps9Z |
| Matrix | #lazyvim:matrix.org |

### 3.2 Discussions

| Recurso | URL |
|--------|-----|
| LazyVim Discussions | https://github.com/LazyVim/LazyVim/discussions |
| Neovim Discussions | https://github.com/neovim/neovim/discussions |

---

## 4. Tutoriales y Vídeos

### 4.1 Tutoriales Oficiales

| Recurso | Descripción |
|---------|-------------|
| LazyVim Walkthrough | https://www.youtube.com/watch?v=N93cTbtLCIM |
| Getting Started | https://www.lazyvim.org |
| Installation | https://www.lazyvim.org/installation |

### 4.2 Libros Gratuitos

| Libro | Autor | URL |
|-------|-------|-----|
| LazyVim for Ambitious Developers | Dusty Phillips | https://lazyvim-ambitious-devs.phillips.codes |

### 4.3 Canales de YouTube

| Canal | Descripción |
|-------|-------------|
| ThePrimeagen | Neovim teaching |
| Josean Martinez | Dev setup tutorials |
| Ellijah Manor | LazyVim walkthrough |
| Takuya Matsuda | Vim/Neovim tips |

---

## 5. Herramientas de Desarrollo

### 5.1 Flutter/Dart

| Recurso | URL |
|--------|-----|
| Flutter SDK | https://flutter.dev |
| Dart | https://dart.dev |
| flutter-tools.nvim | https://github.com/akinsho/flutter-tools.nvim |
| neotest-dart | https://github.com/sidlatau/neotest-dart |

### 5.2 TypeScript/Next.js

| Recurso | URL |
|--------|-----|
| TypeScript | https://www.typescriptlang.org |
| Next.js | https://nextjs.org |
| Prettier | https://prettier.io |
| ESLint | https://eslint.org |

### 5.3 Supabase

| Recurso | URL |
|--------|-----|
| Supabase | https://supabase.com |
| CLI | https://github.com/supabase/cli |
| vim-dadbod | https://github.com/kristijanhusak/vim-dadbod |

---

## 6. Configuración de Ejemplo

### 6.1 Configuración Básica

```lua
-- ~/.config/nvim/lua/config/options.lua
vim.g.mapleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
```

### 6.2 Configuración con Extras

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  { import = "lazyvim.plugins.extras.lang.dart" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
```

### 6.3 Keymaps Personalizados

```lua
-- ~/.config/nvim/lua/config/keymaps.lua
vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files()
end, { desc = "Find files" })
```

---

## 7. Troubleshooting

### 7.1 Problemas Comunes

| Problema | Solución |
|----------|----------|
| Plugins no cargan | `:Lazy sync` |
| LSP no funciona | `:LspInfo` + `:Mason` |
| Slow startup | `nvim --startuptime` |
| Colores incorrectos | Verificar terminal |

### 7.2 Logs

```vim
:LazyLog     " Ver logs de Lazy
:LspLog     " Ver logs de LSP
:DapShowLog " Ver logs de DAP
```

---

## 8. Actualización

### 8.1 Actualizar LazyVim

```vim
:Lazy
:Lazy update
```

### 8.2 Actualizar Neovim

```bash
# Ubuntu
sudo apt update && sudo apt upgrade neovim

# macOS
brew upgrade neovim

# Windows
winget upgrade Neovim.Neovim
```

---

## 9. Contribute

### 9.1 Contribuir a LazyVim

1. Fork el repositorio
2. Crea un branch
3. Haz cambios
4. Envía pull request

### 9.2 Reportar Bugs

Ve a https://github.com/LazyVim/LazyVim/issues

---

## 10. Aprendiendo Más

### 10.1 Práctica Diaria

1. Usa atajos de teclado siempre
2. Practica movimientos sin flechas
3. Aprende un comando nuevo al día
4. Usa el dot command (`.`)

### 10.2 Recursos de Aprendizaje

| Recurso | Descripción |
|--------|-------------|
| vimtutor | `:Tutor` o `vimtutor` |
| vimhelp | `:h` |
| Learn vimscript the hard way | https://learnvimscripting.filippo.io |

---

## Siguiente Paso

El **[quick reference](quick_reference.md)** proporciona una tarjeta de referencia rápida para tener a mano.

---

**Última actualización**: 2026