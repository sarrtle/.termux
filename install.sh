#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "=== Termux Full Zsh + Tokyonight Setup ==="

# ------------------------------
# Update & upgrade
# ------------------------------
pkg update -y
pkg upgrade -y

# ------------------------------
# Install packages
# ------------------------------
pkg install -y \
  zsh \
  git \
  termux-api \
  lsd \
  wget \
  unzip

# ------------------------------
# Change default shell to zsh
# ------------------------------
if [ "$SHELL" != "$(command -v zsh)" ]; then
  chsh -s zsh
fi

# ------------------------------
# Create tools directory
# ------------------------------
TOOLS_DIR="$HOME/tools"
mkdir -p "$TOOLS_DIR"

# ------------------------------
# Clone Zsh tools (idempotent)
# ------------------------------
clone_if_missing () {
  local repo="$1"
  local target="$2"

  if [ ! -d "$target" ]; then
    echo "Cloning $repo..."
    git clone --depth=1 "$repo" "$target"
  else
    echo "Already exists: $target"
  fi
}

clone_if_missing \
  https://github.com/romkatv/powerlevel10k.git \
  "$TOOLS_DIR/powerlevel10k"

clone_if_missing \
  https://github.com/zsh-users/zsh-autosuggestions \
  "$TOOLS_DIR/zsh-autosuggestions"

clone_if_missing \
  https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "$TOOLS_DIR/zsh-syntax-highlighting"

# ------------------------------
# Install JetBrainsMono Nerd Font (Termux-safe)
# ------------------------------
FONT_DIR="$HOME/.termux"
FONT_TMP="$HOME/.cache/jetbrainsmono"

mkdir -p "$FONT_DIR"
mkdir -p "$FONT_TMP"

echo "Downloading JetBrainsMono Nerd Font..."
wget -q --show-progress \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip \
  -O "$FONT_TMP/font.zip"

unzip -o "$FONT_TMP/font.zip" -d "$FONT_TMP"

FONT_FILE="$FONT_TMP/JetBrainsMonoNLNerdFont-Bold.ttf"

if [ -z "$FONT_FILE" ]; then
  echo "X JetbrainsMono NL Bold font not found"
  exit 1
fi

cp "$FONT_FILE" "$FONT_DIR/font.ttf"

# Cleanup temp files
rm -rf "$FONT_TMP"

# Apply font immediately
termux-reload-settings

# ------------------------------
# Write clean .zshrc (overwrite)
# ------------------------------
cat > "$HOME/.zshrc" << 'EOF'
# ==============================
# Zsh Configuration
# ==============================

# --- Powerlevel10k Theme ---
source ~/tools/powerlevel10k/powerlevel10k.zsh-theme

# --- Autosuggestions ---
source ~/tools/zsh-autosuggestions/zsh-autosuggestions.zsh

# --- Persistent History ---
HISTFILE=~/.zsh_history
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# --- Completion System ---
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

# --- Aliases ---
alias ls=lsd

# --- Syntax Highlighting (must be last) ---
source ~/tools/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
EOF

# ------------------------------
# Tokyonight Colors
# ------------------------------
cat > "$HOME/.termux/colors.properties" << 'EOF'
background=#1a1b26
foreground=#a9b1d6
cursor=#c0caf5

color0=#15161e
color1=#f7768e
color2=#9ece6a
color3=#e0af68
color4=#7aa2f7
color5=#bb9af7
color6=#7dcfff
color7=#a9b1d6
color8=#414868
color9=#f7768e
color10=#9ece6a
color11=#e0af68
color12=#7aa2f7
color13=#bb9af7
color14=#7dcfff
color15=#c0caf5
EOF

termux-reload-settings

# ------------------------------
# Remove Termux MOTD
# ------------------------------
rm -f "$PREFIX/etc/motd"

# -----------------------------
# Install NEOVIM
# -----------------------------
pkg install -y \
  mandoc \
  nodejs \
  neovim \
  python \
  uv \
  ruff \
  rust \
  rust-src \
  rust-analyzer

git clone --branch termux --single-branch https://github.com/sarrtle/.nvim.git .config/nvim

echo
echo "✅ Setup complete."
echo "Restart Termux to enter Zsh + Powerlevel10k."
echo "Enter nvim and let the setup install then :Mason and install only pyright and black."
