export def init-project [] {
}

def select-project [ ] {
  let project: string = nu -c $"ls ($env.NNN_BOOKMARK_DIR) | get name | input list"
  $"($project)"
}

def send-to-helix [ command: string ] {
  zellij action toggle-floating-panes # Select Helix In The System
  zellij action write 27 # Exit To Normal Mode
  zellij action write-chars $command # Write actual Command
  zellij action write 13 # Press Enter to run the command

  zellij action write 27 # Exit To Normal Mode
  zellij action write-chars ":sh direnv allow"# running direnv
  zellij action write 13 # Press Enter to run the command
} 

def main [] {
  let project: string = select-project

  if $project != "" {
    send-to-helix $":cd ($project)"
  } else {
    zellij action toggle-floating-panes # Select Helix In The System
  }
}
