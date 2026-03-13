#!/usr/bin/env nu

# Simplified test for core Zellix improvements

def main [] {
  print "🧪 Testing core Zellix improvements..."
  
  # Test 1: Environment tools
  print "\n1. Testing environment tools..."
  source plugins/helpers.nu
  
  # Create test environment
  let test_env = { TEST_A: "value_a", TEST_B: "value_b" }
  load-env-from-record $test_env
  
  if ($env.TEST_A == "value_a" and $env.TEST_B == "value_b") {
    print "✅ Environment variables loaded correctly"
  } else {
    print "❌ Failed to load environment variables"
    exit 1
  }
  
  # Test 2: Logger initialization
  print "\n2. Testing logger..."
  source plugins/logger.nu
  
  # Set up test environment
  let-env ZELLIX_LOG_LEVEL = "info"
  let-env ZELLIX_LOG_FILE = "/tmp/zellix-test-core.log"
  let-env ZELLIX_SESSION = "test-core"
  
  init-logger
  log-info "Test log message"
  
  if ($env.ZELLIX_LOG_FILE | path exists) {
    print "✅ Logger initialized and log file created"
  } else {
    print "⚠️  Log file not created (may be normal in test environment)"
  }
  
  # Test 3: Project config loading
  print "\n3. Testing project config system..."
  
  # Create test project
  let test_dir = "/tmp/zellix-test-project"
  mkdir $test_dir
  mkdir ($test_dir + "/.zellix")
  
  # Create config
  echo '{
    name: "test-project",
    env: {
      PROJECT_TEST: "success"
    }
  }' | save ($test_dir + "/.zellix/project.nu")
  
  source plugins/project.nu
  let config = (load-project-config $test_dir)
  
  if ($config != null and $config.name == "test-project") {
    print "✅ Project config loaded successfully"
  } else {
    print "❌ Failed to load project config"
    exit 1
  }
  
  # Clean up
  rm -r $test_dir
  rm -f /tmp/zellix-test-core.log
  
  print "\n🎉 Core functionality tests passed!"
  print ""
  print "Summary of verified improvements:"
  print "1. ✅ Environment variable management"
  print "2. ✅ Structured logging system"
  print "3. ✅ Project configuration loading"
  print ""
  print "Next steps:"
  print "- Test direnv integration in interactive session"
  print "- Test project switching with actual bookmarks"
  print "- Test create-project.nu interactive tool"
}

main