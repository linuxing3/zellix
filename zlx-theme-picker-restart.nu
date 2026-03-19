#!/usr/bin/env nu

def main [] {
  let session = ($env.ZELLIX_SESSION? | default "")
  if ($session | is-empty) {
    print "zlx theme picker: ZELLIX_SESSION not set, cannot restart automatically."
    exit 1
  }

  let theme_dir = ($env.HOME | path join ".config" "zellij" "themes")
  if not ($theme_dir | path exists) {
    print $"zlx theme picker: theme directory not found: ($theme_dir)"
    exit 1
  }

  let themes = (
    ls $theme_dir
    | where type == file and name =~ "\\.kdl$"
    | get name
    | path basename
    | each {|n| $n | str replace ".kdl" "" }
    | sort
  )

  if ($themes | is-empty) {
    print $"zlx theme picker: no .kdl themes found in ($theme_dir)"
    exit 1
  }

  let selected = ($themes | str join (char nl) | ^fzf --prompt 'zellij theme> ' --height=50% --layout=reverse --border --exit-0 | str trim)
  if ($selected | is-empty) {
    print "zlx theme picker: cancelled."
    exit 0
  }

  let cache_dir = ($env.HOME | path join ".cache")
  mkdir $cache_dir
  $selected | save -f ($cache_dir | path join "zlx-zellij-theme")

  print $"zlx theme picker: selected '($selected)'"

  try { ^zellij options --theme $selected }

  "" | save -f $"/tmp/zellix/restart-($session).flag"
  print $"zlx theme picker: restarting session '($session)' to apply theme..."
  ^zellij kill-session $session
}
