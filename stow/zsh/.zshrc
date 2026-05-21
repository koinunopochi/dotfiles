# =============================================================================
# .zshrc — エントリポイント
# =============================================================================

ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-$HOME/.config/zsh}"

# OS 検出
case "$(uname -s)" in
  Darwin) _OS="macos" ;;
  Linux)  _OS="linux" ;;
  *)      _OS="unknown" ;;
esac

# 共通設定
[[ -f "$ZSH_CONFIG_DIR/core.zsh" ]] && source "$ZSH_CONFIG_DIR/core.zsh"

# OS 別設定
[[ -f "$ZSH_CONFIG_DIR/os/${_OS}.zsh" ]] && source "$ZSH_CONFIG_DIR/os/${_OS}.zsh"

# ローカル設定（環境固有、Git 管理外）
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# -----------------------------------------------------------------------------
# 開発ツール PATH（存在するディレクトリだけ追加）
#
# 環境ごとに入っている / 入っていないが分かれるので、ディレクトリチェックして
# from PATH を汚さない。新しい dev tool を増やすときはこの並びに足す。
# -----------------------------------------------------------------------------
[[ -d "$HOME/.local/bin" ]]    && export PATH="$HOME/.local/bin:$PATH"
[[ -d "/usr/local/go/bin" ]]   && export PATH="$PATH:/usr/local/go/bin"
[[ -d "$HOME/slack-cli/bin" ]] && export PATH="$PATH:$HOME/slack-cli/bin"   # koinunopochi/slack-cli
