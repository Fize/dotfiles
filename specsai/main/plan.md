# dotfiles 安装脚本优化设计方案（main）

## 背景与目标
- 背景：当前 `install.sh` 在更新 Oh My Zsh 配置时会提前切换默认 shell，导致脚本终端中断；日志输出较分散，不易追踪；部分包安装存在平台差异导致中途失败。
- 目标：
  - 仅在脚本最后一步执行默认 shell 切换；
  - 规范化日志与错误输出，统一带时间戳，可追加到日志文件；
  - 清理无用代码，统一包安装检查与失败兜底；
  - 确保安装过程中涉及的包存在/可用，避免因源或包名差异导致中断。

## 设计原则（遵循 `/specsai/constitution.md`）
- Shell 编码遵循 `.github/rules/bash.md`：shebang、变量作用域、main 入口、`[[ ]]` 条件、`$(...)`、`tee -a` 日志追加等。
- 保持现有技术栈：Bash + 包管理器（apt/dnf/brew），不引入新的安装框架。
- 平台适配：Darwin / Debian/Ubuntu / Fedora/TencentOS。
- 错误处理：显式校验前置条件、命令返回值检查、失败提示与退出。

## 方案概述
1. Shell 切换时机调整
   - 将 `chsh` 相关逻辑从“最终配置”前移除，改为“脚本最后的交互区”执行。
   - 增加环境变量 `SKIP_CHSH` 支持；在 CI 或非交互环境时可跳过。

2. 日志与回显统一
   - 定义 `LOG_FILE=${HOME}/.dotfiles_install.log`，所有关键步骤 `| tee -a "$LOG_FILE"`。
   - 提供 `log_info/log_warn/log_error` 封装，统一带时间戳：`printf '[%s] LEVEL: msg\n' "$(date +'%F %T')"`。
   - 交互提示统一为 `read -r`，明确超时/默认值策略（默认继续）。

3. 包安装健壮性
   - 引入 `ensure_cmd`（命令存在性检查）与 `ensure_pkg`（按平台安装视图）：
     - macOS: `brew list <pkg> || brew install <pkg>`；`brew tap` 与 `--cask` 区分。
     - Fedora/TencentOS: `sudo dnf -y install <pkg>` 前加 `sudo dnf -y update`，必要时提供替代包名（如 `fd-find` -> `fd` 的软链接方案）。
     - Debian/Ubuntu: `sudo apt -y update`，处理 GPG key 与源添加后再安装；必要包名映射与软链接。
   - 对源码安装（neovim）统一封装：存在即跳过，不存在则执行 clone、checkout、build，失败回滚提示。

4. 无用代码清理与结构化
   - 保留功能：系统检测、核心包安装、扩展包安装、zsh、tmux、atuin、neovim、最终交互区。
   - 移除：冗余 echo、平台不支持部分的死代码路径；把零散 `echo` 替换为 `log_*`。
   - 结构：`main` 中按阶段调用函数，阶段首尾打印分隔符，便于日志检索。

5. 安装前置校验
   - 校验网络与必要命令：`curl`, `git`, `sudo`（Linux）；若缺失给出修复提示并退出。
   - 对 brew 未安装时提示安装脚本；Linux 检查 `/etc/os-release` 与可用包管理器。

## 详细设计

### 日志封装
- 函数：
  - `log_ts()`: `date +'%F %T'`
  - `log_info()`: `printf '[%s] INFO: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"`
  - `log_warn()`: 同上，改 `WARN`
  - `log_error()`: 同上，改 `ERROR`
- 使用：所有安装与配置函数入口与关键步骤调用 `log_info`；非致命问题用 `log_warn`；错误退出前用 `log_error`。

### 平台检测与包安装
- `check_system()`：保持现有逻辑，增加 `log_info` 与返回码检查；不支持发行版直接 `exit 1`。
- `install_core_package()`/`install_package()`：
  - 重构为内部调用 `ensure_pkg`，处理包名差异与映射：
    - Debian/Ubuntu：`silversearcher-ag`，`fd-find`；创建 `ln -sf $(command -v fdfind) /usr/local/bin/fd` 以兼容脚本。
    - Fedora/TencentOS：`the_silver_searcher`，`fd-find`（或系统包名 `fd`）。
    - macOS：`the_silver_searcher`、`fd`、`ripgrep`、`shfmt`、`atuin`、`neovim --HEAD`（保留现有选择）。
  - 源添加与 GPG（Debian/Ubuntu）流程封装为独立函数 `setup_apt_sources()`，失败即回滚并提示手动。

### 组件安装
- `setup_zsh()`：
  - 安装 Oh My Zsh（如不存在）—使用 `--unattended`；
  - 安装插件（autosuggestions/syntax-highlighting）—存在性检查；
  - 不在此处执行 `chsh`；仅修改 `.zshrc` 插件列表与环境变量追加；
  - `.zshrc` 备份与安全写入（避免重复追加）。
- `setup_tmux()`：保留同构，增加存在性检查与日志。
- `setup_atuin()`：保留，增加存在性检查，失败 `log_warn`。
- `setup_neovim()`：符号链接创建前做备份；存在时跳过并日志说明。

### 交互与收尾
- 最后交互区：
  - 询问是否切换默认 shell 至 zsh：若 `SKIP_CHSH=1` 则跳过；否则检测 zsh 路径（`/usr/local/bin` `/usr/bin` `/bin`）并执行 `chsh -s`。
  - 打印总结：成功安装的组件列表；失败或跳过项。
  - 日志文件路径提示：`$LOG_FILE`。

## 失败与回滚策略
- 任一关键阶段失败时：打印错误、推荐手动步骤、退出码非零；不中断其他独立阶段（例如 Atuin 失败不影响 tmux）。
- 源与 GPG 失败：回滚源变更，保留本地日志。

## 兼容性与安全
- 不处理 `ls` 输出；文件读取使用 `while read`；临时文件使用 `mktemp`；关键信号 `trap` 收尾（可选）。
- 路径尽量绝对路径；脚本内避免裸 `sudo` 密集调用（合并为批次，或提示预输入）。

## 实施步骤（仅设计，不实现）
1. 重构 `install.sh` 结构：引入日志封装与 `ensure_pkg`。
2. 将 `chsh` 移至最后交互区；增加 `SKIP_CHSH`。
3. 清理零散 `echo`，替换为 `log_*`；为各阶段添加分隔符输出。
4. 完善 Debian/Ubuntu 的源与包名映射，做 `fd` 软链接处理。
5. 为 `.zshrc` 修改增加备份与幂等逻辑；避免重复插件追加。
6. 增加失败兜底：源码安装 neovim 的回滚与跳过选项。

## 与现有约定的对齐
- 遵循 `.github/rules/bash.md` 与 `/specsai/constitution.md` 的日志与错误处理约定。
- 不引入新技术栈；继续使用现有包管理器与 LazyVim。
- 输出清晰可维护的安装日志，便于后续问题排查。
