
export def send-to-helix [ command: string, cd?: string ] {
  # Focus Helix pane directly to avoid flashing floating panes during project switch
  zellij action move-focus up
  zellij action write 27 # Exit To Normal Mode

  zellij action write-chars $command # Write actual Command
  zellij action write 13 # Press Enter to run the command

  if $cd != "" {
    let escaped = ($cd | str replace -a '\' '\\' | str replace -a '"' '\"')
    zellij action write-chars $":cd \"($escaped)\"" # Change to last file directory
    zellij action write 13 # Press Enter to run the command

    # Restart right-side AI pane to sync cwd after project switch.
    # Enabled by default; set ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH=false to opt out.
    if (($env.ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH? | default true) == true) {
      zellij action move-focus right
      zellij action close-pane
      ^zellij action new-pane -d right --cwd $cd -- nu -c $"nu ($env.ZELLIX_PATH + '/plugins/ai.nu')"
      zellij action move-focus left
    }
  }
} 

export def helix-file-picker [ ] {
  send-to-helix ":e ." ""
} 

# Environment Management Utilities

# Load environment variables from a record
export def load-env-from-record [env_record: record] {
  for $key in ($env_record | columns) {
    let value = ($env_record | get $key)
    $env | insert $key $value
  }
}

# Save current environment to a file
export def save-env-to-file [file_path: string] {
  let env_data = $env | to nuon
  $env_data | save $file_path
  print $"Environment saved to ($file_path)"
}

# Load environment from a file
export def load-env-from-file [file_path: string] {
  if ($file_path | path exists) {
    try {
      let env_data = (open $file_path)
      load-env-from-record $env_data
      print $"Environment loaded from ($file_path)"
    } catch {|err|
      print $"(ansi yellow)Warning: Failed to load environment from ($file_path): ($err)(ansi reset)"
    }
  }
}

# Merge multiple environment layers with priority
export def merge-env-layers [layers: list<record>] {
  # Sort by priority (ascending)
  let sorted_layers = ($layers | sort-by priority)
  
  # Merge layers, later (higher priority) overwrites earlier
  mut merged_env = {}
  
  for layer in $sorted_layers {
    if ($layer.env? != null) {
      $merged_env = ($merged_env | merge $layer.env)
    }
  }
  
  $merged_env
}

# Check if a command exists
export def command-exists [cmd: string] {
  try {
    which $cmd | length | $in > 0
  } catch {
    false
  }
}

# Safe directory change with logging
export def safe-cd [dir: string] {
  if ($dir | path exists) {
    cd $dir
    print $"Changed to directory: ($dir)"
    true
  } else {
    print $"(ansi red)Error: Directory ($dir) does not exist(ansi reset)"
    false
  }
}

# Get project root directory (looks for .git, .project, etc.)
export def find-project-root [start_dir?: string] {
  let current_dir = if ($start_dir != null) { $start_dir } else { $env.PWD }
  mut dir = $current_dir
  
  while $dir != "/" {
    let markers = [".git", ".project", ".envrc", ".zellix"]
    for marker in $markers {
      let marker_path = ($dir + "/" + $marker)
      if ($marker_path | path exists) {
        return $dir
      }
    }
    $dir = ($dir | path dirname)
  }
  
  $current_dir
}
