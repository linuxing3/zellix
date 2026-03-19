export def init-remap [] {}

def main [] {
  let xmodmap_path = ("~/.config/X11/xmodmap" | path expand)
  print $"(ansi cb)Command: xmodmap ($xmodmap_path)(ansi reset)"
  ^xmodmap $xmodmap_path
  print $"(ansi cb)Done!(ansi reset)"
}
