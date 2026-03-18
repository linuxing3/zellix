#!/usr/bin/env nu

# Test the fixed create-project-fixed.nu

def main [] {
  print "Testing create-project-fixed.nu..."
  
  # Test loading the module
  source ../plugins/create-project-fixed.nu
  
  # Test init function
  init-create-project
  
  # Create test data
  let test_info = {
    name: "test-project",
    description: "Test project",
    env: {
      DATABASE_URL: "postgres://localhost/test",
      API_KEY: "test123"
    },
    enabled_plugins: ["git", "makefile"],
    disabled_plugins: ["ai"]
  }
  
  # Create test directory
  let test_dir = "/tmp/zellix-fixed-test"
  mkdir $test_dir
  cd $test_dir
  
  print $"Test directory: ($test_dir)"
  
  # Test config creation
  let config_file = (create-project-config $test_info)
  
  if ($config_file | path exists) {
    print $"✅ Config file created: ($config_file)"
    
    # Show config content
    print "\nConfig content:"
    open $config_file | print
    
    # Clean up
    cd /
    rm -r $test_dir
    print "\n✅ Test completed successfully"
  } else {
    print "❌ Config file not created"
  }
}

main