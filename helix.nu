try { nu ($env.ZELLIX_MOD + "/init.nu") }

# Build helix args: optionally inject a themed config overlay.
let helix_theme = ($env.ZELLIX_HELIX_THEME? | default "")
let base_helix_config = ($env.HOME | path join ".config" "helix" "config.toml")

let theme_args = if ($helix_theme | is-not-empty) and ($base_helix_config | path exists) {
  let themed_config_path = ($env.ZELLIX_TMP | path join "helix-config.toml")
  let base_content = (open --raw $base_helix_config)
  let replacement = $"theme = \"($helix_theme)\""
  let themed_content = if ($base_content | str contains "theme = ") {
    $base_content | str replace -r '(?m)^\s*theme\s*=\s*".*"$' $replacement
  } else {
    [$replacement $base_content] | str join "\n"
  }
  $themed_content | save -f $themed_config_path
  ["-c" $themed_config_path]
} else {
  []
}

let open_args = if ($env.ZELLIX_OPEN | is-not-empty) { [$env.ZELLIX_OPEN] } else { [] }

^hx ...$theme_args ...$open_args

try { nu ($env.ZELLIX_MOD + "/exit.nu") }

zellij kill-session $env.ZELLIX_SESSION
