# dotfiles

## 核心功能模块

### 1. Neovim 配置模块
- 基于 LazyVim 框架的完整 Neovim IDE 配置
- 集成 AI 编程助手（Copilot、Avante）、代码导航、文件管理等功能
- 支持多语言开发（Go、Python、Markdown、JSON、YAML、TOML）

### 2. Shell 环境模块
- Oh My Zsh 配置与插件管理（zsh-autosuggestions、zsh-syntax-highlighting）
- 常用命令别名和环境变量配置
- Atuin 历史命令搜索集成

### 3. 终端与工具配置模块
- Ghostty 终端模拟器配置（TokyoNight 主题、透明度、快捷键）
- Tmux 终端复用器配置（oh-my-tmux）
- Clash 代理工具配置

### 4. AI 编程规范模块
- 多语言代码规范指南（C++、Go、Python、JavaScript、SQL 等）
- Git 提交规范
- AI Agent 交互规范

## 项目结构分析

### 入口文件
- `init.lua` - Neovim 配置入口，引导 LazyVim 框架
- `install.sh` - 一键安装脚本，支持 Linux 和 macOS
- `config.zsh` - Zsh 配置模板

### 核心业务包
- `lua/config/` - Neovim 核心配置（选项、快捷键、自动命令）
- `lua/plugins/` - Neovim 插件配置（AI、编辑器、颜色主题）
- `.github/rules/` - AI 编程规范文档

### 基础设施包
- `.github/templates/` - 文档模板
- `.github/instructions/` - AI Agent 指令文件
- `.github/prompts/` - AI 提示词模板

### 代码目录文件结构

```
dotfiles/
├── init.lua                    # Neovim 入口文件
├── install.sh                  # 一键安装脚本
├── config.zsh                  # Zsh 配置模板
├── ghostty.config              # Ghostty 终端配置
├── clash.yaml                  # Clash 代理配置
├── stylua.toml                 # Lua 格式化配置
├── lazyvim.json                # LazyVim 插件清单
├── lazy-lock.json              # 插件版本锁定
├── cursor_blaze.glsl           # 终端光标着色器效果
├── lua/
│   ├── config/
│   │   ├── lazy.lua            # LazyVim 引导配置
│   │   ├── options.lua         # 编辑器选项（Tab、剪贴板、UI）
│   │   ├── keymaps.lua         # 自定义快捷键映射
│   │   └── autocmds.lua        # 自动命令（YAML 禁用格式化等）
│   └── plugins/
│       ├── avante.lua          # AI 编程助手配置
│       ├── colorscheme.lua     # 颜色主题（NeoSolarized）
│       ├── copilot_chat.lua    # GitHub Copilot 聊天
│       ├── editor.lua          # 编辑器增强插件
│       ├── markdown.lua        # Markdown 支持
│       └── toggleterm.lua      # 终端切换配置
└── .github/
    ├── rules/                  # 编程规范
    │   ├── c++.md
    │   ├── css.md
    │   ├── flask.md
    │   ├── git.md
    │   ├── go.md
    │   ├── go-web.md
    │   ├── javascript.md
    │   ├── protobuf.md
    │   ├── python.md
    │   └── sql.md
    ├── instructions/           # AI Agent 指令
    ├── templates/              # 文档模板
    └── prompts/                # AI 提示词
```

## 技术栈

### 主要依赖
- **Lua** - Neovim 配置语言
- **LazyVim** - Neovim 配置框架（基于 lazy.nvim 插件管理器）
- **Oh My Zsh** - Zsh 框架
- **Bash** - 安装脚本语言

### 开发工具
- **StyLua** - Lua 代码格式化（2空格缩进，120列宽）
- **Prettier** - 多语言格式化（通过 LazyVim 集成）
- **Ripgrep** - 快速文件搜索
- **fd** - 文件查找工具
- **eza** - 现代化 ls 替代品
- **Atuin** - 智能命令历史

## 开发和使用指南

### 环境配置
```bash
# 前置要求
# macOS: 安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Linux: 确保已安装 git
sudo apt install -y git  # Ubuntu/Debian
sudo dnf install -y git  # Fedora
```

### 构建和运行
```bash
# 一键安装所有配置
./install.sh

# 安装 LazyVim 额外插件
# 在 Neovim 中运行 :LazyExtra

# 手动创建 Neovim 配置链接
ln -s $(pwd) ~/.config/nvim
```

## 项目架构特点

### 设计模式
- **模块化配置** - Neovim 配置分离为 config（核心）和 plugins（插件）两层
- **声明式插件管理** - 使用 lazy.nvim 实现按需加载
- **平台适配** - install.sh 自动检测系统类型（Darwin/Ubuntu/Debian/Fedora）

### 数据流设计
- Neovim 启动 → `init.lua` → `config/lazy.lua` → LazyVim 框架 → 自定义插件
- Zsh 启动 → Oh My Zsh 框架 → 插件加载 → 环境变量和别名

### 错误处理
- install.sh 包含系统检测和错误退出机制
- LazyVim 自动处理插件依赖和版本兼容

## 扩展性设计

### 插件化架构
- 在 `lua/plugins/` 目录添加新 Lua 文件即可扩展 Neovim 功能
- LazyVim Extras 提供可选功能模块（AI、语言支持等）

### API设计原则
- 快捷键以 `<leader>` 为前缀，分组清晰（f=文件, t=终端, s=分屏）
- 插件配置遵循 LazyVim 的 opts 合并规范

## 部署和运维

### 部署环境要求
- **操作系统**: macOS (Darwin) / Linux (Ubuntu, Debian, Fedora, TencentOS)
- **Shell**: Zsh
- **必需工具**: git, curl

### 配置管理
- 配置文件通过 Git 版本控制
- install.sh 自动创建符号链接到 ~/.config/nvim
- 现有配置会自动备份为 .bak 文件

### 主要自定义快捷键
| 快捷键 | 功能 |
|--------|------|
| `kj` | 退出插入模式 |
| `<leader>w` | 保存文件 |
| `<leader>q` | 退出 |
| `<leader>e` | 切换 Neo-tree |
| `<leader>ff` | 文件搜索 |
| `<leader>fg` | 全局搜索 |
| `H/L` | 切换 Buffer |
| `<leader>tf` | 浮动终端 |
| `<C-\>` | 切换终端 |
