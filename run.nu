#!/usr/bin/env nu

def setup-files [session: string] {
  let path = ("/tmp/zellix" | path join $session)
  try { rm -r $path }
  mkdir $path
}

def resolve-layout-path [layout_input: string, config_root: string] {
  let layout_value = ($layout_input | str trim)
  if ($layout_value | str starts-with "/" ) or ($layout_value | str starts-with "~") {
    $layout_value | path expand
  } else {
    $config_root | path join $layout_value | path expand
  }
}

export def --env configure-zellix-env [
  project_dir?: string,
  session_name?: string,
  config_dir?: string,
  layout_path?: string,
  open_path?: string,
] {
  let resolved_project = ($project_dir | default $env.PWD | path expand)

  if not ($resolved_project | path exists) {
    print $"(ansi red)Error: project directory ($resolved_project) does not exist(ansi reset)"
    exit 1
  }

  cd $resolved_project

  let resolved_config_root = ($config_dir | default ($env.HOME | path join ".config" "zellix") | path expand)

  $env.ZELLIX_PATH = $resolved_config_root
  $env.ZELLIX_PROJECT_DIR = $resolved_project
  $env.ZELLIX_PROJECT_ROOT = $resolved_project

  let session = ($session_name | default (random chars --length 10))
  $env.ZELLIX_SESSION = $session
  $env.ZELLIX_TMP = ("/tmp/zellix" | path join $session)
  $env.ZELLIX_MOD = ($resolved_config_root | path join "plugins")
  $env.YAZI_CONFIG_HOME = ($resolved_config_root | path join "plugins" "config" "yazi")
  $env.ZK_NOTEBOOK_DIR = "~/notebooks"
  $env.NNN_BOOKMARK_DIR = "/bookmarks"

  let layout_target = if ($layout_path | default "" | str trim | is-empty) {
    $resolved_config_root | path join "config" "zellij" "layout.kdl"
  } else {
    resolve-layout-path $layout_path $resolved_config_root
  }

  let config_file = ($resolved_config_root | path join "config" "zellij" "config.kdl")
  $env.ZELLIX_OPEN = ($open_path | default "" | if ($in | is-not-empty) { $in | path expand } else { "" })

  {
    session: $session,
    layout: $layout_target,
    config: $config_file,
  }
}

export def --env run-zellix [
  project_dir?: string,
  session?: string,
  config_dir?: string,
  layout?: string,
  open_path?: string,
] {
  let env_info = (configure-zellix-env $project_dir $session $config_dir $layout $open_path)
  setup-files $env_info.session
  zellij -s $env_info.session -n $env_info.layout -c $env_info.config
  try { rm -r $env.ZELLIX_TMP }
  print $"(ansi cb)Thank you for using Zellix!(ansi reset)"
}

def main [
  --directory (-d): string  # Project directory (defaults to cwd)
  --session (-s): string    # Zellij session name (random if omitted)
  --config (-c): string     # Zellix config root (defaults to ~/.config/zellix)
  --layout (-l): string     # Layout file (defaults to config/zellij/layout.kdl)
  open_path?: string        # File to open in Helix
] {
  if ($env.ZELLIX_MAIN_DISABLED? | default "" | is-not-empty) { return }

  run-zellix $directory $session $config $layout $open_path
}
