# 仓库指南

## 项目概述
Zellix 是一个基于 NuShell 脚本的 **Helix 编辑器 + Zellij 终端多路复用器** 工作流工具集。它通过 Zellij 的自动关闭面板机制为 Helix 提供类似插件系统的体验，包括文件管理、项目切换、AI 辅助、Git 集成、主题管理等功能。

## 项目结构与模块组织

```
zellix/
├── run.nu                      # 主入口：创建 Zellij 会话，设置环境变量
├── helix.nu                    # Helix 启动脚本：初始化插件、应用主题、退出清理
├── zlx-theme.nu                # 主题检测与应用（dark/light/auto）
├── zlx-theme-toggle.nu         # 深色/浅色主题切换（持久化到 ~/.cache）
├── zlx-theme-toggle-restart.nu # 切换主题并重启当前会话
├── zlx-theme-picker-restart.nu # fzf 主题选择器并重启会话
├── plugins/                    # 核心插件模块
│   ├── init.nu                 # 插件注册与初始化入口
│   ├── helpers.nu              # 共享工具函数（send-to-helix、环境管理等）
│   ├── ai.nu                   # AI 代理面板（cursor-agent）
│   ├── project.nu              # 项目管理器（fzf 选择 + direnv 集成）
│   ├── create-project.nu       # 交互式项目配置创建器
│   ├── git.nu                  # Git 集成（lazygit）
│   ├── yazi.nu                 # Yazi 文件管理器集成
│   ├── nnn.nu                  # nnn 文件管理器集成
│   ├── makefile.nu             # Make 命令选择运行器
│   ├── justfile.nu             # Just 任务选择运行器
│   ├── terminal.nu             # 终端插件（nnn -P l）
│   ├── home-manager.nu         # Nix Home Manager switch/build
│   ├── zk.nu                   # zk 笔记系统集成
│   ├── tangle.nu               # Org-mode tangle 集成（doom emacs）
│   ├── markdown.nu             # Markdown 预览（glow/bat/lowdown）
│   ├── neomutt.nu              # NeoMutt 邮件客户端
│   ├── remap.nu                # X11 键盘重映射（xmodmap）
│   ├── sh.nu                   # Helix :sh 命令辅助
│   ├── editor-shell.nu         # 编辑器内嵌 Shell（zsh + cwd 同步）
│   ├── exit.nu                 # 会话退出清理钩子
│   ├── logger.nu               # 完整日志系统（多级别 + 文件输出）
│   └── logger-minimal.nu       # 轻量日志（用于测试）
├── config/
│   ├── zellij/layout.kdl       # Zellij 布局（AI 编辑器 + Shell + Web 标签页）
│   ├── zellij/config.kdl       # Zellij 配置
│   └── yazi/yazi.toml          # Yazi 配置
├── templates/
│   └── project.nu              # 项目配置模板（.zellix/project.nu）
├── tests/
│   ├── repl.py                 # REPL 测试脚本（Python）
│   ├── repl.nix                # REPL 测试 Nix 环境
│   ├── test_core_functionality.nu  # 核心功能测试
│   ├── test_project_workflow.nu    # 项目工作流测试
│   ├── test_all_improvements.nu    # 全量集成测试
│   ├── test_create_project.nu      # 项目创建测试
│   ├── test_project_creation.nu    # 项目配置创建测试
│   ├── test_project_integration.nu # 项目集成测试
│   ├── test_fixed_create.nu        # 修复版创建测试
│   ├── simple_test.nu              # 快速冒烟测试
│   ├── final_test.nu               # 最终验证测试
│   └── verify_improvements.nu      # 回归验证
├── .zellix/project.nu          # 本仓库自身的项目配置
├── README.md / QUICKSTART.md   # 用户文档
└── CHANGELOG.md                # 版本变更记录
```

### 核心执行流程

1. **`run.nu`**：设置 `ZELLIX_*` 环境变量 → 创建 Zellij 会话（加载 layout.kdl + config.kdl）。
2. **`layout.kdl`**：定义三个标签页——`ai dev`（Helix 编辑器 + AI 代理面板）、`shell`（Shell + 任务面板）、`www`（elinks 浏览器）。
3. **`helix.nu`**：运行 `init.nu` 初始化所有插件 → 启动 Helix（可选主题覆盖）→ Helix 退出后运行 `exit.nu` 并终止会话。
4. **插件调用**：通过 Helix 快捷键触发 `zellij run` 在浮动面板中执行各插件脚本。

### 关键设计模式

