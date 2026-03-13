export def init-project [] {
}

def select-project [] {
  # Get list of bookmark names (just basenames, no table formatting)
  try {
    let project_list = (ls ($env.NNN_BOOKMARK_DIR) | each {|x| $x.name | path basename} | to text)
    
    # Use fzf to select a project (clean output without table borders)
    let selected = ($project_list | fzf | str trim)
    
    # Return the full path to the selected project
    if ($selected | is-empty) {
      ""
    } else {
      realpath ($env.NNN_BOOKMARK_DIR)/($selected)
    }
  } catch {
    ""
  }
}

use helpers.nu *

def main [] {
  let project_path = select-project
  
  if ($project_path | is-empty) {
    exit 0
  } else {
    send-to-helix "" $project_path
    helix-file-picker 
  }
}
