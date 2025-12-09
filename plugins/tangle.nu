# This is an example system to allow for the use of yazi as a
# filepicker that supports multiple files, opening folders,
# and re-opening the picker at the current path instead of the root project path.

# This command can not do anything that would be temporary.
# Example: Adding an Environment Variable here would not persist.
export def init-tangle [] {
   $env.YAZI_CONFIG_HOME = $env.ZELLIX_MOD + "/config/yazi"
}

def main [filepath] {
  # let dirname = filepath | path dirname
  # mkdir dirname

  doom +org tangle --all $filepath
}
