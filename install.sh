#!/usr/bin/env bash
# =============================================================================
# install.sh — Stow で dotfiles を symlink する
# =============================================================================
set -euo pipefail

DOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(vim tmux zsh)

# -y で対話なし（既存実体ファイルは自動で .bak に退避）
AUTO_YES=0
[[ "${1:-}" == "-y" ]] && AUTO_YES=1

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: stow が見つかりません。"
  echo "  - Nix を使うなら: nix develop  # devShell に入って再実行"
  echo "  - apt なら:       sudo apt install stow"
  echo "  - brew なら:      brew install stow"
  exit 1
fi

cd "$DOT_DIR/stow"

# 過去に stow した状態をクリーンに戻す（初回は no-op）
# これをしないと tree-folded symlink (~/.config/zsh など) 経由で
# dotfiles 内の実ファイルを「実体ファイル」と誤検出してしまい、
# .bak 退避時に dotfiles 内ファイルをリネームしてしまう。
echo "=== 既存 symlink を一度クリア ==="
stow -t "$HOME" -D "${PACKAGES[@]}" 2>/dev/null || true
echo ""

# 既存ファイルが実体（symlink ではない）か確認
# parent ディレクトリのいずれかが symlink なら dotfiles 配下扱いとして除外
is_under_symlinked_dir() {
  local p
  p="$(dirname "$1")"
  while [[ "$p" != "$HOME" && "$p" != "/" && -n "$p" ]]; do
    [[ -L "$p" ]] && return 0
    p="$(dirname "$p")"
  done
  return 1
}

echo "=== 既存実体ファイル確認 ==="
conflict=0
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r src; do
    rel="${src#$pkg/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]] && ! is_under_symlinked_dir "$target"; then
      echo "  WARN: $target は実体ファイル"
      echo "        バックアップ推奨: mv $target $target.bak"
      conflict=1
    fi
  done < <(find "$pkg" -type f)
done

if [[ $conflict -eq 1 ]]; then
  echo ""
  if [[ $AUTO_YES -eq 1 ]]; then
    ans=y
    echo "  → -y 指定のため自動で .bak に退避"
  else
    read -rp "既存実体ファイルを .bak に退避してから続行しますか? [y/N]: " ans
  fi
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    for pkg in "${PACKAGES[@]}"; do
      while IFS= read -r src; do
        rel="${src#$pkg/}"
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]] && ! is_under_symlinked_dir "$target"; then
          mv -v "$target" "$target.bak"
        fi
      done < <(find "$pkg" -type f)
    done
  else
    echo "中断しました。"
    exit 1
  fi
fi

echo ""
echo "=== stow 実行 ==="
stow -t "$HOME" -v "${PACKAGES[@]}"

echo ""
echo "Done."
