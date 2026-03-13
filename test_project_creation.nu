#!/usr/bin/env nu

# Non-interactive test for project creation

def main [] {
  print "Testing project creation..."
  
  # Create test directory
  let test_dir = "/tmp/zellix-test-proj-" + (random chars --length 8)
  mkdir $test_dir
  cd $test_dir
  
  print $"Test directory: ($test_dir)"
  
  # Create a simple project config manually
  let config_content = '{
    name: "test-project",
    description: "Test project for zellix",
    
    env: {
      DATABASE_URL: "postgres://localhost/test",
      API_KEY: "test_key_123",
      PROJECT_ROOT: "{{CWD}}"
    },
    
    plugins: {
      enabled: ["git", "makefile", "justfile"],
      disabled: ["ai"]
    },
    
    commands: {
      build: "echo building...",
      test: "echo testing...",
      run: "echo running..."
    }
  }'
  
  # Create .zellix directory and save config
  mkdir .zellix
  $config_content | save .zellix/project.nu
  
  print "✅ Project configuration created"
  
  # Test loading the config
  source plugins/project.nu
  let loaded_config = (load-project-config $test_dir)
  
  if ($loaded_config != null) {
    print $"✅ Config loaded successfully"
    print $"  Project name: ($loaded_config.name)"
    print $"  Environment variables: ($loaded_config.env | columns | length)"
    
    # Test environment variable loading
    if ($loaded_config.env? != null) {
      use helpers.nu load-env-from-record
      load-env-from-record $loaded_config.env
      
      if ("DATABASE_URL" in $env) {
        print $"✅ Environment variable loaded: DATABASE_URL=($env.DATABASE_URL)"
      }
    }
  } else {
    print "❌ Failed to load config"
  }
  
  # Clean up
  cd /
  rm -r $test_dir
  
  print "\n🎉 Project creation test completed!"
}

main