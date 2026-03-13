# Zellix Quick Start Guide

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites
```bash
# Install required tools
# On NixOS or with nix:
nix-shell -p zellij helix nushell direnv fzf

# Or install individually:
# - zellij (terminal multiplexer)
# - helix (editor)
# - nushell (shell)
# - direnv (environment manager)
# - fzf (fuzzy finder)
```

### 2. Clone and Setup
```bash
# Clone the repository
git clone <repository-url> ~/.config/zellix
cd ~/.config/zellix

# Make run script executable
chmod +x run.nu

# Optional: Link to PATH
ln -s $(pwd)/run.nu ~/.local/bin/zellix
```

### 3. First Run
```bash
# Start zellix with example module
nu ./run.nu

# Or if linked to PATH:
zellix
```

### 4. Configure Helix
Add to `~/.config/helix/config.toml`:
```toml
[keys.normal.space]
p = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/project.nu"
f = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/yazi.nu"
a = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/ai.nu"
```

## 📁 Project Management

### Create Your First Project
```bash
# Navigate to your project
cd ~/projects/my-app

# Create project configuration
nu ~/.config/zellix/plugins/create-project.nu

# Follow the interactive prompts:
# - Project name: my-app
# - Description: My awesome app
# - Environment variables: DATABASE_URL=postgres://localhost/myapp
# - Enabled plugins: git, makefile, justfile
```

### Switch Between Projects
1. Press `Space + p` in Helix
2. Select project from list (uses fzf)
3. Zellix will:
   - Change to project directory
   - Load `.envrc` if exists (with `direnv allow`)
   - Load project configuration from `.zellix/project.nu`
   - Set environment variables
   - Open file picker in the project

### Project Configuration
Create `.zellix/project.nu`:
```nu
{
  name: "my-app",
  description: "My awesome application",
  
  env: {
    DATABASE_URL: "postgres://localhost/myapp",
    API_KEY: "{{ENV_API_KEY}}",  # Uses environment variable
    PROJECT_ROOT: "{{CWD}}"      # Current working directory
  },
  
  plugins: {
    enabled: ["git", "makefile", "justfile"],
    disabled: ["ai"]  # Disable AI panel for this project
  },
  
  commands: {
    build: "cargo build",
    test: "cargo test",
    run: "cargo run"
  }
}
```

## 🔧 Key Features

### File Management
- `Space + f`: Open yazi file manager
- Select files → Opens in Helix
- Navigate directories within floating pane

### Development Tools
- `git.nu`: Launch lazygit
- `makefile.nu`: Interactive make command selector
- `justfile.nu`: List and run just tasks
- `terminal.nu`: Open terminal/file manager

### AI Integration
- `Space + a`: Open AI chat interface
- Requires `aichat` or similar AI tool

### Environment Management
```bash
# Set logging level
export ZELLIX_LOG_LEVEL=debug

# View logs
nu -c "use ~/.config/zellix/plugins/logger.nu *; get-logs"

# Clear logs
nu -c "use ~/.config/zellix/plugins/logger.nu *; clear-logs"
```

## 🐛 Troubleshooting

### Common Issues

#### "Command not found"
```bash
# Ensure tools are in PATH
which zellij helix nu direnv fzf

# Add to PATH if needed
export PATH=$PATH:~/.nix-profile/bin
```

#### "direnv not loading"
```bash
# Check .envrc exists
ls -la .envrc

# Allow direnv manually first time
direnv allow

# Ensure direnv is hooked in shell
# Add to ~/.bashrc or ~/.zshrc:
eval "$(direnv hook bash)"  # or zsh
```

#### "No projects in list"
```bash
# Create bookmarks directory
mkdir -p ~/bookmarks

# Link your projects
ln -s ~/projects/my-app ~/bookmarks/my-app
ln -s ~/projects/other ~/bookmarks/other
```

#### "Logging not working"
```bash
# Enable logging
export ZELLIX_LOG_LEVEL=info
export ZELLIX_LOG_FILE=/tmp/zellix.log

# Check log file
cat /tmp/zellix.log
```

### Debug Mode
```bash
# Run with debug logging
ZELLIX_LOG_LEVEL=debug nu ./run.nu

# Check environment variables
nu -c "use plugins/helpers.nu *; print $env"

# Test specific plugin
nu -c "source plugins/project.nu; init-project"
```

## 📚 Next Steps

### Custom Plugins
1. Create `plugins/my-plugin.nu`
2. Add `export def main [] { ... }`
3. Update `plugins/init.nu` to import it
4. Bind to key in Helix config

### Advanced Configuration
- Modify `config/zellij/config.kdl` for keybindings
- Edit `config/zellij/layout.kdl` for pane layout
- Create custom themes in layout files

### Integration with Other Tools
- Add `.envrc` for project-specific environment
- Use `direnv` with `use flake` for Nix projects
- Combine with `tmux` or `screen` for session management

## 🆘 Need Help?

1. Check the [README.md](README.md) for detailed documentation
2. Review the [CHANGELOG.md](CHANGELOG.md) for recent changes
3. Enable debug logging: `export ZELLIX_LOG_LEVEL=debug`
4. Report issues on GitHub repository

## 🎯 Pro Tips

- Use `~/bookmarks` for quick project access
- Create project templates in `templates/` directory
- Set `ZELLIX_LOG_LEVEL=warn` in production
- Combine with `direnv` for automatic environment switching
- Use `fzf` previews for better project selection

---

**Happy coding with Zellix!** 🎉