# dotfiles - 规约

## 技术栈

### 主要依赖
- Lua（Neovim 配置） - 建议 Neovim 稳定版（lazy.nvim/LazyVim 生态）
- Bash（环境安装与配置脚本） - `install.sh`
- Zsh + Oh My Zsh（交互式 Shell 配置）
- LazyVim/Lazy.nvim（插件管理与基础配置框架）
- 其他组件：tmux、atuin、ripgrep、fd、eza、StyLua、Prettier、Ghostty、Clash

### 开发工具
- 依赖管理：
  - Neovim 插件使用 `lazy.nvim` 声明式管理（见 `lua/config/lazy.lua`）
  - 语言项目约定（当在本机创建对应项目时）：Python 使用 `uv`，Go 使用 `go mod`
- 构建工具：
  - Linux 构建 Neovim 使用 `make`（见 `install.sh`），其余为配置即用
- 测试框架：
  - 本仓为开发环境配置，不包含统一测试框架
- 代码质量工具：
  - Lua：`stylua`（见 `stylua.toml`）
  - 通用：Prettier（通过 LazyVim 集成）、shellcheck/shfmt（建议用于 Shell）
  - 语言规范参考 `.github/rules/*.md`（python/go/js/sql/css/flask/protobuf/bash 等）

## 项目开发要求

### 日志
- Shell 脚本需有清晰回显，关键步骤输出人类可读信息；长流程建议记录到文件并包含时间戳
- 推荐使用 `tee -a <logfile>` 进行追加记录，便于排错与追踪（与 `.github/rules/bash.md` 一致）
- 交互式步骤需明确提示（如 `install.sh` 的系统检测、确认切换默认 shell 提示）

### 错误处理
- 脚本需进行平台/前置条件校验：不支持或缺失条件时，明确提示并终止（见 `install.sh` 的系统类型与发行版检查）
- 远程依赖/克隆失败需给出清晰提示并退出（见 `lua/config/lazy.lua` 对 lazy.nvim 克隆失败的回显处理）
- 重要文件操作应做存在性与备份处理（`install.sh` 对 `~/.tmux.conf*`、`~/.config/nvim` 的备份与符号链接）

