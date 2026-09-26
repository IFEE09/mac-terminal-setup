#!/bin/bash
# Notificación de macOS al terminar una tarea (Stop) o un subagente (SubagentStop).
# Al hacer clic abre el resumen completo en TextEdit.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
TN=$(command -v terminal-notifier) || exit 0
input=$(cat)

event=$(jq -r '.hook_event_name // "Stop"' <<<"$input")
project=$(basename "$(jq -r '.cwd // empty' <<<"$input")")
full=$(jq -r '.last_assistant_message // empty' <<<"$input")

# Si el payload no trae el último mensaje, lo saca del transcript.
if [ -z "$full" ]; then
  tp=$(jq -r '.agent_transcript_path // .transcript_path // empty' <<<"$input")
  if [ -f "$tp" ]; then
    full=$(tail -n 200 "$tp" | jq -rs '[.[] | select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text] | last // empty' 2>/dev/null)
  fi
fi
[ -z "$full" ] && full="Sin resumen disponible"

if [ "$event" = "SubagentStop" ]; then
  agent=$(jq -r '(.agent_type | select(. != null and . != "")) // "subagente"' <<<"$input")
  title="Subagente terminado ($agent)"; sound="Pop"
else
  title="Tarea terminada"; sound="Glass"
fi

# Guarda el resumen completo; borra los de más de 7 días.
dir="$HOME/.claude/notificaciones"
mkdir -p "$dir"
find "$dir" -name '*.txt' -mtime +7 -delete 2>/dev/null
id="claude-$(date +%Y%m%d-%H%M%S)-$$"
file="$dir/$id.txt"
printf '%s\n%s — %s\n\n%s\n' "$title" "${project:-Claude Code}" "$(date '+%d/%m/%Y %H:%M')" "$full" > "$file"

# Texto corto para la notificación: una línea, sin markdown.
msg=$(printf '%s' "$full" | tr '\n' ' ' | sed -E 's/[*`#>]//g; s/  +/ /g; s/^ //')
[ ${#msg} -gt 180 ] && msg="${msg:0:177}..."

# Monito de Claude Code a la derecha de la notificación (si existe)
img="$HOME/.claude/hooks/clawd.png"
[ -f "$img" ] && img_args=(-contentImage "$img") || img_args=()

"$TN" "${img_args[@]}" \
  -title "$title" \
  -subtitle "${project:-Claude Code}" \
  -message "$msg" \
  -sound "$sound" \
  -group "$id" \
  -execute "open -a TextEdit '$file'; $TN -remove '$id'"
