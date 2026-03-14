# Repository Guidelines

## Project Structure & Module Organization
This repository is a NuShell-driven Helix + Zellij workflow toolkit.

- `run.nu`, `helix.nu`, `zlx-theme*.nu`: entrypoints and session/theme helpers.
- `plugins/`: core plugin modules (`project.nu`, `ai.nu`, `git.nu`, `logger.nu`, etc.).
- `config/`: runtime configuration (notably `config/zellij/*.kdl`, `config/yazi/yazi.toml`).
- `templates/`: starter templates (for example `templates/project.nu`).
- `tests/` plus root `test_*.nu` scripts: test harness and scenario scripts.
- `README.md`, `QUICKSTART.md`, `CHANGELOG.md`: user and release documentation.

Prefer adding new plugin logic under `plugins/` and keeping launch/orchestration behavior in `run.nu`.

## Build, Test, and Development Commands
- `nu ./run.nu <module-path> [open-path]`: start a Zellix session locally.
- `nu test_core_functionality.nu`: run core workflow checks.
- `nu test_project_workflow.nu`: validate project switching and env behavior.
- `nu test_all_improvements.nu`: run broader integration-style checks.
- `nu simple_test.nu`: fast sanity test during iteration.
- `nu verify_improvements.nu`: regression verification pass.

Run commands from repository root (`/home/Designers/.config/zellix`).

## Coding Style & Naming Conventions
- Language: NuShell (`.nu`), with supporting KDL/TOML/Nix files.
- Use 2-4 space indentation consistently within a file; do not mix tabs/spaces.
- File naming: lowercase kebab-case for scripts (`zlx-theme-toggle.nu`), descriptive plugin names (`create-project.nu`).
- Keep functions small and task-focused; prefer shared helpers in `plugins/helpers.nu`.
- Preserve existing environment variable naming style (`ZELLIX_*`, `ZLX_*`).

## Testing Guidelines
- Add or update a `test_*.nu` script for new behavior.
- Prefer focused tests first (`simple_test.nu`), then broader checks (`test_all_improvements.nu`).
- For REPL-related changes, validate `tests/repl.py` / `tests/repl.nix` paths still work.
- Ensure no regressions in project/env and theme flows before opening a PR.

## Commit & Pull Request Guidelines
- Follow Conventional Commit style seen in history: `feat: ...`, `fix: ...`, `chore: ...`.
- Keep subject lines imperative and specific (for example: `fix: project border color in gruvbox layout`).
- PRs should include:
- what changed and why,
- commands run to verify behavior,
- screenshots or terminal snippets for UI/session changes (Zellij/Helix/theme behavior),
- linked issue/context when applicable.
