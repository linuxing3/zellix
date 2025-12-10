# This is an example system to allow for the use of yazi as a
# filepicker that supports multiple files, opening folders,
# and re-opening the picker at the current path instead of the root project path.

# This command can not do anything that would be temporary.
# Example: Adding an Environment Variable here would not persist.
export def init-yazi [] {
}

def main [] {

  # Quit floating to shell
  zellij action toggle-floating-panes

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
