export def init-create-project [] {}

use helpers.nu *

def get-project-info [] {
  print $"(ansi cyan)=== Zellix Project Configuration Creator ===(ansi reset)"
  print ""

  let project_name = (input "Project name: " | str trim)
  if ($project_name | is-empty) {
    print $"(ansi red)Error: Project name is required(ansi reset)"
    exit 1
  }

  let description = (input "Project description (optional): " | str trim)

  print ""
  print $"(ansi yellow)Environment Variables Configuration(ansi reset)"
  print "Enter environment variables (key=value), empty line to finish:"

  mut env_vars = {}
  mut count = 0

  while true {
    let input_line = (input $"Env var [($count + 1)]: " | str trim)
    if ($input_line | is-empty) { break }

    let parts = ($input_line | split row "=")
    if ($parts | length) >= 2 {
      let key = ($parts | get 0 | str trim)
      let value = ($parts | range 1.. | str join "=" | str trim)
      if ($key | is-not-empty) {
        $env_vars = ($env_vars | insert $key $value)
        $count = $count + 1
        print $"  Added: ($key)=($value)"
      }
    }
  }

  print ""
  print $"(ansi yellow)Plugin Selection(ansi reset)"
  print "Available plugins: git, makefile, justfile, terminal, ai, yazi, nnn, markdown, tangle, zk, home-manager, neomutt, remap, sh"

  let plugin_input = (input "Enabled plugins (comma-separated, default: git,makefile,justfile,terminal): " | str trim)
  let enabled_plugins = if ($plugin_input | is-empty) {
    ["git" "makefile" "justfile" "terminal"]
  } else {
    $plugin_input | split row "," | each {|p| $p | str trim }
  }

  let disabled_input = (input "Disabled plugins (comma-separated, optional): " | str trim)
  let disabled_plugins = if ($disabled_input | is-empty) {
    []
  } else {
    $disabled_input | split row "," | each {|p| $p | str trim }
  }

  {
    name: $project_name,
    description: $description,
    env: $env_vars,
    enabled_plugins: $enabled_plugins,
    disabled_plugins: $disabled_plugins,
  }
}

def create-project-config [project_info: record] {
  let config_dir = ".zellix"
  let config_file = ($config_dir | path join "project.nu")

  if not ($config_dir | path exists) {
    mkdir $config_dir
    print $"Created directory: ($config_dir)"
  }

  let env_lines = ($project_info.env | columns | each {|key|
    let value = ($project_info.env | get $key)
    $"    ($key): \"($value)\","
  })

  let enabled_str = ($project_info.enabled_plugins | each {|p| $"\"($p)\""} | str join ", ")
  let disabled_str = ($project_info.disabled_plugins | each {|p| $"\"($p)\""} | str join ", ")

  let config_content = ([
    "{"
    $"  name: \"($project_info.name)\","
    $"  description: \"($project_info.description)\","
    "  env: {"
    ...($env_lines)
    "  },"
    "  plugins: {"
    $"    enabled: [($enabled_str)],"
    $"    disabled: [($disabled_str)],"
    "  },"
    "  commands: {"
    "    build: \"echo 'Add your build command here'\","
    "    test: \"echo 'Add your test command here'\","
    "    run: \"echo 'Add your run command here'\","
    "  },"
    "}"
  ] | str join "\n")

  $config_content | save $config_file
  print $"(ansi green)Project configuration created at ($config_file)(ansi reset)"
  print ""
  print "Next steps:"
  print "1. Review and edit the configuration file"
  print "2. Add project-specific commands and settings"
  print "3. Use 'project.nu' plugin to switch to this project"
  print "4. Consider creating a .envrc file for direnv integration"

  $config_file
}

def main [] {
  let project_info = get-project-info

  print ""
  print $"(ansi cyan)=== Configuration Summary ===(ansi reset)"
  print $"Project: ($project_info.name)"
  print $"Description: ($project_info.description)"
  print $"Environment variables: ($project_info.env | columns | length)"
  print $"Enabled plugins: ($project_info.enabled_plugins | str join ', ')"
  print $"Disabled plugins: ($project_info.disabled_plugins | str join ', ')"

  print ""
  let confirm = (input "Create project configuration? (y/N): " | str trim | str downcase)

  if $confirm == "y" or $confirm == "yes" {
    create-project-config $project_info
  } else {
    print "Configuration creation cancelled"
  }
}
