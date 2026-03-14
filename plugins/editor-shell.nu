#!/usr/bin/env nu

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

with-env { ZDOTDIR: $zdotdir } {
  ^zsh -i
}
