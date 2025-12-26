export def init-zk [] {
}

use helpers.nu *

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

def main [] {
  let command_list: list = generate-command
  let command_str: string = $command_list | str join " "
  print $"(ansi cb)Command: ($command_str)(ansi reset)"
  nu -c $command_str

  send-to-helix "" "~/notebooks"

}