- **`helpers.nu` 中的 `send-to-helix`**：通过 Zellij action 向 Helix 发送命令（切换浮动面板 → 写入按键序列），是文件选择器和项目切换的核心机制。
- **每个插件**都导出 `init-*` 函数（在 `init.nu` 中统一调用）并提供 `def main` 作为独立运行入口。
- **AI 面板同步**：项目切换时可自动重启 AI 面板使其跟随新工作目录（`ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH`）。
- **`editor-shell.nu`**：为编辑器面板提供带 cwd 同步的 zsh 子 shell，通过 `ZDOTDIR` 注入同步钩子。

## 构建、测试与开发命令

所有命令在仓库根目录（`/home/Designers/.config/zellix`）执行：

| 命令 | 用途 |
|------|------|
| `zlx [-d <项目目录>] [-s <会话名>] [-c <配置根>] [-l <布局文件>] [path-to-open]` | 启动 Zellix 会话（`zellix` 与 `nu ./run.nu` 仍兼容） |
| `nu tests/test_core_functionality.nu` | 核心流程检查 |
| `nu tests/test_project_workflow.nu` | 项目切换与环境变量验证 |
| `nu tests/test_all_improvements.nu` | 广泛集成测试 |
| `nu tests/simple_test.nu` | 快速冒烟测试 |
| `nu tests/verify_improvements.nu` | 回归验证 |
| `nu tests/test_create_project.nu` | 项目创建功能测试 |

## 代码风格与命名规范
- 主要语言：NuShell（`.nu`），辅以 KDL（Zellij 布局/配置）、TOML（Yazi 配置）、Nix 文件。
- 缩进统一使用 2-4 个空格；同一文件内不混用 Tab 与空格。
- 文件命名：小写 kebab-case（如 `zlx-theme-toggle.nu`、`create-project.nu`）。
- 函数保持小而专注；通用工具函数优先放入 `plugins/helpers.nu` 复用。
- 环境变量命名沿用 `ZELLIX_*`（内部会话变量）和 `ZLX_*`（主题/用户覆盖变量）前缀。
- 新增插件逻辑优先放在 `plugins/`，启动/编排逻辑保持在 `run.nu`。

## 环境变量说明

### 会话变量（由 `run.nu` 自动设置）
| 变量名 | 说明 |
|--------|------|
| `ZELLIX_PATH` | Zellix 配置根目录 |
| `ZELLIX_SESSION` | 当前会话名（随机或用户指定） |
| `ZELLIX_TMP` | 会话临时目录（`/tmp/zellix/<session>`） |
| `ZELLIX_MOD` | 插件目录路径（`$ZELLIX_PATH/plugins`） |
| `ZELLIX_OPEN` | 启动时打开的文件路径 |
| `ZELLIX_PROJECT_DIR` | 当前项目根目录（对应 `-d` 选项） |
| `ZELLIX_LOG_LEVEL` | 日志级别（debug/info/warn/error/fatal） |
| `ZELLIX_LOG_FILE` | 日志文件路径 |

### 主题覆盖变量（可选，用户设置）
| 变量名 | 说明 |
|--------|------|
| `ZLX_THEME_MODE` | 强制主题模式（`dark` / `light`） |
| `ZLX_HELIX_THEME_DARK` / `_LIGHT` | Helix 主题名称 |
| `ZLX_ZELLIJ_THEME_DARK` / `_LIGHT` | Zellij 主题名称 |
| `ZLX_ST_BG_DARK` / `_LIGHT` | st 终端背景色（十六进制） |
| `ZLX_ST_FG_DARK` / `_LIGHT` | st 终端前景色（十六进制） |
| `ZLX_ST_CURSOR_DARK` / `_LIGHT` | st 终端光标色（十六进制） |
| `ZELLIX_SYNC_AI_PANE_ON_PROJECT_SWITCH` | 项目切换时是否重启 AI 面板（默认 true） |

## 测试指南
- 新增行为时，添加或更新对应 `test_*.nu` 脚本。
- 建议先跑聚焦测试（`tests/simple_test.nu`），再跑全量检查（`tests/test_all_improvements.nu`）。
- 修改 REPL 相关功能时，确认 `tests/repl.py` 与 `tests/repl.nix` 路径仍可用。
- 提交 PR 前，确保项目/环境管理与主题流程无回归。

## 提交与 Pull Request 规范
- 遵循 Conventional Commits 风格：`feat: ...`、`fix: ...`、`chore: ...`。
- 提交标题使用祈使语气且具体（例如：`fix: project border color in gruvbox layout`）。
- PR 需包含：
  - 改动内容与原因；
  - 已执行的验证命令；
  - 涉及界面/会话变更时的截图或终端片段（Zellij/Helix/主题行为）；
  - 相关 issue 或上下文链接（如适用）。
