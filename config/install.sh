#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------------------------
# Ubuntu/Debian 自动化安装脚本
# 安装：vim、git、zsh、zinit、Lua(带版本回退)、Powerlevel10k，并设置 zsh 为默认 shell
# 说明：
# - 针对 Ubuntu/Debian (apt) 设计；需要网络和 sudo 权限
# - zinit 与 p10k 会安装给目标普通用户（sudo 时优先使用 $SUDO_USER）
# -----------------------------------------------------------------------------

log() { echo -e "\033[1;32m==>\033[0m $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $*" >&2; }
err() { echo -e "\033[1;31m[ERR]\033[0m $*" >&2; }

# 仅限 apt 系
if ! command -v apt-get >/dev/null 2>&1; then
  err "本脚本仅适用于 Ubuntu/Debian（需 apt-get）。"
  exit 1
fi

# 目标用户与家目录（zinit/p10k 需安装到普通用户环境）
TARGET_USER="${SUDO_USER:-${USER}}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6 2>/dev/null || echo "${HOME}")"

# sudo 助手
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

export DEBIAN_FRONTEND=noninteractive

# 安装可用性检查
is_available() {
  # 候选版本不是 none 则认为可安装
  apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2}' | grep -vq "^none$"
}

ensure_pkg() {
  local pkg="$1"
  if dpkg -s "$pkg" >/dev/null 2>&1; then
    return 0
  fi
  $SUDO apt-get install -y "$pkg"
}

ensure_one_of() {
  # 从参数列表中选择第一个可用包进行安装
  for pkg in "$@"; do
    if is_available "$pkg"; then
      ensure_pkg "$pkg"
      return 0
    fi
  done
  return 1
}

log "更新 apt 源..."
$SUDO apt-get update -y

log "安装基础工具：curl、git、vim、zsh..."
ensure_pkg ca-certificates
ensure_pkg curl
ensure_pkg wget
ensure_pkg git
ensure_pkg vim
ensure_pkg zsh

log "安装 Lua（带版本回退）..."
if ! ensure_one_of lua5.4 lua5.3 lua5.2 lua5.1 lua; then
  warn "未找到可安装的 Lua 包（尝试 lua5.4/5.3/5.2/5.1/lua），跳过。"
fi

log "可选：安装 Powerline 字体以改善终端渲染..."
if is_available fonts-powerline; then
  ensure_pkg fonts-powerline
fi

log "为用户 ${TARGET_USER} 安装 zinit..."
ZINIT_DIR="${TARGET_HOME}/.local/share/zinit/zinit.git"
if [[ ! -s "${ZINIT_DIR}/zinit.zsh" ]]; then
  # 以目标普通用户身份执行 zinit 官方安装脚本
  $SUDO -u "$TARGET_USER" bash -lc 'bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"'
else
  log "zinit 已存在，跳过安装。"
fi

log "确保 Powerlevel10k（p10k）可通过 zinit 加载..."
ZSHRC="${TARGET_HOME}/.zshrc"
if [[ ! -f "$ZSHRC" ]] || ! grep -q 'romkatv/powerlevel10k' "$ZSHRC" 2>/dev/null; then
  log "在 ${ZSHRC} 中追加 p10k 的 zinit 加载片段。"
  $SUDO -u "$TARGET_USER" mkdir -p "${TARGET_HOME}"
  # 追加最小可用片段（如用户已有更完善的 .zshrc，请自行合并）
  $SUDO -u "$TARGET_USER" bash -lc "cat >> '$ZSHRC' <<'EOF'
# ----- Added by install.sh: Powerlevel10k via zinit -----
if [[ -f \"\$HOME/.local/share/zinit/zinit.git/zinit.zsh\" ]]; then
  source \"\$HOME/.local/share/zinit/zinit.git/zinit.zsh\"
  zinit ice depth=1
  zinit light romkatv/powerlevel10k
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# --------------------------------------------------------
EOF"
else
  log "检测到 .zshrc 已包含 p10k 加载，跳过注入。"
fi

log "设置 zsh 为默认 shell..."
ZSH_PATH="$(command -v zsh)"
if [[ -z "${ZSH_PATH}" ]]; then
  err "未找到 zsh 可执行文件。"
else
  # 确保 /etc/shells 包含 zsh
  if ! grep -q "^${ZSH_PATH}\$" /etc/shells 2>/dev/null; then
    echo "${ZSH_PATH}" | $SUDO tee -a /etc/shells >/dev/null || true
  fi
  # 切换默认 shell（优先切换调用者）
  if [[ -n "${SUDO_USER:-}" ]]; then
    if $SUDO chsh -s "${ZSH_PATH}" "${SUDO_USER}"; then
      log "已将 ${SUDO_USER} 的默认 shell 设置为 zsh。"
    else
      warn "为 ${SUDO_USER} 设置默认 shell 失败（可能需手动执行：sudo chsh -s ${ZSH_PATH} ${SUDO_USER}）。"
    fi
  else
    if chsh -s "${ZSH_PATH}"; then
      log "已将当前用户的默认 shell 设置为 zsh。"
    else
      warn "设置默认 shell 失败（可能需手动执行：chsh -s ${ZSH_PATH}）。"
    fi
  fi
fi

log "全部完成！建议后续操作："
echo "  - 打开新终端（zsh 首次启动可运行 p10k configure 完成主题配置）"
echo "  - 如使用 WSL，记得在终端配置里选择 Nerd Font（如 MesloLGS NF）"


