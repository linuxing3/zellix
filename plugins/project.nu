# Zellix Project Manager with direnv integration
# Enhanced project switching with environment management

use logger-minimal.nu *

export def init-project [] {
  # Initialize project manager
  log-info "Project manager initialized"
}

# Select a project from bookmarks or custom directories
def select-project [] {
  # Get list of bookmark names (just basenames, no table formatting)
  try {
    # Check if NNN_BOOKMARK_DIR exists, otherwise use fallback
    let bookmark_dir = if ($env.NNN_BOOKMARK_DIR? != null and ($env.NNN_BOOKMARK_DIR | path exists)) {
      $env.NNN_BOOKMARK_DIR
    } else {
      # Fallback to home directory bookmarks
      "~/bookmarks" | path expand
    }
    
    if not ($bookmark_dir | path exists) {
      print $"(ansi yellow)Warning: Bookmark directory ($bookmark_dir) does not exist.(ansi reset)"
      print "Creating directory..."
      mkdir $bookmark_dir
    }
    
    let project_list = (ls $bookmark_dir | each {|x| $x.name | path basename} | to text)
    
    # Use fzf to select a project (clean output without table borders)
    let selected = ($project_list | fzf --prompt="Select project: " | str trim)
    
    # Return the full path to the selected project
    if ($selected | is-empty) {
      ""
    } else {
      realpath ($bookmark_dir)/($selected)
    }
  } catch {|err|
    print $"(ansi red)Error selecting project: ($err)(ansi reset)"
    ""
  }
}

# Handle direnv integration for project
def handle-direnv [project_path: string] {
  if ($project_path | is-empty) {
    return
  }
  
  let envrc_path = ($project_path + "/.envrc")
  
  if ($envrc_path | path exists) {
    print $"(ansi green)Found .envrc at ($project_path)(ansi reset)"
    
    # Change to project directory
    cd $project_path
    
    # Allow direnv if not already allowed
    try {
      direnv allow
      print "direnv allowed successfully"
    } catch {|err|
      print $"(ansi yellow)Warning: direnv allow failed: ($err)(ansi reset)"
    }
    
    # direnv will automatically load environment when we cd
    # No need to manually export and load
    
  } else {
    print $"(ansi blue)No .envrc found at ($project_path)(ansi reset)"
    print "You can create one with: echo 'use flake' > .envrc"
  }
}

# Load project-specific configuration
def load-project-config [project_path: string] {
  if ($project_path | is-empty) {
    return null
  }
  
  let config_path = ($project_path + "/.zellix/project.nu")
  
  if ($config_path | path exists) {
    try {
      let config = (open $config_path)
      print $"(ansi green)Loaded project config from ($config_path)(ansi reset)"
      $config
    } catch {|err|
      print $"(ansi yellow)Warning: Failed to load project config: ($err)(ansi reset)"
      null
    }
  } else {
    print $"(ansi blue)No project config found at ($config_path)(ansi reset)"
    null
  }
}

use helpers.nu *

def main [] {
  let project_path = select-project
  
  if ($project_path | is-empty) {
    print "No project selected"
    exit 0
  }
  
  print $"(ansi cyan)Selected project: ($project_path)(ansi reset)"
  
  # Handle direnv integration
  handle-direnv $project_path
  
  # Load project configuration
  let project_config = load-project-config $project_path
  
  # Set project-specific environment variables
  if ($project_config != null) {
    # Check if config has env field and it's a record
    if ($project_config | get --optional env | is-not-empty) and ($project_config.env | describe | str contains "record") {
      use helpers.nu load-env-from-record
      load-env-from-record $project_config.env
      print $"Set ($project_config.env | columns | length) project-specific environment variables"
    }
  }
  
  # Send to helix and open file picker
  send-to-helix "" $project_path
  helix-file-picker
}
