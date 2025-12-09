export def init-hm [] {}

def main [] {
  let choice = ([ switch build ] | input list )
  let flake_dir = "/home/Designers/.config/home-manager"
  print $"You chose: ($choice)"
  let command = match $choice {
    "switch" => "home-manager switch -b b --flake /home/Designers/.config/home-manager",
    "build" => "home-manager build -b b --flake /home/Designers/.config/home-manager",
    _ => ""
  }
  nu -c $command
}
