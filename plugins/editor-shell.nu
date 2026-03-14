#!/usr/bin/env nu

def main [startup_command?: string] {
  let zdotdir = ($env.ZELLIX_TMP | path join "zsh-sync")
  mkdir $zdotdir

  let rc_path = ($zdotdir | path join ".zshrc")
  let user_rc = ($env.HOME | path join ".zshrc")
  let sync_hook = ($env.ZELLIX_PATH | path join "plugins" "zsh-cwd-sync.zsh")

  mut rc_lines = []
  if ($user_rc | path exists) {
    $rc_lines = ($rc_lines | append $"source ($user_rc)")
  }
  $rc_lines = ($rc_lines | append $"source ($sync_hook)")
  ($rc_lines | str join (char nl) | str trim | $"($in)\n") | save -f $rc_path

  let launch_cwd = if (($env.ZELLIX_TMP? | default "") != "") {
    let ai_cwd_file = ($env.ZELLIX_TMP | path join "ai-dev-cwd")
    if ($ai_cwd_file | path exists) {
      let candidate = (open $ai_cwd_file | str trim)
      if ($candidate != "" and ($candidate | path type) == "dir") {
        $candidate
      } else {
        $env.PWD
      }
    } else {
      $env.PWD
    }
  } else {
    $env.PWD
  }

  with-env { ZDOTDIR: $zdotdir } {
    if ($launch_cwd != $env.PWD) {
      cd $launch_cwd
    }

    if ($startup_command | is-empty) {
      ^zsh -i
    } else {
      ^zsh -ic $startup_command
    }
  }
}
