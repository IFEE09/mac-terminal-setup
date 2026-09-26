# mac-terminal-setup

Tema para la **Terminal nativa de macOS**, inspirado en el de S4vitar: prompt Powerlevel10k, fuente Hack Nerd Font, fondo transparente con desenfoque y colores vivos.

**Regla principal para la Terminal: solo aspecto.** No agrega atajos de teclado, no reemplaza comandos (`ls` y `cat` siguen siendo los de Mac) y no cambia el comportamiento de ninguna tecla. Solo afecta a la Terminal de Mac: VS Code, la app de Claude y cualquier otra terminal quedan igual.

Además instala las **notificaciones de Claude Code**: un aviso de macOS cada vez que Claude termina una tarea, con el resumen completo a un clic.

- Instalar en otra Mac con Claude: ver [PROMPT.md](PROMPT.md)
- Instalar a mano: `./install.sh` (requiere Homebrew)

## Opcional: Claude Usage

No viene incluida en este instalador. Si también la quieres, es una app aparte para la barra de menús que muestra tus límites de uso de Claude: **[IFEE09/claude-usage](https://github.com/IFEE09/claude-usage)**

```bash
git clone https://github.com/IFEE09/claude-usage.git ~/claude-usage
~/claude-usage/build.sh --install
```

## Qué se instala

| Pieza | Para qué | Cómo |
|---|---|---|
| Homebrew | Gestor de paquetes | Manual (pide contraseña) |
| Hack Nerd Font | Fuente con los íconos del prompt | `brew install --cask font-hack-nerd-font` |
| Powerlevel10k | Prompt de colores con carpeta, git y hora | `brew install powerlevel10k` |
| zsh-autosuggestions | Sugerencia en gris según el historial | `brew install zsh-autosuggestions` |
| zsh-syntax-highlighting | Comando en verde si existe, rojo si no | `brew install zsh-syntax-highlighting` |
| Perfil "Savitar" | Fuente, transparencia, colores y cursor de la Terminal | `terminal/make-profile.js` |
| terminal-notifier y jq | Mostrar las notificaciones de Claude Code y leer sus datos | `brew install terminal-notifier jq` |
| Hook de notificaciones | Aviso al terminar cada tarea de Claude Code | `claude/notify.sh` → `~/.claude/hooks/` |

## Archivos

```
install.sh                 Instalador (se puede correr varias veces)
PROMPT.md                  Prompt para Claude Code en otra Mac
dotfiles/zshrc             → ~/.zshrc
dotfiles/p10k.zsh          → ~/.p10k.zsh (estilo del prompt: lean, nerdfont, 24h)
terminal/make-profile.js   Genera el perfil de la Terminal (JXA, sin dependencias)
claude/notify.sh           → ~/.claude/hooks/notify.sh (notificación al terminar una tarea)
claude/clawd.png           → ~/.claude/hooks/clawd.png (imagen de la notificación)
```

## Qué hace `install.sh`, paso a paso

1. Comprueba que sea macOS y que Homebrew esté instalado (en `/opt/homebrew` o `/usr/local`). Si falta Homebrew, se detiene y muestra el comando para instalarlo.
2. Agrega `brew shellenv` a `~/.zprofile` si no está.
3. Instala la fuente, Powerlevel10k y los dos plugins.
4. Respalda `~/.zshrc` y `~/.p10k.zsh` si existen y son distintos (`.backup-FECHA`), y copia los del repo.
5. Genera `Savitar.terminal` con `make-profile.js`, lo importa (se abre una ventana de la Terminal) y lo deja como perfil predeterminado y de inicio.
6. Instala `terminal-notifier` y `jq`, copia `notify.sh` y `clawd.png` a `~/.claude/hooks/` y agrega el hook `Stop` a `~/.claude/settings.json`. No borra nada de lo que ya tengas ahí: respalda el archivo (`.backup-FECHA`) y, si el hook ya existe, no lo duplica.

## Notificaciones de Claude Code

Cada vez que Claude Code termina de responder, el hook `Stop` corre `~/.claude/hooks/notify.sh`, que:

- Muestra una notificación de macOS con el nombre del proyecto y las primeras líneas de la respuesta (sonido "Glass").
- Guarda la respuesta completa en `~/.claude/notificaciones/` y la abre en TextEdit si das clic en la notificación. Los archivos de más de 7 días se borran solos.
- Corre en segundo plano (`async`), así que no hace esperar a Claude. Si algo falla, no muestra error.

Lo que se agrega a `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      { "hooks": [{ "type": "command", "command": "~/.claude/hooks/notify.sh 2>/dev/null || true", "async": true }] }
    ]
  }
}
```

Claude Code lee la configuración al arrancar: después de instalar, cierra y vuelve a abrir Claude Code para que empiecen a salir las notificaciones.

La primera vez, macOS puede pedir permiso para que `terminal-notifier` muestre notificaciones: acéptalo en **Ajustes del Sistema → Notificaciones**.

## Detalles del perfil de la Terminal

| Ajuste | Valor |
|---|---|
| Fuente | Hack Nerd Font Mono, 14 pt (`HackNFM-Regular`) |
| Fondo | `#0f111a` al 78 % de opacidad, desenfoque 0.6 |
| Texto | `#e6edff`; negrita `#ffffff` con colores brillantes |
| Cursor | Barra rosa `#ff79c6` |
| Selección | `#3d59a1` |
| Tamaño | 110 × 30 |

Paleta ANSI (normal / brillante):

| Color | Normal | Brillante |
|---|---|---|
| Negro | `#1b1e2b` | `#5c6690` |
| Rojo | `#ff5370` | `#ff6e85` |
| Verde | `#50fa7b` | `#7dffa0` |
| Amarillo | `#ffcb6b` | `#ffe08a` |
| Azul | `#5ea8ff` | `#82bfff` |
| Magenta | `#c792ea` | `#e0aaff` |
| Cian | `#00e5ff` | `#6cf6ff` |
| Blanco | `#c3cee3` | `#ffffff` |

Para cambiar colores o transparencia, edita `terminal/make-profile.js` y vuelve a correr `install.sh`, o ajústalo a mano en **Terminal → Ajustes → Perfiles → Savitar**.

## Cómo funciona el `.zshrc`

Todo el tema está dentro de `if [[ "$TERM_PROGRAM" == "Apple_Terminal" && -o interactive ]]`, así que:

- Solo se carga en la Terminal de Mac y en shells interactivos; los scripts no lo ven.
- En otras terminales el prompt sigue siendo el de Mac (`usuario@mac carpeta %`).
- `CLICOLOR=1` y `LSCOLORS` activan el color del `ls` original de Mac. No es un alias, así que todas sus opciones funcionan igual.
- Usa `$HOMEBREW_PREFIX`, por lo que funciona en Macs con Apple Silicon y con Intel.
- Además agrega `~/.local/bin` al PATH, que es donde se instala Claude Code.

## Historia: qué se probó y se descartó

Este setup es el resultado de varias iteraciones. Queda documentado para no repetir errores:

1. **Kitty como terminal**: funcionaba bien, pero se descartó para usar la Terminal nativa de Mac. Su paleta y transparencia se pasaron al perfil "Savitar".
2. **Atajos de teclado** (alias `ll`/`la`/`l`, función `mkt`, plugin sudo con `Esc Esc`, fzf con `Ctrl+R`/`Ctrl+T`, paneles con `Cmd+D`, `bindkey` de Option y flechas): se quitaron porque la idea es que todo funcione como viene en Mac.
3. **`ls` → lsd y `cat` → bat con alias**: se quitaron porque rompen opciones de Mac. Probado: `ls -laT`, `ls -l@`, `ls -lO`, `cat -b`, `cat -e`, `cat -v` y `cat -t` fallaban. Se reemplazó por el color nativo de `ls` (`CLICOLOR`).
4. **Tema cargado en todas las terminales**: se limitó a la Terminal de Mac porque en otras (VS Code, la app de Claude) no hay Nerd Font y los íconos se veían rotos.
5. **Rutas fijas `/opt/homebrew`**: se cambiaron por `$HOMEBREW_PREFIX` para que también funcione en Macs con Intel.

## Verificación

Después de instalar, deberían cumplirse estas comprobaciones:

```bash
# 1. Perfil predeterminado
osascript -e 'tell application "Terminal" to name of default settings'        # → Savitar

# 2. El tema carga en la Terminal de Mac
TERM_PROGRAM=Apple_Terminal zsh -lic 'echo ${+functions[p10k]}'              # → 1

# 3. Y no carga en otras terminales
TERM_PROGRAM=vscode zsh -lic 'echo ${+functions[p10k]}'                      # → 0

# 4. ls y cat siguen siendo los de Mac
zsh -ic 'whence -w ls cat'                                                   # → ls: command, cat: command

# 5. Sin errores de sintaxis
zsh -n ~/.zshrc && echo ok                                                   # → ok

# 6. Notificaciones: el hook está configurado y el script se ejecuta
jq '.hooks.Stop' ~/.claude/settings.json | grep -c notify.sh                 # → 1
echo '{"cwd":"/tmp/prueba","last_assistant_message":"Prueba"}' | ~/.claude/hooks/notify.sh   # → aparece una notificación
```

## Desinstalar

```bash
osascript -e 'tell application "Terminal" to set default settings to settings set "Basic"'
osascript -e 'tell application "Terminal" to set startup settings to settings set "Basic"'
brew uninstall powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
brew uninstall --cask font-hack-nerd-font
# Restaurar el respaldo más reciente de ~/.zshrc (o borrarlo) y borrar ~/.p10k.zsh

# Notificaciones de Claude Code
jq 'del(.hooks.Stop[] | select(any(.hooks[]; .command | contains("notify.sh"))))' ~/.claude/settings.json > /tmp/s.json && mv /tmp/s.json ~/.claude/settings.json
rm -f ~/.claude/hooks/notify.sh ~/.claude/hooks/clawd.png
rm -rf ~/.claude/notificaciones
brew uninstall terminal-notifier
```
