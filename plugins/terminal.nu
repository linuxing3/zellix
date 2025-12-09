export def init-terminal [] {}

def main [] {
  let choice = ([ st kitty xterm deepin ] | input list )
  st -e $choice
}
