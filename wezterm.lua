-- ============================================================================
-- WezTerm 配置（开箱即用）
--
-- 由 dotfiles 仓库管理，install.sh --wezterm 会把本文件软链到：
--   ~/.config/wezterm/wezterm.lua
--
-- 设计取向：与 ghostty.config 保持一致（字体、内边距、光标、行为），
-- 界面用「无边框 + 集成窗口按钮 + fancy tab bar」做现代化。
-- 仅使用稳定版可用的配置项（nightly-only 的选项一律不用）。
-- ============================================================================

local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local is_mac = wezterm.target_triple:find('darwin') ~= nil
local is_win = wezterm.target_triple:find('windows') ~= nil

-- 修饰键：
--   标签页 - macOS 用 Command，其他平台用 CTRL+SHIFT（与 wezterm 默认一致）
--   窗格   - 统一用 ALT，避免和标签页的 CTRL+SHIFT 组合撞键
local tab_mod = is_mac and 'SUPER' or 'CTRL|SHIFT'
local pane_mod = 'ALT'

-- Catppuccin Mocha 调色板（用于窗口框架、标签栏与光标等细节）
local palette = {
  base = '#1e1e2e',
  mantle = '#181825',
  crust = '#11111b',
  surface0 = '#313244',
  surface1 = '#45475a',
  surface2 = '#585b70',
  overlay0 = '#6c7086',
  subtext1 = '#bac2de',
  text = '#cdd6f4',
  mauve = '#cba6f7',
  peach = '#fab387',
}

-- ====================
-- 配色
-- ====================

-- Catppuccin Mocha 是 wezterm 内置主题，无需额外下载。
config.color_scheme = 'Catppuccin Mocha'

-- color_scheme 之上再覆盖少量细节色（20220903 起 colors 会覆盖 scheme）
config.colors = {
  cursor_bg = palette.text,
  cursor_border = palette.peach,
  cursor_fg = palette.base,
  selection_bg = palette.surface2,
  selection_fg = palette.text,
  compose_cursor = palette.peach,
  visual_bell = palette.surface1,
  split = palette.surface0,
  scrollbar_thumb = palette.surface1,
  tab_bar = {
    background = palette.crust,
    inactive_tab_edge = palette.surface0,
  },
}

-- ====================
-- 窗口与界面
-- ====================

-- 无边框：去掉系统标题栏，但保留可调整大小的边框（去掉 RESIZE 会导致无法缩放/最小化）
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
-- 集成窗口按钮：macOS 用原生红绿灯，其他平台画 Windows 风格按钮
config.integrated_title_button_style = is_mac and 'MacOsNative' or 'Windows'
config.integrated_title_button_color = 'Auto'
config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

-- fancy tab bar（原生风格、比例字体），只有单个标签时自动隐藏
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = false
config.show_new_tab_button_in_tab_bar = true

-- 标签栏 / 窗口框架配色跟随 Catppuccin
config.window_frame = {
  font = wezterm.font { family = 'Roboto', weight = 'Bold' },
  font_size = 11.0,
  active_titlebar_bg = palette.mantle,
  inactive_titlebar_bg = palette.crust,
  active_titlebar_fg = palette.text,
  inactive_titlebar_fg = palette.overlay0,
  active_titlebar_border_bottom = palette.crust,
  inactive_titlebar_border_bottom = palette.crust,
  button_fg = palette.subtext1,
  button_bg = palette.mantle,
  button_hover_fg = palette.base,
  button_hover_bg = palette.mauve,
}

-- 纯色背景，不启用背景图 / 模糊（wezterm 不支持 ghostty 的自定义 shader）
config.window_background_opacity = 1.0
config.window_padding = {
  left = '20px',
  right = '20px',
  top = '10px',
  bottom = '10px',
}
config.enable_scroll_bar = false
config.initial_cols = 120
config.initial_rows = 32

-- 关闭窗口时的确认行为保持 wezterm 默认（有前台进程时提示），
-- 如需直接关闭可改为 'NeverPrompt'。
-- config.window_close_confirmation = 'NeverPrompt'

-- ====================
-- 字体与文本渲染
-- ====================

