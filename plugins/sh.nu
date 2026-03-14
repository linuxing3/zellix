export def init-sh[] {
}

def main [] {

  # Focus Helix pane without toggling floating panes
  zellij action move-focus up

  # write shell command
  zellij action write-chars ":"
  # write shell command
  zellij action write-chars "sh $@ "
  # ctrl +r to select registry
  zellij action write 18
  # paste from document path registry
  zellij action write-chars '%'
  # enter
  zellij action write 13
}
