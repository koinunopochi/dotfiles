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
git clone git@github.com:koinunopochi/dotfiles.git ~/dotfiles
cd ~/dotfiles
direnv allow      # use flake が走る
make install      # stow で symlink を貼る
```

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
