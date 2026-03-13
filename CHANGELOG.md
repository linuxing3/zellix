# Zellix Changelog

## v2.0 - Project Management Enhancements (2026-03-02)

### New Features

#### 1. Enhanced Project Switching
- **direnv Integration**: Automatic `direnv allow` when switching to projects with `.envrc` files
- **Project Configuration**: Support for `.zellix/project.nu` configuration files
- **Environment Management**: Project-specific environment variable loading

#### 2. New Plugins
- `create-project.nu`: Interactive project configuration creator
- `logger.nu`: Structured logging system with configurable levels
- Enhanced `project.nu`: Now includes direnv integration and config loading

#### 3. Environment Management Tools
- `load-env-from-record`: Load environment variables from structured records
- `merge-env-layers`: Merge environment variables with priority
- `find-project-root`: Detect project root from markers (.git, .envrc, .zellix)
- `command-exists`: Check if a command is available
- `safe-cd`: Safe directory change with error handling

#### 4. Logging System
- Configurable log levels: debug, info, warn, error, fatal
- Session-based logging with timestamps
- Log file rotation and management
- Error handling wrappers (`try-with-log`)
- Performance measurement (`measure-time`)

### Improvements

#### Project Management
- Bookmark directory fallback to `~/bookmarks` if `NNN_BOOKMARK_DIR` not set
- Automatic directory creation for bookmarks
- Better error handling in project selection
- Project metadata support (name, description, version)

#### Configuration
- Project-specific plugin enable/disable lists
- Environment variable template support (`{{CWD}}`, `{{ENV_VAR}}`)
- Command definitions for build, test, run workflows
- Dependency tracking (nix, node, rust, python)

#### Developer Experience
- ANSI color codes in console output
- Structured error messages
- Session persistence configuration
- Editor settings per project

### Technical Changes

#### Code Quality
- Updated deprecated NuShell flags (`-i` → `--optional`)
- Fixed syntax errors in helper functions
- Improved function parameter handling
- Better type annotations

#### Architecture
- Modular plugin system
- Environment variable layering
- Configurable logging backend
- Template-based configuration

### Files Added
- `plugins/logger.nu` - Logging utilities
- `plugins/create-project.nu` - Project configuration creator
- `templates/project.nu` - Project configuration template
- `test_core_functionality.nu` - Core functionality tests
- `simple_test.nu` - Basic component tests
- `CHANGELOG.md` - This changelog file

### Files Modified
- `plugins/project.nu` - Enhanced with direnv and config loading
- `plugins/helpers.nu` - Added environment management utilities
- `plugins/init.nu` - Added new plugin imports
- `README.md` - Updated documentation

### Files Removed
- `test_project_integration.nu` - Replaced with better tests
- `update_logging.nu` - One-time update script

### Known Issues
- `direnv allow` requires interactive session (can't be fully automated in tests)
- Some environment variable functions need additional testing
- Project switching with fzf requires terminal interaction

### Migration Notes
1. Existing projects work without changes
2. New `.zellix/project.nu` format is optional
3. Bookmark directory defaults to `~/bookmarks` if not set
4. Logging is disabled by default (set `ZELLIX_LOG_LEVEL` to enable)

### Future Plans
1. Plugin marketplace/registry
2. Configuration synchronization across devices
3. Performance optimizations for faster startup
4. More comprehensive test suite
5. GUI configuration tool

---

## v1.0 - Initial Release
- Basic Zellij + Helix integration
- NuShell plugin system
- File management plugins (yazi, nnn)
- Development tools (git, make, just)
- AI and terminal integration