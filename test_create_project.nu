#!/usr/bin/env nu

# Test create-project.nu functionality

def main [] {
  print "Testing create-project.nu..."
  
  source plugins/create-project.nu
  
  # Test with mock data
  let test_project_info = {
    name: "test-project",
    description: "A test project",
    env: {
      DATABASE_URL: "postgres://localhost/test",
      API_KEY: "test_key_123"
    },
    enabled_plugins: ["git", "makefile", "justfile"],
    disabled_plugins: ["ai"]
  }
  
  # Create test directory
  let test_dir = "/tmp/zellix-test-create-" + (random chars --length 8)
  mkdir $test_dir
  cd $test_dir
  
  print $"Test directory: ($test_dir)"
  
  # Create config
  let config_file = (create-project-config $test_project_info)
  
  if ($config_file | path exists) {
    print $"✅ Config file created: ($config_file)"
    
    # Check content
    let content = (open $config_file)
    print $"Config content preview:"
    print ($content | lines | first 10 | str join "\n")
    
    # Clean up
    cd /
    rm -r $test_dir
    print "✅ Test completed successfully"
  } else {
    print "❌ Config file not created"
    exit 1
  }
}

main