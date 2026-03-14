#!/usr/bin/env nu

def main [] {
  let session = (if ("ZELLIX_SESSION" in $env) { $env.ZELLIX_SESSION } else { "" })
  if ($session | str trim) == "" {
    print "zlx theme picker: ZELLIX_SESSION not set, cannot restart automatically."
    exit 1
  }

  let theme_dir = ($env.HOME | path join ".config" "zellij" "themes")
  if (not ($theme_dir | path exists)) {
    print $"zlx theme picker: theme directory not found: ($theme_dir)"
    exit 1
  }

  let themes = (ls $theme_dir
    | where type == file
    | where name =~ "\\.kdl$"
    | get name
    | path basename
    | each {|n| $n | str replace ".kdl" "" }
    | sort)

  if (($themes | length) == 0) {
    print $"zlx theme picker: no .kdl themes found in ($theme_dir)"
    exit 1
  }

  let selected = (($themes | str join (char nl)) | ^fzf --prompt 'zellij theme> ' --height=50% --layout=reverse --border --exit-0)
  if ($selected | str trim) == "" {
    print "zlx theme picker: cancelled."
    exit 0
  }

  let cache_dir = ($env.HOME | path join ".cache")
  mkdir $cache_dir
  let selected_theme_file = ($cache_dir | path join "zlx-zellij-theme")
  ($selected | str trim) | save -f $selected_theme_file

  print $"zlx theme picker: selected '($selected)'"

  # Apply to current session if supported by this zellij build.
  try {
    ^zellij options --theme ($selected | str trim)
  }

  # Ask outer run.nu process to relaunch this session with the selected theme.
  let restart_flag = $"/tmp/zellix/restart-($session).flag"
  "" | save -f $restart_flag
  print $"zlx theme picker: restarting session '($session)' to apply theme..."
  ^zellij kill-session $session
}
