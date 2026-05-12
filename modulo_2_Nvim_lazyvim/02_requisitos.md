# 02 - Requisitos Previos

Antes de instalar LazyVim, necesitas verificar y preparar tu sistema. Esta guía cubre todos los requisitos necesarios.

---

## Neovim >= 0.11.2

Neovim debe estar compilado con **LuaJIT**.

### Verificar Versión Instalada

```bash
nvim --version
```

Deberías ver algo como:

```
NVIM v0.11.2
Build type: Release
LuaJIT 2.1.170
```

### Instalar/Versión Actualizar

#### Linux (Ubuntu/Debian)

```bash
# Opción 1: PPA (recomendado)
sudo add-apt-repository ppa:neovim-dev/unstable
sudo apt update
sudo apt install neovim

# Opción 2: Snap
sudo snap install neovim --classic

# Opción 3: Compilar desde código
git clone https://github.com/neovim/neovim.git
cd neovim
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
```

#### macOS

```bash
# Homebrew (recomendado)
brew install neovim

# MacPorts
sudo port install neovim
```

#### Windows

```powershell
# Winget (recomendado)
winget install Neovim.Neovim

# Chocolatey
choco install neovim

# Scoop
scoop install neovim
```

---

## Git >= 2.19.0

Git es requerido para clonar repositorios y usar partial clones.

### Verificar

```bash
git --version
# git version 2.40.0
```

### Instalar

#### Linux

```bash
sudo apt install git  # Ubuntu/Debian
sudo dnf install git # Fedora
sudo pacman -S git  # Arch
```

#### macOS

```bash
# Ya viene instalado, pero para actualizar:
brew install git
```

#### Windows

```bash
# Ya viene con Git for Windows
# O usar winget:
winget install Git.Git
```

---

## Nerd Font v3.0+ (Opcional pero Recomendado)

Necesario para mostrar icons en la UI.

### Verificar

```bash
fc-list | grep -i nerd
# o
fc-list | grep -i fira
```

### Instalar

#### Linux

```bash
# Crear directorio
mkdir -p ~/.local/share/fonts/NerdFonts

# Descargar
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/FiraCode.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/JetBrainsMono.zip
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/Hack.zip

# Extraer
unzip -o FiraCode.zip -d ~/.local/share/fonts/NerdFonts/
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/NerdFonts/
unzip -o Hack.zip -d ~/.local/share/fonts/NerdFonts/

# Actualizar cache
fc-cache -fv
```

#### macOS

```bash
# Con Homebrew
brew tap homebrew/cask-fonts
brew install font-fira-code-nerd-font
brew install font-jetbrains-mono-nerd-font
```

### Configurar en Terminal

Edita la configuración de tu terminal para usar la Nerd Font:

#### Kitty (`~/.config/kitty/kitty.conf`)

```conf
font_family JetBrainsMono Nerd Font
font_size 12
```

#### WezTerm (`~/.config/wezterm/wezterm.lua`)

```lua
local wezterm = require 'wezterm'
return {
  font = wezterm.font('JetBrainsMono Nerd Font'),
  font_size = 12,
}
```

#### Alacritty (`~/.config/alacritty/alacritty.toml`)

```toml
[font]
normal = { family = "JetBrainsMono Nerd Font" }
```

---

## Terminal Compatible

LazyVim funciona mejor con terminals que soportan **true color** y **undercurl**.

### Terminals Recomendados

| Terminal | Plataforma | True Color | Undercurl |
|----------|------------|-----------|----------|
| **Kitty** | Linux/macOS | ✅ | ✅ |
| **WezTerm** | Linux/macOS/Windows | ✅ | ✅ |
| **Alacritty** | Linux/macOS/Windows | ✅ | ✅ |
| **iTerm2** | macOS | ✅ | ✅ |
| **Ghostty** | Linux/macOS/Windows | ✅ | ✅ |

### Configuración Básica por Terminal

#### Kitty

```conf
# ~/.config/kitty/kitty.conf
enable_audio_bell no
hide_window_decorations yes
adjust_window_width_to_cw 1
adjust_window_height_to_cw 1
tab_bar edge top
tab_bar_style powerline
background_opacity 0.95
```

#### WezTerm

```lua
-- ~/.config/wezterm/wezterm.lua
local wezterm = require 'wezterm'
return {
  color_scheme = 'Tokyo Night',
  enable_tab_bar = true,
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
}
```

