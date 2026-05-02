#!/usr/bin/env bash
# =============================================================================
# install.sh — Stow で dotfiles を symlink する
# =============================================================================
set -euo pipefail

DOT_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(vim tmux zsh)

if ! command -v stow >/dev/null 2>&1; then
  echo "ERROR: stow が見つかりません。"
  echo "  - Nix を使うなら: nix develop  # devShell に入って再実行"
  echo "  - apt なら:       sudo apt install stow"
  echo "  - brew なら:      brew install stow"
  exit 1
fi

cd "$DOT_DIR/stow"

# 既存ファイルが実体（symlink ではない）か確認
echo "=== 既存ファイル確認 ==="
conflict=0
for pkg in "${PACKAGES[@]}"; do
  while IFS= read -r src; do
    rel="${src#$pkg/}"
    target="$HOME/$rel"
    if [[ -e "$target" && ! -L "$target" ]]; then
      echo "  WARN: $target は実体ファイル"
      echo "        バックアップ推奨: mv $target $target.bak"
      conflict=1
    fi
  done < <(find "$pkg" -type f)
done

if [[ $conflict -eq 1 ]]; then
  echo ""
  read -rp "既存実体ファイルを .bak に退避してから続行しますか? [y/N]: " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    for pkg in "${PACKAGES[@]}"; do
      while IFS= read -r src; do
        rel="${src#$pkg/}"
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" ]]; then
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
