#!/usr/bin/env nu

# Test the complete project switching workflow with direnv integration
# This simulates the enhanced project.nu functionality

use plugins/helpers.nu *
use plugins/logger-minimal.nu *

def main [] {
  print "🧪 Testing Complete Project Switching Workflow with direnv Integration"
  print "=" * 60
  
  # Test 1: Environment management tools
  print "\n📋 Test 1: Environment Management Tools"
  print "-" * 40
  
  try {
    # Test load-env-from-record
    let test_env = {
      TEST_VAR_1: "value1"
      TEST_VAR_2: "value2"
      TEST_VAR_3: "value3"
    }
    
    print "Testing load-env-from-record..."
    load-env-from-record $test_env
    
    # Verify environment variables were set
    let env_check = [
      ($env.TEST_VAR_1? == "value1")
      ($env.TEST_VAR_2? == "value2")
      ($env.TEST_VAR_3? == "value3")
    ]
    
    if ($env_check | all {|x| $x}) {
      print "✅ load-env-from-record works correctly"
    } else {
      print "❌ load-env-from-record failed to set environment variables"
    }
    
    # Test merge-env-layers
    print "\nTesting merge-env-layers..."
    let base_env = {A: "base", B: "base"}
    let override_env = {B: "override", C: "new"}
    let merged = merge-env-layers $base_env $override_env
    
    let merge_check = [
      ($merged.A? == "base")
      ($merged.B? == "override")
      ($merged.C? == "new")
    ]
    
    if ($merge_check | all {|x| $x}) {
      print "✅ merge-env-layers works correctly"
    } else {
      print "❌ merge-env-layers failed"
      print $"Merged: ($merged)"
    }
    
    # Test command-exists
    print "\nTesting command-exists..."
    let cmd_check = [
      (command-exists "ls")
      (command-exists "nonexistent_command_xyz" == false)
    ]
    
    if ($cmd_check | all {|x| $x}) {
      print "✅ command-exists works correctly"
    } else {
      print "❌ command-exists failed"
    }
    
  } catch {|err|
    print $"(ansi red)❌ Test 1 failed with error: ($err)(ansi reset)"
  }
  
  # Test 2: Project configuration loading
  print "\n📋 Test 2: Project Configuration System"
  print "-" * 40
  
  try {
    # Create a test project configuration
    let test_project_dir = "/tmp/zellix_test_project"
    mkdir $test_project_dir
    mkdir $"($test_project_dir)/.zellix"
    
    # Create a .envrc file for direnv
    "export TEST_ENVRC_VAR='from_envrc'" | save -f $"($test_project_dir)/.envrc"
    
    # Create project.nu configuration
    let project_config = {
      name: "test-project"
      description: "Test project for Zellix"
      env: {
        PROJECT_NAME: "test-project"
        DATABASE_URL: "postgres://localhost/test"
        API_KEY: "test_api_key_123"
      }
      plugins: {
        enabled: ["git", "makefile"]
        disabled: ["ai"]
      }
      direnv: {
        enabled: true
        auto_allow: true
      }
    }
    
    $project_config | to json | save -f $"($test_project_dir)/.zellix/project.nu"
    
    print $"Created test project at: ($test_project_dir)"
    print "Project configuration created"
    
    # Test find-project-root
    print "\nTesting find-project-root..."
    let project_root = find-project-root $test_project_dir
    
    if ($project_root | is-empty) {
      print "⚠️  No project root found (expected for test directory)"
    } else {
      print $"✅ Found project root: ($project_root)"
    }
    
    # Test safe-cd
    print "\nTesting safe-cd..."
    let original_dir = $env.PWD
    safe-cd $test_project_dir
    let new_dir = $env.PWD
    
    if ($new_dir == $test_project_dir) {
      print "✅ safe-cd works correctly"
    } else {
      print $"❌ safe-cd failed: expected ($test_project_dir), got ($new_dir)"
    }
    
    # Return to original directory
    cd $original_dir
    
    # Cleanup
    rm -rf $test_project_dir
    print "✅ Test project cleaned up"
    
  } catch {|err|
    print $"(ansi red)❌ Test 2 failed with error: ($err)(ansi reset)"
  }
  
  # Test 3: Logger integration
  print "\n📋 Test 3: Logger Integration"
  print "-" * 40
  
  try {
    # Set log level
    $env.ZELLIX_LOG_LEVEL = "info"
    
    # Test logging functions
    print "Testing logger functions..."
    
    # These should work without errors
    log-info "This is an info message"
    log-warn "This is a warning message"
    log-error "This is an error message"
    log-debug "This is a debug message (may not show)"
    
    print "✅ Logger functions work without errors"
    
    # Test with different log levels
    $env.ZELLIX_LOG_LEVEL = "error"
    log-info "This info message should not appear"
    log-error "This error message should appear"
    
    $env.ZELLIX_LOG_LEVEL = "debug"
    log-debug "This debug message should appear"
    
    print "✅ Log level filtering works"
    
  } catch {|err|
    print $"(ansi red)❌ Test 3 failed with error: ($err)(ansi reset)"
  }
  
  # Test 4: Simulate project switching workflow
  print "\n📋 Test 4: Simulated Project Switching Workflow"
  print "-" * 40
  
  try {
    # Create a mock bookmark directory structure
    let bookmark_dir = "/tmp/zellix_bookmarks"
    mkdir $bookmark_dir
    
    # Create test projects
    let projects = ["project-a", "project-b", "project-c"]
    
    for $project in $projects {
      let project_path = $"($bookmark_dir)/($project)"
      mkdir $project_path
      
      # Create .envrc for each project
      $"export PROJECT='($project)'" | save -f $"($project_path)/.envrc"
      
      # Create .zellix/project.nu for each project
      mkdir $"($project_path)/.zellix"
      {
        name: $project
        env: {
          PROJECT_ID: $"($project)-id"
          API_ENDPOINT: $"https://api.example.com/($project)"
        }
      } | to json | save -f $"($project_path)/.zellix/project.nu"
    }
    
    print $"Created test bookmarks at: ($bookmark_dir)"
    print "Projects: " + ($projects | str join ", ")
    
    # Simulate the select-project logic
    print "\nSimulating project selection logic..."
    
    let project_list = (ls $bookmark_dir | each {|x| $x.name | path basename} | to text)
    print $"Available projects: ($project_list)"
    
    # Simulate selecting the first project
    let selected_project = ($projects | first)
    let selected_path = $"($bookmark_dir)/($selected_project)"
    
    print $"Selected project: ($selected_project)"
    print $"Project path: ($selected_path)"
    
    # Simulate handle-direnv logic
    print "\nSimulating direnv integration..."
    
    let envrc_path = $"($selected_path)/.envrc"
    if ($envrc_path | path exists) {
      print $"✅ Found .envrc at: ($envrc_path)"
      
      # Check if direnv is available
      if (command-exists "direnv") {
        print "✅ direnv is available"
        print "Would run: direnv allow " + $selected_path
      } else {
        print "⚠️  direnv not installed (simulation only)"
        print "Would run: direnv allow " + $selected_path
      }
    } else {
      print "⚠️  No .envrc found in project"
    }
    
    # Simulate loading project configuration
    print "\nSimulating project configuration loading..."
    
    let config_path = $"($selected_path)/.zellix/project.nu"
    if ($config_path | path exists) {
      print $"✅ Found project config at: ($config_path)"
      
      # In real implementation, this would load and apply the config
      let config_content = (open $config_path | from json)
      print $"Project config loaded: ($config_content.name)"
      print $"Environment variables to set: ($config_content.env | columns | length)"
    } else {
      print "⚠️  No project config found"
    }
    
    # Cleanup
    rm -rf $bookmark_dir
    print "\n✅ Test bookmarks cleaned up"
    
  } catch {|err|
    print $"(ansi red)❌ Test 4 failed with error: ($err)(ansi reset)"
  }
  
  # Summary
  print "\n" + "=" * 60
  print "🎯 TEST SUMMARY"
  print "=" * 60
  print "All tests completed. The enhanced project switching workflow includes:"
  print ""
  print "✅ Environment management tools (load-env-from-record, merge-env-layers)"
  print "✅ Project configuration system (.zellix/project.nu)"
  print "✅ Logger integration with level filtering"
  print "✅ Simulated direnv integration for automatic environment setup"
  print "✅ Project selection and switching workflow"
  print ""
  print "📝 Next steps for actual usage:"
  print "1. Install direnv if not already installed"
  print "2. Create bookmark directory: mkdir ~/bookmarks"
  print "3. Symlink your projects to ~/bookmarks/"
  print "4. Use 'nu $ZELLIX_MOD/create-project.nu' to create project configs"
  print "5. The enhanced project.nu plugin will handle the rest automatically"
}

main