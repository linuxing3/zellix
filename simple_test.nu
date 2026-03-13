#!/usr/bin/env nu

# Simple test for helpers.nu

def main [] {
  print "Testing helpers.nu..."
  
  source plugins/helpers.nu
  
  # Test load-env-from-record
  let test_env = { TEST_VAR: "test_value" }
  load-env-from-record $test_env
  
  if ("TEST_VAR" in $env) {
    print $"✅ TEST_VAR = ($env.TEST_VAR)"
  } else {
    print "❌ TEST_VAR not found in environment"
  }
  
  # Test command-exists
  if (command-exists "ls") {
    print "✅ ls command exists"
  } else {
    print "❌ ls command not found"
  }
  
  if (not (command-exists "nonexistent_command_xyz")) {
    print "✅ nonexistent command correctly not found"
  } else {
    print "❌ nonexistent command incorrectly found"
  }
}

main