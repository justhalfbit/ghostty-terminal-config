#!/bin/bash

# ==============================================================================
# ghostty-terminal-config 一键安装脚本
# ==============================================================================
# 用法:
#   bash <(curl -fsSL https://raw.githubusercontent.com/justhalfbit/ghostty-terminal-config/main/install.sh)
#
# 说明:
#   1. 安装 Homebrew 依赖（字体、终端工具、zsh 插件）
#   2. 备份已有配置到 ~/.config-backup/YYYYMMDD_HHMMSS/
#   3. 从 GitHub 下载配置文件到目标位置
#
# 恢复备份:
#   cp ~/.config-backup/<时间戳>/ghostty-config ~/.config/ghostty/config
#   cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
#   cp ~/.config-backup/<时间戳>/ghostty-terminal-config.zsh ~/.config/ghostty-terminal-config/zshrc.zsh
#   cp ~/.config-backup/<时间戳>/zshrc ~/.zshrc
#
# 卸载 zsh 配置:
#   删除 ~/.zshrc 中 ">>> ghostty-terminal-config >>>" 到 "<<< ghostty-terminal-config <<<" 之间的内容
#   删除 ~/.config/ghostty-terminal-config/zshrc.zsh
# ==============================================================================

set -e

REPO_URL="https://github.com/justhalfbit/ghostty-terminal-config.git"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
TMP_DIR="$(mktemp -d)"
ZSH_CONFIG_DIR="$HOME/.config/ghostty-terminal-config"
ZSH_CONFIG_FILE="$ZSH_CONFIG_DIR/zshrc.zsh"
ZSHRC_FILE="$HOME/.zshrc"
ZSHRC_MARKER_START="# >>> ghostty-terminal-config >>>"
ZSHRC_MARKER_END="# <<< ghostty-terminal-config <<<"

# 清理临时目录
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ==============================================================================
# 用户确认
# ==============================================================================
echo ""
echo "======================================"
echo " Ghostty Terminal Config 安装脚本"
echo "======================================"
echo ""
echo "本脚本将执行以下操作:"
echo "  1. 通过 Homebrew 安装终端工具和字体"
echo "  2. 备份已有 Ghostty、Starship 和 zsh 配置到 ~/.config-backup/"
echo "  3. 安装新的终端配置（Ghostty + Starship + 独立 zsh 配置文件）"
echo "  4. 在 ~/.zshrc 中写入一小段 source 引入"
echo ""
echo "已有配置将备份到: $BACKUP_DIR"
echo ""
read -p "是否继续？(y/n) " -n 1 -r < /dev/tty
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "已取消安装。"
  exit 0
fi
echo ""

# ==============================================================================
# 检查环境
# ==============================================================================
if ! command -v brew &> /dev/null; then
  echo "错误: 未检测到 Homebrew，请先安装: https://brew.sh"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "错误: 未检测到 git，请先安装 Xcode Command Line Tools: xcode-select --install"
  exit 1
fi

# ==============================================================================
# 安装依赖
# ==============================================================================
echo "==> 安装 Homebrew 依赖..."
brew install --cask font-maple-mono-nf
if [ ! -d "/Applications/Ghostty.app" ]; then
  brew install --cask ghostty
else
  echo "    Ghostty 已安装，跳过。"
fi
brew install starship fzf zoxide eza bat yazi zsh-autosuggestions zsh-syntax-highlighting zsh-completions

# ==============================================================================
# 下载配置文件
# ==============================================================================
echo "==> 下载配置文件..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"

# ==============================================================================
# 备份已有配置
# ==============================================================================
echo "==> 检查已有配置..."
backup_file() {
  local file="$1"
  local name="$2"
  if [ -e "$file" ] || [ -L "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ -L "$file" ]; then
      local target
      target="$(readlink "$file")"
      echo "$target" > "$BACKUP_DIR/$name.symlink"
      echo "    备份软链接 $file (指向 $target)"
    else
      cp "$file" "$BACKUP_DIR/$name"
      echo "    备份文件 $file"
    fi
  fi
}

backup_file ~/.config/ghostty/config "ghostty-config"
backup_file ~/.config/starship.toml "starship.toml"
backup_file "$ZSH_CONFIG_FILE" "ghostty-terminal-config.zsh"
backup_file "$ZSHRC_FILE" "zshrc"

if [ -d "$BACKUP_DIR" ]; then
  echo ""
  echo "    ✓ 已有配置已备份到: $BACKUP_DIR"
  echo ""
else
  echo "    无已有配置，跳过备份。"
fi

# ==============================================================================
# 安装配置文件
# ==============================================================================
echo "==> 安装配置文件..."
mkdir -p ~/.config/ghostty
mkdir -p "$ZSH_CONFIG_DIR"

cp "$TMP_DIR/repo/ghostty/config" ~/.config/ghostty/config
cp "$TMP_DIR/repo/starship/starship.toml" ~/.config/starship.toml
cp "$TMP_DIR/repo/zsh/ghostty-terminal-config.zsh" "$ZSH_CONFIG_FILE"
echo "    ✓ ~/.config/ghostty/config"
echo "    ✓ ~/.config/starship.toml"
echo "    ✓ $ZSH_CONFIG_FILE"

# .zshrc 仅保留 source 引入，实际配置放在独立文件中，便于升级和卸载
ZSHRC_SNIPPET="$(mktemp)"
{
  echo ""
  echo "$ZSHRC_MARKER_START"
  echo "# ghostty-terminal-config: 独立 zsh 配置文件引入"
  echo "# 删除方法: 移除此区块，并删除 $ZSH_CONFIG_FILE"
  echo "[ -r \"$ZSH_CONFIG_FILE\" ] && source \"$ZSH_CONFIG_FILE\""
  echo "$ZSHRC_MARKER_END"
} > "$ZSHRC_SNIPPET"

if [ -f "$ZSHRC_FILE" ]; then
  ZSHRC_WITHOUT_MANAGED_BLOCK="$(mktemp)"
  awk -v start="$ZSHRC_MARKER_START" -v end="$ZSHRC_MARKER_END" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$ZSHRC_FILE" > "$ZSHRC_WITHOUT_MANAGED_BLOCK"
  cat "$ZSHRC_WITHOUT_MANAGED_BLOCK" "$ZSHRC_SNIPPET" > "$ZSHRC_FILE"
else
  cat "$ZSHRC_SNIPPET" > "$ZSHRC_FILE"
fi
echo "    ✓ ~/.zshrc (已写入 source 引入)"

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "请重启 Ghostty 终端生效。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧配置:"
  echo "  cp $BACKUP_DIR/ghostty-config ~/.config/ghostty/config"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo "  cp $BACKUP_DIR/ghostty-terminal-config.zsh $ZSH_CONFIG_FILE"
  echo "  cp $BACKUP_DIR/zshrc ~/.zshrc"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshrc 中 '>>> ghostty-terminal-config >>>' 到 '<<< ghostty-terminal-config <<<' 之间的所有内容"
echo "  rm -f $ZSH_CONFIG_FILE"
echo ""
