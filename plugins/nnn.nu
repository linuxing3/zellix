# This is an example system to allow for the use of nnn as a
# filepicker that supports multiple files, opening folders,
# and re-opening the picker at the current path instead of the root project path.

# This command can not do anything that would be temporary.
# Example: Adding an Environment Variable here would not persist.
export def init-nnn [] {
   $env.NNN_OPENNER = "hx"
}

use helpers.nu *

def main [] {

  # Open nnn at the current path
  let paths = nnn -p -

  # Split the files by rows.
  let command = ($paths | each {|line| $line | split row "\n"})

  # Check if no files were selected, and exit if none are.
  if ($command | get 0 | str trim | is-empty) {
    exit 0
  }

  # last file dirname
  let last_dirname = $command | last | path dirname
  let cd = ":cd " + $last_dirname

  # Join the list of filepaths we had above to support writing the paths to helix.
  let command_str = $command | str join " "

  # Set up the string for the actual command.
  let run = ":open " + $command_str

  if $command != "" and $run != "" {
    send-to-helix $run $cd
  } else {
    exit 0
  }

}
