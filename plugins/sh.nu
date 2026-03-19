export def init-sh [] {}

def main [] {
  zellij action move-focus up
  zellij action write-chars ":sh $@ "
  zellij action write 18   # Ctrl+R — select register
  zellij action write-chars '%'
  zellij action write 13   # Enter
}
