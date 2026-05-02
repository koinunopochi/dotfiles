# =============================================================================
# 全 OS 共通設定
# =============================================================================

# -----------------------------------------------------------------------------
# 色付き出力 + ls エイリアス（OS 共通で ll / la / l を使えるようにする）
# -----------------------------------------------------------------------------
autoload -U colors && colors

# OS ごとに ls の color オプションが違うので、ここで吸収する
case "$(uname -s)" in
  Darwin) alias ls='ls -G' ;;          # BSD ls
  Linux)  alias ls='ls --color=auto' ;; # GNU ls
esac

# ls エイリアス（zsh の alias 再帰展開で OS 別の ls にチェーンされる）
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# -----------------------------------------------------------------------------
# プロンプト（Git ブランチ表示付き）
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
setopt PROMPT_SUBST

PROMPT='%F{green}%n@%m%f:%F{blue}%~%f${vcs_info_msg_0_} %# '

# -----------------------------------------------------------------------------
# 補完（タブ補完）
# -----------------------------------------------------------------------------
autoload -Uz compinit
compinit

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select

# -----------------------------------------------------------------------------
# ヒストリ
# -----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# 上下矢印でヒストリ検索（入力中の文字列でフィルタ）
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search
bindkey '^R' history-incremental-search-backward

# -----------------------------------------------------------------------------
# 便利な設定
# -----------------------------------------------------------------------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
