export def init-zk [] {
}

def generate-command [ ] {

  mut command_list = [ "xmodmap" ("~/.config/X11/xmodmap" | path expand) ] | str join " "

  $command_list
}

def main [] {

  let command_str: string = generate-command 
  print $"(ansi cb)Command: ($command_str)(ansi reset)"
  nu -c $command_str

  print $"(ansi cb)Done!(ansi reset)"
}
