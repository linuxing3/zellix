use logger-minimal.nu *

export def init-project [] {
  log-info "Project manager initialized"
}

def select-project [] {
  try {
    let configured = ($env.NNN_BOOKMARK_DIR? | default "" | if ($in | is-not-empty) { $in | path expand } else { "" })
    let bookmark_dir = if ($configured | is-not-empty) and ($configured | path exists) {
      $configured
    } else {
      "~/bookmarks" | path expand
    }

    if not ($bookmark_dir | path exists) {
      print $"(ansi yellow)Warning: Bookmark directory ($bookmark_dir) does not exist.(ansi reset)"
      print "Creating directory..."
      mkdir $bookmark_dir
    }

    let project_entries = (
      ls $bookmark_dir
      | where type in ["dir", "symlink"]
      | each {|x|
          let name = ($x.name | path basename)
          let resolved = (try { realpath $x.name } catch { "" })
          if ($resolved | is-not-empty) and ($resolved | path exists) {
            { name: $name, path: $resolved }
          } else {
            null
          }
        }
      | compact
    )

    if ($project_entries | is-empty) {
      print $"(ansi yellow)No projects found in ($bookmark_dir). Add symlinks or directories there.(ansi reset)"
      return ""
    }

    let selected = ($project_entries | get name | to text | fzf --prompt="Select project: " | str trim)

    if ($selected | is-empty) {
      ""
    } else {
      $project_entries | where name == $selected | get path.0? | default ""
    }
  } catch {|err|
    print $"(ansi red)Error selecting project: ($err)(ansi reset)"
    ""
  }
}

def handle-direnv [project_path: string] {
  if ($project_path | is-empty) { return }

  let envrc_path = ($project_path | path join ".envrc")

  if ($envrc_path | path exists) {
    print $"(ansi green)Found .envrc at ($project_path)(ansi reset)"
    cd $project_path
    try {
      direnv allow
      print "direnv allowed successfully"
    } catch {|err|
      print $"(ansi yellow)Warning: direnv allow failed: ($err)(ansi reset)"
    }
  } else {
    print $"(ansi blue)No .envrc found at ($project_path)(ansi reset)"
    print "You can create one with: echo 'use flake' > .envrc"
  }
}

def load-project-config [project_path: string] {
  if ($project_path | is-empty) { return null }

  let config_path = ($project_path | path join ".zellix" "project.nu")

  if ($config_path | path exists) {
    try {
      let config = (open --raw $config_path | from nuon)
      print $"(ansi green)Loaded project config from ($config_path)(ansi reset)"
      $config
    } catch {|err|
      print $"(ansi yellow)Warning: Failed to load project config: ($err)(ansi reset)"
      null
    }
  } else {
    print $"(ansi blue)No project config found at ($config_path)(ansi reset)"
    null
  }
}

use helpers.nu *

def main [] {
  let project_path = select-project

  if ($project_path | is-empty) {
    print "No project selected"
    exit 0
  }

  print $"(ansi cyan)Selected project: ($project_path)(ansi reset)"

  handle-direnv $project_path

  let project_config = load-project-config $project_path

  if ($project_config != null) {
    if ($project_config | get --optional env | is-not-empty) and ($project_config.env | describe | str contains "record") {
      use helpers.nu load-env-from-record
      load-env-from-record $project_config.env
      print $"Set ($project_config.env | columns | length) project-specific environment variables"
    }
  }

  send-to-helix ":e ." $project_path
}
