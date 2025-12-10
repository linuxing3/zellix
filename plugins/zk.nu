export def init-zk [] {
}

def generate-category [ ] {
  
  let alias: string = nu -c $"cd ($env.ZK_NOTEBOOK_DIR) ; open .zk/config.toml | get alias | columns | input list"
  print $"(ansi cb)Category: ($alias)\n(ansi reset)"

  $"($alias)"
}

def pair-dirname [ ] {
  
  let alias: string = generate-category

  let dirname: string = match $alias {
    "daily" => "journal"
    "idea" => "ideas"
    _ => "misc"
  }

  $"($dirname)"
}

def generate-command [ ] {

  let dirname: string = pair-dirname

  mut command_list =  [ "cd" $env.ZK_NOTEBOOK_DIR ";" "zk" "new" $dirname ]
  if $dirname != "journal" {
    $command_list ++= [ "-t" (input "Input title: " | str kebab-case)]
  }

  $command_list
}

def run-in-helix [ command: string ] {
  
  zellij action toggle-floating-panes # Select Helix In The System
  zellij action write 27 # Exit To Normal Mode
  zellij action write-chars $command # Write actual Command
  zellij action write 13 # Press Enter to run the command
} 

def main [] {
  let command_list: list = generate-command
  let command_str: string = $command_list | str join " "
  print $"(ansi cb)Command: ($command_str)(ansi reset)"
  nu -c $command_str

  run-in-helix ":cd ~/notebooks"

}
