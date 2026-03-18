#!/usr/bin/env nu

def setup-files [session] {
  let path = "/tmp/zellix/" + $session

  # Ensure the session folder actually got deleted
  try { rm -r $path }

  # Create the session folder.
  mkdir $path
}

def resolve-layout-path [layout_input: string, config_root: string] {
  let layout_value = $layout_input | str trim
  if ($layout_value | str starts-with "/") {
    $layout_value | path expand
  } else if ($layout_value | str starts-with "~") {
    $layout_value | path expand
  } else {
    ($config_root | path join $layout_value) | path expand
  }
}

export def configure-zellix-env [
  project_dir?: string,
  session_name?: string,
  config_dir?: string,
  layout_path?: string,
  open_path?: string
] {
  let requested_project = match $project_dir {
    null => $env.PWD,
    _ => $project_dir
  }
  let resolved_project = ($requested_project | path expand)

  if not ($resolved_project | path exists) {
    print "(ansi red)Error: project directory ($resolved_project) does not exist(ansi reset)"
    exit 1
  }

  cd $resolved_project

  let resolved_config_root = match $config_dir {
    null => ([ $env.HOME ".config" "zellix" ] | path join),
    _ => $config_dir
  }
  let resolved_config_root = $resolved_config_root | path expand

  $env.ZELLIX_PATH = $resolved_config_root
  $env.ZELLIX_PROJECT_DIR = $resolved_project
  $env.ZELLIX_PROJECT_ROOT = $resolved_project

  let session = match $session_name {
    null => (random chars --length 10),
    _ => $session_name
  }
  $env.ZELLIX_SESSION = $session
  $env.ZELLIX_TMP = "/tmp/zellix/" + $session
  $env.ZELLIX_MOD = $env.ZELLIX_PATH + "/plugins"
  $env.YAZI_CONFIG_HOME = $env.ZELLIX_MOD + "/config/yazi"
  $env.ZK_NOTEBOOK_DIR = "~/notebooks"
  $env.NNN_BOOKMARK_DIR = "/bookmarks"

  let layout_input = ($layout_path | default "")
  let layout_target = if (($layout_input | str trim | is-empty) == true) {
    ($env.ZELLIX_PATH | path join "config" "zellij" "layout.kdl")
  } else {
    resolve-layout-path $layout_input $env.ZELLIX_PATH
  }

  let config_file = ($env.ZELLIX_PATH | path join "config" "zellij" "config.kdl")

  let open_target = match $open_path {
    null => "",
    _ => ($open_path | path expand)
  }
  $env.ZELLIX_OPEN = $open_target

  {
    session: $session,
    layout: $layout_target,
    config: $config_file
  }
}

def print-usage [] {
  print "Usage: zlx [-d <project-dir>] [-s <session-name>] [-c <config-root>] [-l <layout>] [path-to-open]"
  print "  -d  Project directory to start the session in (defaults to current working directory)"
  print "  -s  Optional zellij session name (random if omitted)"
  print "  -c  Path to the zellix configuration root (defaults to ~/.config/zellix)"
  print "  -l  Layout file to load (defaults to config/zellij/layout.kdl inside the config root)"
  print "  -h, --help  Show this help text"
}

def parse-tokens [tokens: list<string>, state: record] {
  if (($tokens | length) == 0) {
    $state
  } else {
    let current = ($tokens | get 0)
    match $current {
      "-h" | "--help" => {
        print-usage
        exit 0
      }
      "-d" => {
        if (($tokens | length) < 2) {
          print "(ansi red)Error: missing value for -d option(ansi reset)"
          exit 1
        }
        let next_state = ($state | merge { project_dir: ($tokens | get 1) })
        parse-tokens ($tokens | skip 2) $next_state
      }
      "-s" => {
        if (($tokens | length) < 2) {
          print "(ansi red)Error: missing value for -s option(ansi reset)"
          exit 1
        }
        let next_state = ($state | merge { session_name: ($tokens | get 1) })
        parse-tokens ($tokens | skip 2) $next_state
      }
      "-c" => {
        if (($tokens | length) < 2) {
          print "(ansi red)Error: missing value for -c option(ansi reset)"
          exit 1
        }
        let next_state = ($state | merge { config_dir: ($tokens | get 1) })
        parse-tokens ($tokens | skip 2) $next_state
      }
      "-l" => {
        if (($tokens | length) < 2) {
          print "(ansi red)Error: missing value for -l option(ansi reset)"
          exit 1
        }
        let next_state = ($state | merge { layout_path: ($tokens | get 1) })
        parse-tokens ($tokens | skip 2) $next_state
      }
      _ => {
        let next_positional = ($state.positional | append $current)
        let next_state = ($state | merge { positional: $next_positional })
        parse-tokens ($tokens | skip 1) $next_state
      }
    }
  }
}

def parse-cli [...rest] {
  let initial_state = {
    project_dir: null,
    session_name: null,
    config_dir: null,
    layout_path: null,
    positional: []
  }
  let final_state = parse-tokens $rest $initial_state

  let open_path = if ($final_state.positional | length) > 0 { ($final_state.positional | get 0) } else { null }
  let fallback_session = if ($final_state.positional | length) > 1 { ($final_state.positional | get 1) } else { null }
  let fallback_config = if ($final_state.positional | length) > 2 { ($final_state.positional | get 2) } else { null }

  let final_session = match $final_state.session_name {
    null => $fallback_session,
    _ => $final_state.session_name
  }
  let final_config = match $final_state.config_dir {
    null => $fallback_config,
    _ => $final_state.config_dir
  }

  {
    project_dir: $final_state.project_dir,
    session: $final_session,
    config_dir: $final_config,
    layout: $final_state.layout_path,
    open_path: $open_path
  }
}

export def run-zellix [
  project_dir?: string,
  session?: string,
  config_dir?: string,
  layout?: string,
  open_path?: string
] {
  let env_info = configure-zellix-env $project_dir $session $config_dir $layout $open_path
  setup-files $env_info.session
  zellij -s $env_info.session -n $env_info.layout -c $env_info.config
  try { rm -r $env.ZELLIX_TMP }
  print "(ansi cb)Thank you for using Zellix!(ansi reset)"
}
def main [
  --directory: string,
  --session: string,
  --config: string,
  --layout: string,
  ...rest
] {
  if (($env.ZELLIX_MAIN_DISABLED? | default "") != "") {
    return
  }

  let tokens = []
  let tokens = if (($directory | default "") != "") {
    ($tokens | append "-d" | append $directory)
  } else {
    $tokens
  }
  let tokens = if (($session | default "") != "") {
    ($tokens | append "-s" | append $session)
  } else {
    $tokens
  }
  let tokens = if (($config | default "") != "") {
    ($tokens | append "-c" | append $config)
  } else {
    $tokens
  }
  let tokens = if (($layout | default "") != "") {
    ($tokens | append "-l" | append $layout)
  } else {
    $tokens
  }
  let tokens = ($tokens | concat $rest)

  let options = parse-cli $tokens
  run-zellix $options.project_dir $options.session $options.config_dir $options.layout $options.open_path
}