-- 与 ghostty 相同的回退顺序：中文等宽优先，Nerd Font 兜底
config.font = wezterm.font_with_fallback {
  { family = 'LXGW WenKai Mono', weight = 'Medium' },
  { family = 'Cascadia Code NF', weight = 'Medium' },
  'JetBrains Mono',
  'Noto Color Emoji',
}
config.font_size = 15.0
config.line_height = 1.0
-- 关闭连字（对应 ghostty 的 font-feature = -calt）
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- ====================
-- 光标
-- ====================
--
-- ghostty 用 cursor_blaze.glsl 做光标动效，wezterm 不支持自定义 shader，
-- 这里用「实心方块 + 恒定速率闪烁」替代。
config.default_cursor_style = 'BlinkingBlock'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

-- ====================
-- 行为
-- ====================

-- 关闭最后一个标签即退出（对应 ghostty quit-after-last-window-closed）
config.exit_behavior = 'Close'
-- 与 tmux.conf 的 history-limit 保持一致
config.scrollback_lines = 50000
config.audible_bell = 'Disabled'
-- 无声提示：收到 BEL 时让背景轻微闪一下（wezterm 没有 ghostty 的铃声动画）
config.visual_bell = {
  fade_in_duration_ms = 60,
  fade_out_duration_ms = 120,
  fade_in_function = 'EaseOut',
  fade_out_function = 'EaseIn',
  target = 'BackgroundColor',
}
config.hide_mouse_cursor_when_typing = true
-- 输入时把滚轮交给应用（vim/tmux 等），而不是切换标签
config.mouse_wheel_scrolls_tabs = false
config.alternate_buffer_wheel_scroll_speed = 3
-- 自动重载配置 + 检查更新（对应 ghostty auto-update = check）
config.automatically_reload_config = true
config.check_for_updates = true
-- 现代 TUI 应用需要的 kitty 键盘协议
config.enable_kitty_keyboard = true
config.max_fps = 120
config.animation_fps = 60

-- macOS：Option 键作为 Alt 发送转义序列（对应 ghostty macos-option-as-alt = true）
if is_mac then
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true
end

-- ====================
-- 快捷键
-- ====================
--
-- 标签页：Cmd（macOS）/ CTRL+SHIFT（Linux、Windows）
-- 窗格：  ALT（与标签页修饰键错开，不会互相覆盖）
config.keys = {
  -- 切换标签（对应 ghostty super+left/right）
  { key = 'LeftArrow', mods = tab_mod, action = wezterm.action.ActivateTabRelative(-1) },
  { key = 'RightArrow', mods = tab_mod, action = wezterm.action.ActivateTabRelative(1) },
  -- 新建 / 关闭标签
  { key = 't', mods = tab_mod, action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = tab_mod, action = wezterm.action.CloseCurrentTab { confirm = true } },
  -- 分屏：\ 左右、- 上下（对齐 tmux.conf 的 | 与 _）
  { key = '\\', mods = pane_mod, action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = pane_mod, action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  -- 窗格导航 h/j/k/l
  { key = 'h', mods = pane_mod, action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'j', mods = pane_mod, action = wezterm.action.ActivatePaneDirection 'Down' },
  { key = 'k', mods = pane_mod, action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'l', mods = pane_mod, action = wezterm.action.ActivatePaneDirection 'Right' },
  -- 窗格最大化 / 还原
  { key = 'z', mods = pane_mod, action = wezterm.action.TogglePaneZoomState },
  -- 重载配置
  { key = 'r', mods = tab_mod, action = wezterm.action.ReloadConfiguration },
  -- 命令面板（可搜索全部动作与快捷键）
  { key = 'p', mods = tab_mod, action = wezterm.action.ActivateCommandPalette },
  -- 搜索
  { key = 'f', mods = tab_mod, action = wezterm.action.Search { CaseSensitiveString = '' } },
  -- 全屏
  { key = 'Enter', mods = tab_mod, action = wezterm.action.ToggleFullScreen },
}
-- 字号调整（Cmd/Ctrl +/-/0）沿用 wezterm 默认绑定，无需重复声明。

-- ====================
-- 可选：Windows / WSL 相关（按需取消注释）
-- ====================
--
-- 默认打开 WSL 发行版（名称用 `wsl -l -v` 查看）：
-- if is_win then
--   config.default_domain = 'WSL:Ubuntu'
-- end
--
-- 追加 SSH 域，便于 `Ctrl+Shift+P` 命令面板里直接连服务器：
-- config.ssh_domains = {
--   { name = 'devbox', remote_address = 'devbox.example.com', username = 'root' },
-- }

return config
