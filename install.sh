#!/bin/bash
# Instala el tema "Savitar" en la Terminal de Mac (solo aspecto, sin atajos).
# Se puede ejecutar varias veces: respalda lo existente y no duplica nada.
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

info() { printf '\033[1;36m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m ✔\033[0m %s\n' "$1"; }
fail() { printf '\033[1;31m ✘\033[0m %s\n' "$1" >&2; exit 1; }

[[ "$(uname)" == "Darwin" ]] || fail "Este script es solo para macOS."

# 1. Homebrew (su instalador pide contraseña de administrador: se corre a mano)
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  fail 'Falta Homebrew. Instálalo primero con:
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
fi
ok "Homebrew en $HOMEBREW_PREFIX"

if ! grep -qs 'brew shellenv' ~/.zprofile; then
  echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> ~/.zprofile
  ok "Homebrew agregado a ~/.zprofile"
fi

# 2. Fuente, prompt y plugins
info "Instalando fuente, prompt y plugins..."
brew install --cask font-hack-nerd-font
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
ok "Paquetes instalados"

# 3. Dotfiles (con respaldo)
for f in zshrc p10k.zsh; do
  dest="$HOME/.$f"
  if [[ -f "$dest" ]] && ! cmp -s "$dest" "$REPO/dotfiles/$f"; then
    cp "$dest" "$dest.backup-$STAMP"
    ok "Respaldo: $dest.backup-$STAMP"
  fi
  cp "$REPO/dotfiles/$f" "$dest"
done
zsh -n ~/.zshrc || fail "~/.zshrc tiene errores de sintaxis"
ok "~/.zshrc y ~/.p10k.zsh instalados"

# 4. Perfil de la Terminal
info "Creando perfil 'Savitar' de la Terminal..."
PROFILE="$(mktemp -d)/Savitar.terminal"
OUT="$PROFILE" osascript -l JavaScript "$REPO/terminal/make-profile.js" >/dev/null
plutil -lint "$PROFILE" >/dev/null || fail "El perfil generado no es válido"
open "$PROFILE"      # importa el perfil (abre una ventana de la Terminal)
sleep 2
osascript -e 'tell application "Terminal"
  set default settings to settings set "Savitar"
  set startup settings to settings set "Savitar"
end tell'
ok "Perfil 'Savitar' importado y marcado como predeterminado"

echo
ok "Listo. Abre una ventana nueva de la Terminal para ver el tema."
