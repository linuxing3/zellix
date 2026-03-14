# Zellix
A Simple, [NuShell](https://nushell.sh) Based "Plugin" system for Helix using the power of Zellij!
![screenshot](screenshot.png)

## 🚀 Enhanced Features (v2.0)

Zellix has been significantly enhanced with new features for better project management and development workflow:

### ✅ New Improvements

1. **Enhanced Project Switching with direnv Integration**
   - Automatic `direnv allow` when switching projects
   - Project-specific environment variable management
   - Support for `.envrc` files in project directories

2. **Project Configuration System**
   - `.zellix/project.nu` configuration files
   - Project metadata, environment variables, and plugin settings
   - `create-project.nu` tool for interactive project setup

3. **Environment Management Tools**
   - `load-env-from-record` for structured environment setup
   - Environment variable merging with priority layers
   - Project root detection and safe directory navigation

4. **Structured Logging System**
   - Configurable log levels (debug, info, warn, error, fatal)
   - Session-based logging with timestamps
   - Error handling wrappers and performance measurement

5. **New Plugins**
   - `logger.nu` - Comprehensive logging utilities
   - `create-project.nu` - Interactive project configuration creator

## What does it do?
Under the hood, it creates a special zellij session, focused on using auto-closing panes to support windows in helix.

## Installation
If you don't want to run from this directory directly, you can install it with `ln` and `chmod`. First, navigate to the directory where `run.nu` is located.
Run 
```nu
chmod +x run.nu
```
in your terminal to make the file runnable. Next, use 
```nu
ln -s $(pwd)/run.nu ~/.local/bin/zellix
```
to link `run.nu` into your local bin directory. Then you can run `zellix` directly (or `zellix path/to/file`) instead of `nu ./run.nu`.

## Usage
In order to actually run the system, you must run the shell file with the following parameters.
`open-path`: Optional file/path for Helix to open. This is the same as typing `hx {file}`.
`session-name`: Optional zellij session name.
`config-path`: Optional path to an alternative zellix config directory.

A simple example run, if currently inside of the cloned repository, you can run the program like this 
```nu
nu ./run.nu
```
You can also open a specific file at startup:
```nu
nu ./run.nu README.md
```

If you just want to try out zellix, clone the repository, ensure you have `zellij` and `helix` installed.
Then, if you want to try out my configuration, you will need `yazi` and optionally `codex` (for the AI pane).
You'll want to edit your helix configuration to use the following in a keybind, or you can run it in helix by pasting it.
`:sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/yazi.nu` Will run the yazi program, and replacing `yazi.nu` with `ai.nu`
will run the AI Module.

if you want to try how i use it, the following will add keybinds for both yazi and the ai module.
```toml
[keys.normal.space.f]
f = "file_picker"
t = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/yazi.nu"

[keys.normal.space.p]
p = ":sh zellij run -c -- nu $ZELLIX_MOD/project.nu"

[keys.normal.space.l]
a = ":sh zellij run -c -f -x 10% -y 10% --width 80% --height 80% -- nu $ZELLIX_MOD/ai.nu"
```

## Enhanced Project Management

### Creating a New Project Configuration
```bash
# Run from within your project directory
nu $ZELLIX_MOD/create-project.nu
```

### Switching Projects with Environment Management
The enhanced `project.nu` plugin now:
1. Automatically detects and uses `.envrc` files
2. Loads project-specific configuration from `.zellix/project.nu`
3. Sets project environment variables
4. Changes to the project directory

### Project Configuration Example
Create `.zellix/project.nu` in your project root:
```nu
{
  name: "my-project",
  env: {
    DATABASE_URL: "postgres://localhost/dev",
    API_KEY: "{{ENV_API_KEY}}",
    PROJECT_ROOT: "{{CWD}}"
  },
  plugins: {
    enabled: ["git", "makefile", "justfile"],
    disabled: ["ai"]
  }
}
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| `project.nu` | Enhanced project switching with direnv integration |
| `create-project.nu` | Interactive project configuration creator |
| `logger.nu` | Structured logging and error handling |
| `helpers.nu` | Environment management utilities |
| `yazi.nu` | File manager integration |
| `ai.nu` | Codex CLI agent pane |
| `git.nu` | Git integration (lazygit) |
| `makefile.nu` | Make command runner |
| `justfile.nu` | Just task runner |
| `nnn.nu` | Terminal file manager |
| `terminal.nu` | Terminal/shell integration |
| `zk.nu` | Note-taking system |
| `tangle.nu` | Org-mode tangle integration |
| `home-manager.nu` | Nix home-manager integration |
| `neomutt.nu` | Email client |
| `markdown.nu` | Markdown preview |
| `remap.nu` | Keyboard remapping |
| `sh.nu` | Shell command integration |

## Environment Variables

Zellix sets the following environment variables:

- `ZELLIX_PATH`: Path to zellix configuration
- `ZELLIX_SESSION`: Unique session identifier
- `ZELLIX_MOD`: Path to plugins directory
- `ZELLIX_TMP`: Temporary directory for the session
- `ZELLIX_OPEN`: File to open in helix
- `ZELLIX_THEME_MODE`: Resolved theme mode (`dark` or `light`) for this session
- `ZELLIX_HELIX_THEME`: Helix theme applied for this session
- `ZELLIX_LOG_LEVEL`: Logging level (debug, info, warn, error, fatal)
- `ZELLIX_LOG_FILE`: Path to log file

Theme override variables (optional):
- `ZLX_THEME_MODE`: Force mode to `dark` or `light`
- `ZLX_HELIX_THEME_DARK` / `ZLX_HELIX_THEME_LIGHT`: Helix theme names
- `ZLX_ZELLIJ_THEME_DARK` / `ZLX_ZELLIJ_THEME_LIGHT`: Zellij theme names
- `ZLX_APPLY_ST_THEME`: `true` to force runtime recolor hook even when `$TERM` is not `st*`
- `ZLX_ST_BG_DARK` / `ZLX_ST_BG_LIGHT`: st background colors (hex)
- `ZLX_ST_FG_DARK` / `ZLX_ST_FG_LIGHT`: st foreground colors (hex)
- `ZLX_ST_CURSOR_DARK` / `ZLX_ST_CURSOR_LIGHT`: st cursor colors (hex)

Live helper command:
- `nu ~/.config/zellix/zlx-theme.nu auto` (detect and apply st runtime colors)
- `nu ~/.config/zellix/zlx-theme.nu dark`
- `nu ~/.config/zellix/zlx-theme.nu light`

Zellij shortcuts:
- `Alt-t`: toggle zlx dark/light mode (persists for next zlx session)
- `Alt-Shift-t`: toggle and restart current zlx session (applies zellij/helix theme immediately)

## Logging

Set log level via environment variable:
```bash
export ZELLIX_LOG_LEVEL=debug
```

View logs:
```bash
# From within a zellix session
nu -c "use plugins/logger.nu *; get-logs 20"
```

## Why does this exist?
At the time of writing this, there is no plugin system for helix, and I dislike the configuration of neovim,
so I created this to satiate my desire for more than just an editor systems that can still be controlled through my editor.

## Wrote something awesome?
Put in a pull request adding a link to a repository containing the code, and I'll look at pulling it in!

## Awesome zellix
- **Project Configuration System** - Manage project-specific settings and environment
- **direnv Integration** - Automatic environment switching
- **Structured Logging** - Debug and monitor zellix sessions

## Contributing
### WARNING
At this time, this is a very rough implementation that hasn't been fully tested. 
If you choose to use this, please report **any** bugs you find during usage, and I will fix them ASAP.

### Development
To test improvements:
```bash
# Run core functionality tests
nu test_core_functionality.nu

# Test specific components
nu simple_test.nu
```
