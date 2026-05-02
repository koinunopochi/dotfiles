# =============================================================================
# .zshenv — 全 zsh セッションで読まれる（login / non-login / interactive 問わず）
# =============================================================================
# 環境変数（特に PATH）はここに置く。

# Nix の PATH を読み込む
# /etc/profile は bash 専用なので、zsh では明示的に source する必要がある
if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi
