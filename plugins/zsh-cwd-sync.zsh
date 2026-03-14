autoload -Uz add-zsh-hook

typeset -g _ZELLIX_LAST_SYNCED_PWD=""
typeset -g _ZELLIX_SYNCING=0

_zellix_debug_enabled() {
  case "${ZELLIX_DEBUG_INPUT_SYNC:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

_zellix_debug_log() {
  _zellix_debug_enabled || return 0
  print -r -- "[zellix] $*" >&2
}

_zellix_escape_for_helix_cd() {
  local dir="$1"
  dir="${dir//\\/\\\\}"
  dir="${dir//\"/\\\"}"
  print -r -- "$dir"
}

_zellix_sync_helix_cwd() {
  (( _ZELLIX_SYNCING )) && return 0
  [[ -n "${ZELLIJ:-}" ]] || return 0
  command -v zellij >/dev/null 2>&1 || return 0
  [[ "$PWD" == "$_ZELLIX_LAST_SYNCED_PWD" ]] && return 0

  _ZELLIX_SYNCING=1
  local escaped
  escaped="$(_zellix_escape_for_helix_cd "$PWD")"

  command zellij action move-focus up >/dev/null 2>&1 || {
    _ZELLIX_SYNCING=0
    return 0
  }

  local target_cmd
  target_cmd="$(command zellij action list-clients 2>/dev/null | awk 'NR==2 {for(i=3;i<=NF;i++) printf (i>3?OFS:"") $i}')"
  if [[ "$target_cmd" != *helix* && "$target_cmd" != *"/helix.nu"* && "$target_cmd" != *"/hx"* ]]; then
    _zellix_debug_log "cwd-sync skipped (focused pane command: '$target_cmd')"
    command zellij action move-focus down >/dev/null 2>&1
    _ZELLIX_SYNCING=0
    return 0
  fi
  _zellix_debug_log "cwd-sync target accepted (focused pane command: '$target_cmd')"

  command zellij action write 27 >/dev/null 2>&1
  command zellij action write-chars ":cd \"$escaped\"" >/dev/null 2>&1
  command zellij action write 13 >/dev/null 2>&1
  command zellij action move-focus down >/dev/null 2>&1

  _ZELLIX_LAST_SYNCED_PWD="$PWD"
  _ZELLIX_SYNCING=0
}

add-zsh-hook chpwd _zellix_sync_helix_cwd
