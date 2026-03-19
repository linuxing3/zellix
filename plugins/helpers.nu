
# ── Internal: Zellij → Helix keystroke helpers ──

def helix-escape [] {
  zellij action write 27
}

def helix-enter [] {
  zellij action write 13
}

def helix-run-cmd [command: string] {
  zellij action write-chars $command
  helix-enter
}

def helix-cd [dir: string] {
  let escaped = ($dir | str replace -a '\' '\\' | str replace -a '"' '\"')
  helix-run-cmd $":cd \"($escaped)\""
}

# Restart the right-side AI pane so its cwd follows the project switch.
# Opt out by setting ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH=false.
def sync-ai-pane [cwd: string] {
  let enabled = ($env.ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH? | default true)
  if $enabled != true { return }

  zellij action move-focus right
  zellij action close-pane
  zellij action new-pane -d right --cwd $cwd -- nu -c $"nu ($env.ZELLIX_PATH + '/plugins/ai.nu')"
  zellij action move-focus left
}

# ── Public: Send commands to Helix ──

export def send-to-helix [command: string, cd?: string] {
  zellij action toggle-floating-panes
  helix-escape

  if ($cd | default "" | is-not-empty) {
    helix-cd $cd
    sync-ai-pane $cd
  }

  if ($command | is-not-empty) {
    helix-run-cmd $command
  }
}

export def send-to-helix-no-floating [command: string, cd?: string] {
  zellij action move-focus up
  helix-escape

  if ($cd | default "" | is-not-empty) {
    helix-cd $cd
    if ($command | is-not-empty) { helix-run-cmd $command }
    sync-ai-pane $cd
  }

  zellij action move-focus down
  zellij action close-pane
}

# ── Environment Management Utilities ──

export def load-env-from-record [env_record: record] {
  load-env $env_record
}

export def merge-env-layers [layers: list<record>] {
  $layers
  | sort-by priority
  | where { $in.env? != null }
  | get env
  | reduce -f {} {|it, acc| $acc | merge $it }
}

export def command-exists [cmd: string] {
  try { which $cmd | is-not-empty } catch { false }
}

export def safe-cd [dir: string] {
  if ($dir | path exists) {
    cd $dir
    print $"Changed to directory: ($dir)"
    true
  } else {
    print $"(ansi red)Error: Directory ($dir) does not exist(ansi reset)"
    false
  }
}

export def find-project-root [start_dir?: string] {
  let current_dir = ($start_dir | default $env.PWD)
  let markers = [".git" ".project" ".envrc" ".zellix"]
  mut dir = $current_dir

  while $dir != "/" {
    let d = $dir
    let found = ($markers | any {|m| $d | path join $m | path exists })
    if $found { return $dir }
    $dir = ($dir | path dirname)
  }

  $current_dir
}
