# Simplified project configuration creator

export def init-create-project [] {
  print "Project configuration creator initialized"
}

def get-project-info [] {
  print "=== Zellix Project Configuration Creator ==="
  print ""
  
  # Get project name
  let project_name = (input "Project name: " | str trim)
  if ($project_name | is-empty) {
    print "Error: Project name is required"
    exit 1
  }
  
  # Get project description
  let description = (input "Project description (optional): " | str trim)
  
  # Simple environment variables
  print ""
  print "Add environment variables (key=value), empty line to finish:"
  
  mut env_vars = {}
  mut count = 0
  
  while true {
    let input_line = (input $"Env var [($count + 1)]: " | str trim)
    if ($input_line | is-empty) {
      break
    }
    
    let parts = ($input_line | split row "=")
    if ($parts | length) >= 2 {
      let key = ($parts | get 0 | str trim)
      let value = ($parts | range 1.. | str join "=" | str trim)
      
      if not ($key | is-empty) {
        $env_vars = ($env_vars | insert $key $value)
        $count = $count + 1
        print $"  Added: ($key)=($value)"
      }
    }
  }
  
  # Simple plugin selection
  let enabled_plugins = ["git", "makefile", "justfile", "terminal"]
  
  {
    name: $project_name,
    description: $description,
    env: $env_vars,
    enabled_plugins: $enabled_plugins,
    disabled_plugins: [],
  }
}

def create-project-config [project_info: record] {
  let config_dir = ".zellix"
  let config_file = $config_dir + "/project.nu"
  
  # Create .zellix directory
  if not ($config_dir | path exists) {
    mkdir $config_dir
    print $"Created directory: ($config_dir)"
  }
  
  # Build simple configuration
  mut config_lines = []
  
  # Basic info
  $config_lines = ($config_lines | append $"  name: \"($project_info.name)\",")
  $config_lines = ($config_lines | append $"  description: \"($project_info.description)\",")
  
  # Environment variables
  $config_lines = ($config_lines | append "  env: {")
  for $key in ($project_info.env | columns) {
    let value = ($project_info.env | get $key)
    $config_lines = ($config_lines | append $"    ($key): \"($value)\",")
  }
  $config_lines = ($config_lines | append "  },")
  
  # Plugins
  $config_lines = ($config_lines | append "  plugins: {")
  let enabled_str = ($project_info.enabled_plugins | each {|p| $"\"($p)\""} | str join ", ")
  $config_lines = ($config_lines | append $"    enabled: [($enabled_str)],")
  $config_lines = ($config_lines | append "    disabled: [],")
  $config_lines = ($config_lines | append "  },")
  
  # Commands
  $config_lines = ($config_lines | append "  commands: {")
  $config_lines = ($config_lines | append "    build: \"echo 'Add build command'\",")
  $config_lines = ($config_lines | append "    test: \"echo 'Add test command'\",")
  $config_lines = ($config_lines | append "    run: \"echo 'Add run command'\",")
  $config_lines = ($config_lines | append "  },")
  
  # Combine
  let config_content = "{\n" + ($config_lines | str join "\n") + "\n}"
  
  # Save
  $config_content | save $config_file
  print $"✅ Project configuration created at ($config_file)"
  
  $config_file
}

def main [] {
  let project_info = get-project-info
  
  print ""
  print "=== Configuration Summary ==="
  print $"Project: ($project_info.name)"
  print $"Description: ($project_info.description)"
  print $"Environment variables: ($project_info.env | columns | length)"
  print $"Enabled plugins: ($project_info.enabled_plugins | str join ', ')"
  
  print ""
  let confirm = (input "Create project configuration? (y/N): " | str trim | str downcase)
  
  if $confirm == "y" or $confirm == "yes" {
    create-project-config $project_info
  } else {
    print "Configuration creation cancelled"
  }
}