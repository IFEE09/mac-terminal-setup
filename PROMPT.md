# Prompt para instalar en otra Mac

## Antes (lo haces tú, una sola vez)

Estos pasos piden tu contraseña o que inicies sesión, así que Claude no puede hacerlos por ti.

1. Instala Claude Code:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
2. Instala Homebrew:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. Instala GitHub CLI e inicia sesión:
   ```bash
   eval "$(/opt/homebrew/bin/brew shellenv)" && brew install gh && gh auth login --web --git-protocol https
   ```

## El prompt

Abre Claude Code (`claude` en la terminal o la app de escritorio) y pega esto:

```text
Instala mi configuración de terminal desde mi repo privado de GitHub IFEE09/mac-terminal-setup.

1. Clónalo con `gh repo clone IFEE09/mac-terminal-setup ~/mac-terminal-setup` (si ya existe, haz `git pull`).
2. Lee el README.md completo para entender qué hace y qué NO debe hacer (solo aspecto, sin atajos, sin reemplazar ls/cat, sin Kitty).
3. Verifica que Homebrew esté instalado. Si no, detente y dime qué comando correr: pide contraseña y lo tengo que hacer yo.
4. Ejecuta `~/mac-terminal-setup/install.sh`.
5. Verifica lo que dice la sección "Verificación" del README y dime el resultado de cada punto.
6. Recuérdame los pasos manuales de notificaciones (permitir terminal-notifier y ponerlo en Persistente) y abrir una ventana nueva de la Terminal.
```