#### Alacritty

```toml
# ~/.config/alacritty/alacritty.toml
[window]
opacity = 0.95

[font]
size = 12
```

---

## Herramientas CLI

Instala las siguientes herramientas que LazyVim necesita:

### Linux

```bash
# Ubuntu/Debian
sudo apt install lazygit ripgrep fd-find fzf curl

# Verificar versiones:
lazygit --version
rg --version
fdfind --version  # o fd
fzf --version
```

### macOS

```bash
brew install lazygit ripgrep fd fzf curl tree-sitter
```

### Windows

```powershell
# Con Chocolatey
choco install lazygit ripgrep fd fzf

#O con Scoop
scoop install lazygit ripgrep fd
```

### Verificar Instalación

```bash
# lazygit
lazygit --version  # >= v0.40

# ripgrep
rg --version

# fd
fd --version  # >= 8.0

# fzf
fzf --version  # >= 0.25.1
```

---

## Herramientas de Desarrollo

### Para Flutter/Dart

#### Verificar

```bash
flutter --version
dart --version
```

#### Instalar

```bash
# Linux
sudo snap install flutter --classic

# macOS
brew install flutter

# Windows
# Descargar de https://flutter.dev/docs/get-started/install
```

#### Configurar PATH

```bash
# Agregar a ~/.bashrc o ~/.zshrc
export PATH="$PATH:$HOME/flutter/bin"
export PATH="$PATH:$HOME/.pub-cache/bin"
```

### Para TypeScript/Next.js

#### Verificar

```bash
node --version  # >= v18
npm --version
```

#### Instalar

```bash
# Linux
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# macOS
brew install node@18

# Windows (con nvm-windows)
winget install OpenJS.NodeJSLTS
```

#### Actualizar npm

```bash
npm install -g npm@latest
```

### Para Supabase

#### Verificar

```bash
supabase --version
```

#### Instalar

```bash
# Con npm
npm install -g supabase

# Con Homebrew
brew install supabase/tap/supabase

# Linux/macOS
curl -fsSL https://github.com/supabase/cli/releases/download/v1.100.0/supabase_linux_amd64.tar.gz | tar -xz
sudo mv supabase /usr/local/bin/
```

---

## Verificación Final

Crea un script para verificar todos los requisitos:

```bash
#!/bin/bash

echo "=== Verificación de Requisitos ==="
echo ""

# Neovim
if command -v nvim &> /dev/null; then
    echo "✓ Neovim: $(nvim --version | head -n1)"
else
    echo "✗ Neovim no encontrado"
fi

# Git
if command -v git &> /dev/null; then
    echo "✓ Git: $(git --version)"
else
    echo "✗ Git no encontrado"
fi

# Terminal
echo "✓ Terminal: $TERM"

# lazygit
if command -v lazygit &> /dev/null; then
    echo "✓ lazygit: $(lazygit --version)"
else
    echo "⚠ lazygit no encontrado (opcional)"
fi

# ripgrep
if command -v rg &> /dev/null; then
    echo "✓ ripgrep: $(rg --version | head -n1)"
else
    echo "⚠ ripgrep no encontrado (opcional)"
fi

# fd
if command -v fd &> /dev/null; then
    echo "✓ fd: $(fd --version | head -n1)"
else
    echo "⚠ fd no encontrado (opcional)"
fi

# Flutter
if command -v flutter &> /dev/null; then
    echo "✓ Flutter: $(flutter --version | head -n1)"
else
    echo "⚠ Flutter no encontrado (opcional)"
fi

# Node
if command -v node &> /dev/null; then
    echo "✓ Node.js: $(node --version)"
else
    echo "⚠ Node.js no encontrado (opcional)"
fi

echo ""
echo "=== Fin de verificación ==="
```

Ejecuta el script:

```bash
chmod +x verify.sh
./verify.sh
```

---

## Siguiente Paso

Una vez verificados los requisitos, procede al **[módulo de instalación](03_instalacion.md)**.

---

## Recursos

- [Neovim Releases](https://github.com/neovim/neovim/releases)
- [nerd-fonts](https://www.nerdfonts.com)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [WezTerm](https://wezterm.org)
- [Alacritty](https://alacritty.org)

---

**Última actualización**: 2026