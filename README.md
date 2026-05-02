# dotfiles

koinunopochi の vim/tmux/zsh dotfiles。

## 設計

- **vim 起動が爆速**（プラグインは最小限）
- **薄く小さく**（最小限の管理機構）
- **GNU Stow で symlink 管理**
- **Nix + direnv でツール管理**

## セットアップ

### Nix を使う（推奨）

```bash
# 1. Nix を入れる（一度だけ）
sh <(curl -L https://nixos.org/nix/install) --daemon
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

# 2. dotfiles を取得して一発セットアップ
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
make setup
```

`make setup` 一発で次が全部入る:

- flake 有効化 (`~/.config/nix/nix.conf`)
- `direnv` + `nix-direnv` を Nix profile に install
- shell hook を `~/.bashrc` に追加（zsh は `core.zsh` で自動）
- stow で symlink（既存ファイルは自動で `.bak`）
- `direnv allow` で flake を許可

以降、`cd ~/dotfiles` するだけで vim/tmux/zsh/stow が Nix 版に切り替わる。

### Nix を使わない

```bash
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo apt install -y stow   # or: brew install stow
make install
```

## ファイル構成

```
~/dotfiles/
├── stow/
│   ├── vim/.vimrc                    → ~/.vimrc
│   ├── tmux/.tmux.conf               → ~/.tmux.conf
│   └── zsh/
│       ├── .zshrc                    → ~/.zshrc
│       └── .config/zsh/
│           ├── core.zsh              → ~/.config/zsh/core.zsh
│           └── os/{linux,macos}.zsh
├── flake.nix                         # vim + プラグイン + tmux + zsh + stow
├── .envrc                            # direnv (use flake)
├── Makefile                          # make install / uninstall / check
└── install.sh                        # 対話式インストーラ
```

## 使い方

```bash
make check       # ドライラン
make install     # symlink を貼る
make uninstall   # symlink を外す
make reinstall   # 貼り直し
```

## ローカル設定

`~/.zshrc.local` に環境固有の設定を書く（Git 管理外）:

```bash
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
```

## ライセンス

MIT
