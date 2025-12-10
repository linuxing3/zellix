export def init-project [] {
}

def select-project [ ] {
  let project: string = nu -c $"ls ($env.NNN_BOOKMARK_DIR) | get name | input list"
  $"($project)"
}

use helpers.nu *

def main [] {
  let project: string = select-project

  if $project != "" {
    send-to-helix $":cd ($project)"
  } else {
    exit 0
  }
}
