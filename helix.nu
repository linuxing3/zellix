try { nu ($env.ZELLIX_MOD + "/init.nu") }

# Open helix or the given filepath.
let helix_theme = if ("ZELLIX_HELIX_THEME" in $env) { $env.ZELLIX_HELIX_THEME } else { "" }
let base_helix_config = ($env.HOME | path join ".config" "helix" "config.toml")
mut hx_args = []

if ($helix_theme != "" and ($base_helix_config | path exists)) {
  let themed_config_path = ($env.ZELLIX_TMP | path join "helix-config.toml")
  let base_content = (open --raw $base_helix_config)
  let replacement = $"theme = \"($helix_theme)\""
  let has_theme = (($base_content | str contains "theme = "))
  let themed_content = if $has_theme {
    $base_content | str replace -r '(?m)^\s*theme\s*=\s*".*"$' $replacement
  } else {
    $replacement + "\n" + $base_content
  }
  $themed_content | save -f $themed_config_path
  $hx_args = ($hx_args | append ["-c" $themed_config_path])
}

if $env.ZELLIX_OPEN == "" {
  ^hx ...$hx_args
} else {
  ^hx ...$hx_args $env.ZELLIX_OPEN
}

# Run exit code for the selected modules
# This is a try block because exit.nu shouldn't be required
try { nu ($env.ZELLIX_MOD + "/exit.nu") }

# Kill the session, closing other panes as soon as helix closes
zellij kill-session $env.ZELLIX_SESSION
