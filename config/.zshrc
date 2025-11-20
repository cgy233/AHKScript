# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# -----------------------------------------------------------------------------
# 平台与环境检测（跨 Ubuntu / Arch / WSL）
# -----------------------------------------------------------------------------
_is_interactive=false
[[ $- == *i* ]] && _is_interactive=true

has() { command -v "$1" >/dev/null 2>&1; }

_is_wsl=false
if [[ -f /proc/sys/kernel/osrelease ]] && command grep -qi "microsoft" /proc/sys/kernel/osrelease 2>/dev/null; then
  _is_wsl=true
fi


if $_is_interactive; then
### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit ice depth=1; zinit light romkatv/powerlevel10k
### End of Zinit's installer chunk
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if $_is_interactive; then [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh; fi

# -----------------------------------------------------------------------------
# Zsh 基础选项与补全
# -----------------------------------------------------------------------------
if $_is_interactive; then
  autoload -Uz compinit
  if [[ -z "$ZSH_COMPDUMP" ]]; then
    ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
    mkdir -p "${ZSH_COMPDUMP:h}"
  fi
  compinit -d "$ZSH_COMPDUMP"
fi

setopt autocd
setopt interactivecomments
setopt share_history
setopt inc_append_history
setopt extendedglob
unsetopt beep

# -----------------------------------------------------------------------------
# 插件（使用 Zinit 管理）
# -----------------------------------------------------------------------------
if $_is_interactive; then
  zinit light skywind3000/z.lua
  if has fzf; then
    zinit light Aloxaf/fzf-tab
  fi
  zinit light paulirish/git-open
  zinit light zsh-users/zsh-completions
  zinit light zsh-users/zsh-autosuggestions
  zinit light zdharma-continuum/fast-syntax-highlighting
  zinit light romkatv/gitstatus

  # Oh My Zsh 核心片段与插件（通过 zinit snippet）
  zinit snippet OMZ::lib/git.zsh
  zinit snippet OMZ::plugins/git/git.plugin.zsh
  zinit snippet OMZ::lib/clipboard.zsh
  zinit snippet OMZ::lib/completion.zsh
  zinit snippet OMZ::lib/history.zsh
  zinit snippet OMZ::lib/key-bindings.zsh
  zinit snippet OMZ::lib/theme-and-appearance.zsh
  #zinit snippet OMZ::plugins/pacman/pacman.plugin.zsh
  zinit snippet OMZP::cp
fi

# -----------------------------------------------------------------------------
# 别名（跨平台与可用性检测）
# -----------------------------------------------------------------------------
og() {
  if has git-open; then
    command git open "$@"
    return
  fi
  local url
  url=$(git config --get remote.origin.url 2>/dev/null) || return 1
  url=${url/git@/https://}
  url=${url/:/\//}
  url=${url%.git}
  if $_is_wsl; then
    cmd.exe /c start "" "$url" >/dev/null 2>&1
  else
    command -v xdg-open >/dev/null 2>&1 && xdg-open "$url" >/dev/null 2>&1
  fi
}
alias cls='clear'
if has eza; then
  alias ls='eza --icons'
  alias ll='eza -l --icons --git'
  alias la='eza -la --icons --git'
  alias lt='eza --tree --icons'
  alias l='eza -l --icons --git --time-style=relative'
else
  alias ls='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias la='ls -la --color=auto'
  alias lt='ls -R --color=auto'
  alias l='ls -l --color=auto'
fi
[[ -x "$HOME/scripts/jj.sh" ]] && alias jj='$HOME/scripts/jj.sh'
has cursor && alias cs='cursor'

# -----------------------------------------------------------------------------
# PATH 与本地环境
# -----------------------------------------------------------------------------
if $_is_wsl; then
  export PATH="$PATH:/mnt/c/Windows/System32"
fi