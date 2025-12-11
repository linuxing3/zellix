export def init-terminal [] {}

def main [] {
  let choice = ([ st kitty xterm deepin-terminal lxterm ] | input list )
  $choice
}
