export def init-ai [] {}

def main [] {
  if (($env.ZELLIX_TMP? | default "") == "") {
    zsh -ic cursor-agent
    return
  }

  mkdir $env.ZELLIX_TMP
  let ai_cwd_file = ($env.ZELLIX_TMP | path join "ai-dev-cwd")
  $env.PWD | save -f $ai_cwd_file

  with-env { ZELLIX_AI_PANE: "1" } {
    nu ($env.ZELLIX_PATH | path join "plugins" "editor-shell.nu") "cursor-agent"
  }
}
