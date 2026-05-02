# dotfiles — koinunopochi の vim/tmux/zsh 管理

## Project Overview

vim/tmux/zsh を中心とした薄い dotfiles。GNU Stow で `~` 配下に symlink を貼る。
ツール（vim 本体・プラグイン・stow・direnv 等）は Nix で宣言的に管理し、direnv で dotfiles ディレクトリ局所に有効化する。

設計の優先順位は次の通り。

1. **vim 起動が爆速であること**（プラグインを増やさない、重い initialization を入れない）
2. **薄く小さく**（最小限の設定・最小限の管理機構）
3. **Stow で symlink 管理**（追加・削除を構造で表現）
4. **Nix + direnv でツール管理**（インストールを宣言的に）

## Directory Structure

```
~/dotfiles/                       # このリポジトリ（koinunopochi/dotfiles）
├── .gitignore
├── .envrc                        # direnv: use flake
├── flake.nix                     # vim + プラグイン + tmux + zsh + stow + direnv
├── flake.lock                    # nix develop 時に生成
├── Makefile                      # make install / uninstall / check
├── install.sh                    # 対話式インストーラ（stow ラッパー）
├── README.md
├── AGENTS.md                     # このファイル
├── CLAUDE.md                     # @AGENTS.md
├── stow/                         # Stow パッケージ
│   ├── vim/
│   │   └── .vimrc                # → ~/.vimrc
│   ├── tmux/
│   │   └── .tmux.conf            # → ~/.tmux.conf
│   └── zsh/
│       ├── .zshrc                # → ~/.zshrc
│       └── .config/zsh/
│           ├── core.zsh          # → ~/.config/zsh/core.zsh
│           └── os/
│               ├── linux.zsh
│               └── macos.zsh
└── nix/                          # 拡張用（home-manager 等を将来検討）
```

## Setup Commands

### Nix を使う（推奨）

```bash
# Nix インストール（公式インストーラ）
sh <(curl -L https://nixos.org/nix/install) --daemon

# flake 有効化
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

# direnv + nix-direnv をグローバルに入れる
nix profile add nixpkgs#direnv nixpkgs#nix-direnv

# direnv が nix-direnv を使うように
mkdir -p ~/.config/direnv
echo 'source $HOME/.nix-profile/share/nix-direnv/direnvrc' >> ~/.config/direnv/direnvrc

# direnv hook をシェルに追加
# zsh の場合は dotfiles の core.zsh で自動有効化される
# bash の場合は ~/.bashrc に追記:
echo 'command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"' >> ~/.bashrc

# dotfiles を取得
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
direnv allow                  # cd するだけで vim/tmux/zsh/stow が Nix 版に切り替わる
make install                  # stow で symlink を貼る
```

### Nix を使わない（apt / brew）

```bash
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo apt install -y stow      # or: brew install stow
make install
```

### 確認

```bash
make check                    # ドライラン（何が symlink されるか）
```

## Stow Packages

| パッケージ | 内容 | symlink 先 |
|-----------|------|-----------|
| `vim` | `.vimrc` | `~/.vimrc` |
| `tmux` | `.tmux.conf` | `~/.tmux.conf` |
| `zsh` | `.zshrc`, `.config/zsh/*` | `~/.zshrc`, `~/.config/zsh/*` |

新しいパッケージを追加するときは `stow/<pkg>/` を作り、`Makefile` の `PACKAGES` と `install.sh` の `PACKAGES` に1行追加する。

## Vim Plugins

- 本体: `pkgs.vim-full.customize` で flake 管理
- プラグイン: `pkgs.vimPlugins.<name>` を `start = [ ... ]` に追加
- 現在管理中: `vim-oscyank`（OSC52 でクリップボード連携）

プラグインを増やす場合の判断軸:
- 起動時間に影響しないか（lazy load 可能か）
- 本当に必要か（標準機能で代替できないか）

## Code Style Guidelines

- シェルスクリプトは `#!/usr/bin/env bash` + `set -euo pipefail`
- ファイル名はケバブケース
- 1ファイル1トピック
- 不要な抽象化を避ける（薄く保つ）

## Commit Guidelines

- Conventional Commits 形式: `type(scope): description`
- 日本語可
- 変更の目的を1行目に簡潔に

## Push Policy（重要）

- **このリポへの `git push` は、必ずユーザーに最終確認してから実行する**
- AI エージェントは勝手に push しない
- リモートは public なので、commit 内容を必ず目視確認

## Security Considerations

- `~/.zshrc.local` に API キーや認証情報を置く（Git 管理外、`.gitignore` 済み）
- `.env`, `*.local` は `.gitignore` で除外
- 公開リポなので、機密情報は絶対にコミットしない
