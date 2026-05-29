# Ghostty Terminal Config

macOS 下基于 Ghostty + Starship + zsh 插件的终端美化方案，从 iTerm2 + oh-my-zsh 迁移而来，更轻量更快。

## 效果

- 彩虹条提示符（基于 Starship 官方 catppuccin-powerline 预设，启用换行显示）
- 半透明毛玻璃窗口
- 语法高亮、自动建议、模糊搜索

## 包含的配置文件

| 文件 | 说明 | 安装位置 |
|------|------|---------|
| `ghostty/config` | Ghostty 终端配置（字体、主题、窗口、光标） | `~/.config/ghostty/config` |
| `starship/starship.toml` | Starship 彩虹条提示符配置（官方预设 + 换行） | `~/.config/starship.toml` |
| `zsh/ghostty-terminal-config.zsh` | zsh 配置（插件、工具、别名、快捷键） | `~/.config/ghostty-terminal-config/zshrc.zsh` |

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/justhalfbit/ghostty-terminal-config/main/install.sh)
```

安装前会询问确认，确认后自动执行：
1. 通过 Homebrew 安装所有依赖
2. 备份已有 Ghostty、Starship、独立 zsh 配置文件和 `~/.zshrc`
3. 安装 Ghostty、Starship 和独立 zsh 配置文件（覆盖）
4. 在 `~/.zshrc` 尾部写入一小段 `source` 引入（不内联整份配置）

## 备份与恢复

安装脚本会自动将已有配置备份到 `~/.config-backup/<时间戳>/` 目录。

备份文件对应关系：

| 备份文件 | 原始位置 |
|---------|---------|
| `~/.config-backup/<时间戳>/ghostty-config` | `~/.config/ghostty/config` |
| `~/.config-backup/<时间戳>/starship.toml` | `~/.config/starship.toml` |
| `~/.config-backup/<时间戳>/ghostty-terminal-config.zsh` | `~/.config/ghostty-terminal-config/zshrc.zsh` |
| `~/.config-backup/<时间戳>/zshrc` | `~/.zshrc` |

恢复命令：

```bash
# 查看备份目录（找到对应时间戳）
ls ~/.config-backup/

# 恢复（替换 <时间戳> 为实际目录名）
cp ~/.config-backup/<时间戳>/ghostty-config ~/.config/ghostty/config
cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
cp ~/.config-backup/<时间戳>/ghostty-terminal-config.zsh ~/.config/ghostty-terminal-config/zshrc.zsh
cp ~/.config-backup/<时间戳>/zshrc ~/.zshrc
```

### 卸载 zsh 配置

删除 `~/.zshrc` 中 `# >>> ghostty-terminal-config >>>` 到 `# <<< ghostty-terminal-config <<<` 之间的引入区块，并删除独立配置文件：

```bash
rm -f ~/.config/ghostty-terminal-config/zshrc.zsh
```

## 依赖

| 工具 | 用途 |
|------|------|
| [Ghostty](https://ghostty.org) | GPU 加速终端模拟器 |
| [Starship](https://starship.rs) | 跨 shell 提示符 |
| [fzf](https://github.com/junegunn/fzf) | 模糊搜索（Ctrl+R 搜历史，Ctrl+T 搜文件） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转（`z foo` 代替 `cd`） |
| [eza](https://github.com/eza-community/eza) | 替代 ls，彩色图标 |
| [bat](https://github.com/sharkdp/bat) | 替代 cat，语法高亮 |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 历史命令自动建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令语法高亮 |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Tab 补全增强 |
| [Maple Mono NF](https://github.com/subframe7536/maple-font) | 终端字体（Nerd Font，中文显示优秀） |

## 手动安装

### 1. 安装依赖

```bash
brew install --cask font-maple-mono-nf
brew install --cask ghostty
brew install starship fzf zoxide eza bat yazi zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

### 2. 下载配置文件

```bash
git clone --depth 1 https://github.com/justhalfbit/ghostty-terminal-config.git /tmp/ghostty-config
```

### 3. 安装配置文件

```bash
mkdir -p ~/.config/ghostty
mkdir -p ~/.config/ghostty-terminal-config
cp /tmp/ghostty-config/ghostty/config ~/.config/ghostty/config
cp /tmp/ghostty-config/starship/starship.toml ~/.config/starship.toml
cp /tmp/ghostty-config/zsh/ghostty-terminal-config.zsh ~/.config/ghostty-terminal-config/zshrc.zsh
cat >> ~/.zshrc <<'EOF'

# >>> ghostty-terminal-config >>>
# ghostty-terminal-config: 独立 zsh 配置文件引入
[ -r "$HOME/.config/ghostty-terminal-config/zshrc.zsh" ] && source "$HOME/.config/ghostty-terminal-config/zshrc.zsh"
# <<< ghostty-terminal-config <<<
EOF
```

> 注意：`~/.zshrc` 中只保留引入区块，实际 zsh 配置位于 `~/.config/ghostty-terminal-config/zshrc.zsh`，方便重复安装、升级和卸载。

### 4. 清理并重启

```bash
rm -rf /tmp/ghostty-config
```

重启 Ghostty 终端生效。

## Starship 预设说明

彩虹条基于 `starship preset catppuccin-powerline` 官方预设，唯一改动：

- `[line_break] disabled = false`：彩虹条一行，输入符号在下一行

## 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+F` | 接受自动建议 |
| `Ctrl+R` | fzf 模糊搜索历史命令 |
| `Ctrl+T` | fzf 模糊搜索文件 |
| `Tab` | 补全，连续按在候选列表中移动 |

## 别名速查

| 别名 | 实际命令 |
|------|---------|
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --sort=name` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat --paging=never --style=plain` |
| `y` | yazi 文件管理器（退出自动 cd） |
| `z foo` | zoxide 智能跳转到包含 foo 的目录 |
