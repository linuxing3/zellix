export def init-makefile [] {}

def main [] {
  let choice = ([ config config.h build clean install ] | input list )
  print $"You chose: ($choice)"
  let command = match $choice {
    "config" => "make config",
    "config.h" => "make clean && make config.h",
    "build" => "make build",
    "clean" => "make clean",
    "install" => "sudo make install",
    _ => "make all"
  }
  nu -c $command
}
