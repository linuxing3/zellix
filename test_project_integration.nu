#!/usr/bin/env nu

# Test script for enhanced project.nu functionality

def main [] {
  print "Testing enhanced project.nu integration..."
  
  # Source the project.nu file
  source plugins/project.nu
  
  # Test init-project
  print "\n1. Testing init-project:"
  init-project
  
  # Test select-project
  print "\n2. Testing select-project:"
  
  # First, ensure bookmark directory exists
  let bookmark_dir = "~/bookmarks" | path expand
  if not ($bookmark_dir | path exists) {
    mkdir $bookmark_dir
  }
  
  # Create a test project if it doesn't exist
  let test_project_path = $bookmark_dir + "/test-project"
  if not ($test_project_path | path exists) {
    mkdir $test_project_path
    echo "Test project created" | save ($test_project_path + "/README.md")
  }
  
  # Test the function
  try {
    let project_path = select-project
    print $"Selected project path: ($project_path)"
  } catch {|err|
    print $"Error in select-project: ($err)"
  }
  
  # Test handle-direnv with a test directory
  print "\n3. Testing handle-direnv:"
  let test_dir = "/tmp/test-direnv"
  mkdir $test_dir
  echo 'export TEST_VAR="direnv test"' | save ($test_dir + "/.envrc")
  
  handle-direnv $test_dir
  
  # Check if environment variable was set
  if ($env.TEST_VAR? != null) {
    print $"✅ TEST_VAR set: ($env.TEST_VAR)"
  } else {
    print "⚠️  TEST_VAR not set"
  }
  
  # Test load-project-config
  print "\n4. Testing load-project-config:"
  
  # Create a test project config
  let config_dir = $test_dir + "/.zellix"
  mkdir $config_dir
  echo '{
    name: "test-project",
    env: {
      PROJECT_TEST: "config test"
    }
  }' | save ($config_dir + "/project.nu")
  
  let config = load-project-config $test_dir
  if $config != null {
    print $"✅ Project config loaded: ($config)"
    if ($config.env? != null) {
      print $"   Environment variables: ($config.env)"
    }
  } else {
    print "⚠️  No project config loaded"
  }
  
  print "\n✅ All tests completed!"
}

main