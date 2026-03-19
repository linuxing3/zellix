#!/usr/bin/env nu

def main [startup_command?: string] {
  let zdotdir = ($env.ZELLIX_TMP | path join "zsh-sync")
  mkdir $zdotdir

  let rc_path = ($zdotdir | path join ".zshrc")
  let user_rc = ($env.HOME | path join ".zshrc")
  let sync_hook = ($env.ZELLIX_PATH | path join "plugins" "zsh-cwd-sync.zsh")

  let rc_lines = (
    [($user_rc | if ($in | path exists) { $"source ($in)" } else { null }),
     $"source ($sync_hook)"]
    | compact
    | str join (char nl)
  )
  $"($rc_lines)\n" | save -f $rc_path

  let launch_cwd = if ($env.ZELLIX_TMP? | default "" | is-not-empty) {
    let ai_cwd_file = ($env.ZELLIX_TMP | path join "ai-dev-cwd")
    if ($ai_cwd_file | path exists) {
      let candidate = (open $ai_cwd_file | str trim)
      if ($candidate | is-not-empty) and ($candidate | path type) == "dir" {
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
    if ($launch_cwd != $env.PWD) { cd $launch_cwd }

    if ($startup_command | default "" | is-empty) {
      ^zsh -i
    } else {
      ^zsh -ic $startup_command
    }
  }
}
