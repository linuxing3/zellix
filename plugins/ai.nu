export def init-ai [] {}

def --wrapped main [...args] {
  zellij run -c -f -- aider ...$args
}

def --wrapped "main pane" [...args] {
  zellij run -c -d right -- aider ...$args
}
