# Zellix Project Configuration
# This file defines project-specific settings for Zellix

{
  # Project metadata
  name: "project-name",
  version: "1.0.0",
  description: "Project description",
  
  # Environment variables
  env: {
    # Database configuration
    DATABASE_URL: "postgres://localhost:5432/db_name",
    REDIS_URL: "redis://localhost:6379",
    
    # API keys (use placeholders for secrets)
    API_KEY: "{{ENV_API_KEY}}",
    SECRET_KEY: "{{ENV_SECRET_KEY}}",
    
    # Project paths
    PROJECT_ROOT: "{{CWD}}",
    LOG_DIR: "{{CWD}}/logs",
    
    # Development settings
    RUST_ENV: "development",
    NODE_ENV: "development",
    DEBUG: "true",
    
    # Tool-specific variables
    EDITOR: "hx",
    PAGER: "bat",
  },
  
  # Plugin configuration
  plugins: {
    # Enabled plugins for this project
    enabled: [
      "git",
      "makefile", 
      "justfile",
      "terminal",
    ],
    
    # Disabled plugins (override global settings)
    disabled: [
      "ai",      # Disable AI panel for this project
      "neomutt", # Disable email client
    ],
    
    # Plugin-specific settings
    settings: {
      git: {
        auto_fetch: true,
        branch_display: true,
      },
      terminal: {
        default_shell: "zsh",
        open_nnn: true,
      },
    },
  },
  
  # Build and development commands
  commands: {
    build: "cargo build",
    test: "cargo test",
    run: "cargo run",
    watch: "cargo watch -x run",
    clean: "cargo clean",
    
    # Custom project commands
    deploy: "just deploy",
    migrate: "diesel migration run",
  },
  
  # Dependencies and tool versions
  dependencies: {
    nix: "./flake.nix",
    node: "./package.json",
    rust: "./Cargo.toml",
    python: "./requirements.txt",
  },
  
  # Project structure
  directories: {
    src: "./src",
    tests: "./tests",
    docs: "./docs",
    config: "./config",
  },
  
  # Editor settings
  editor: {
    formatter: "rustfmt",
    linter: "clippy",
    auto_format: true,
    line_length: 100,
  },
  
  # Session persistence
  session: {
    restore_layout: true,
    remember_open_files: true,
    auto_save_interval: 300, # seconds
  },
}