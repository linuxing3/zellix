export def init-project [] {
}

def select-project [ ] {
  let project: string = nu -c $"ls -al ($env.NNN_BOOKMARK_DIR) | get name | fzf | str substring 10..-4 | str trim"
  $"($project)"
}

use helpers.nu *

def main [] {
  let project: string = select-project
  let rpath = realpath ($project)

  if $project != "" {
    send-to-helix "" $"($rpath)"
    helix-file-picker 
  } else {
    exit 0
  }
}
