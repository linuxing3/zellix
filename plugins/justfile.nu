export def init-just [] {}

def main [] {
  let choice = ([ run build ] | input list )
  print $"You chose: ($choice)"
  let command = match $choice {
    "run" => "just run",
    "build" => "just build",
    _ => ""
  }
  nu -c $command
}
