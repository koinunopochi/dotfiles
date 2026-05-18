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
│   ├── zsh/
│   │   ├── .zshrc                # → ~/.zshrc
│   │   └── .config/zsh/
│   │       ├── core.zsh          # → ~/.config/zsh/core.zsh
│   │       └── os/
│   │           ├── linux.zsh
│   │           └── macos.zsh
│   └── kawauso/
│       └── .config/kawauso/
│           └── config.toml       # → ~/.config/kawauso/config.toml
└── nix/
    └── home.nix                  # home-manager: 普段使う CLI ツールを宣言的に管理
```

## Setup Commands

### Nix を使う（推奨）

```bash
# 1. Nix を入れる（公式インストーラ）
sh <(curl -L https://nixos.org/nix/install) --daemon
# 新規シェルを開くか、現在のシェルで:
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. dotfiles を取得
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. 一発セットアップ
make setup
```

`make setup` は次を全部やる:

- `~/.config/nix/nix.conf` に flake 有効化を追記
- `home-manager switch --flake .#debian@workspace-1` で `nix/home.nix` の `home.packages` (direnv / nix-direnv / zsh / lazygit ほか) を `~/.nix-profile` に反映
- `~/.config/direnv/direnvrc` に nix-direnv を source
- `~/.bashrc` に direnv hook を追加（zsh は core.zsh で有効化済み）
- `install.sh -y` で stow による symlink（既存実体ファイルは自動で `.bak`）
- `direnv allow .` で flake を許可

新しい CLI ツールを追加したいときは `nix/home.nix` の `home.packages` に追記して `make hm-switch` するだけ。`nix profile add ...` を手で叩く必要はない。

### Nix を使わない（apt / brew）

```bash
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo apt install -y stow      # or: brew install stow
make install
```

### Make ターゲット一覧

```bash
make help        # 一覧表示
make setup       # 初期セットアップ一式（要 Nix）
make hm-switch   # nix/home.nix を反映（新規ツール追加時）
make install     # symlink を貼る
make uninstall   # symlink を外す
make reinstall   # 貼り直し
make check       # ドライラン
```

## Stow Packages

| パッケージ | 内容 | symlink 先 |
|-----------|------|-----------|
| `vim` | `.vimrc` | `~/.vimrc` |
| `tmux` | `.tmux.conf` | `~/.tmux.conf` |
| `zsh` | `.zshrc`, `.config/zsh/*` | `~/.zshrc`, `~/.config/zsh/*` |
| `kawauso` | `.config/kawauso/config.toml` | `~/.config/kawauso/config.toml` |

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
