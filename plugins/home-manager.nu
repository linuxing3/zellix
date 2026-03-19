export def init-hm [] {}

def main [] {
  let choice = (["switch" "build"] | input list)
  print $"You chose: ($choice)"
  let flake = "/home/Designers/.config/home-manager"
  let command = match $choice {
    "switch" => $"home-manager switch -b b --flake ($flake)",
    "build" => $"home-manager build -b b --flake ($flake)",
    _ => ""
  }
  if ($command | is-not-empty) { nu -c $command }
}
