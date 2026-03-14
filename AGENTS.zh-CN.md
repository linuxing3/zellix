# 仓库指南

## 项目结构与模块组织
本仓库是一个由 NuShell 驱动的 Helix + Zellij 工作流工具集。

- `run.nu`、`helix.nu`、`zlx-theme*.nu`：入口脚本与会话/主题辅助脚本。
- `plugins/`：核心插件模块（如 `project.nu`、`ai.nu`、`git.nu`、`logger.nu`）。
- `config/`：运行时配置（重点是 `config/zellij/*.kdl`、`config/yazi/yazi.toml`）。
- `templates/`：模板文件（例如 `templates/project.nu`）。
- `tests/` 与根目录下 `test_*.nu`：测试工具与场景脚本。
- `README.md`、`QUICKSTART.md`、`CHANGELOG.md`：用户与发布文档。

新增插件逻辑优先放在 `plugins/`，启动/编排逻辑保持在 `run.nu`。

## 构建、测试与开发命令
- `nu ./run.nu [open-path] [session-name] [config-path]`：本地启动 Zellix 会话。
- `nu test_core_functionality.nu`：运行核心流程检查。
- `nu test_project_workflow.nu`：验证项目切换与环境变量行为。
- `nu test_all_improvements.nu`：执行更广泛的集成检查。
- `nu simple_test.nu`：迭代时快速冒烟测试。
- `nu verify_improvements.nu`：执行回归验证。

以上命令请在仓库根目录（`/home/Designers/.config/zellix`）运行。

## 代码风格与命名规范
- 主要语言：NuShell（`.nu`），并包含 KDL/TOML/Nix 配置。
- 缩进统一使用 2-4 个空格；不要在同一文件混用 Tab 与空格。
- 文件命名：小写 kebab-case（如 `zlx-theme-toggle.nu`），插件名需语义清晰（如 `create-project.nu`）。
- 函数保持小而专注；通用能力优先复用 `plugins/helpers.nu`。
- 环境变量命名沿用现有风格（`ZELLIX_*`、`ZLX_*`）。

## 测试指南
- 新增行为时，添加或更新对应 `test_*.nu` 脚本。
- 建议先跑聚焦测试（`simple_test.nu`），再跑全量检查（`test_all_improvements.nu`）。
- 修改 REPL 相关功能时，确认 `tests/repl.py` 与 `tests/repl.nix` 路径仍可用。
- 提交 PR 前，确保项目/环境管理与主题流程无回归。

## 提交与 Pull Request 规范
- 遵循历史中的 Conventional Commits：`feat: ...`、`fix: ...`、`chore: ...`。
- 提交标题使用祈使语气且具体（例如：`fix: project border color in gruvbox layout`）。
- PR 需包含：
- 改动内容与原因；
- 已执行的验证命令；
- 涉及界面/会话变更时的截图或终端片段（Zellij/Helix/主题行为）；
- 相关 issue 或上下文链接（如适用）。
