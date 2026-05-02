PACKAGES := vim tmux zsh
STOW_DIR := stow

.PHONY: help setup install uninstall reinstall check check-nix nix-deps direnv-config bash-hook direnv-allow

help:
	@echo "セットアップ:"
	@echo "  make setup       # 初期セットアップ一式（要 Nix）"
	@echo ""
	@echo "Stow 操作:"
	@echo "  make install     # symlink を貼る"
	@echo "  make uninstall   # symlink を外す"
	@echo "  make reinstall   # 貼り直し"
	@echo "  make check       # ドライラン"

# -----------------------------------------------------------------------------
# 一発セットアップ
# -----------------------------------------------------------------------------
setup: check-nix nix-deps direnv-config bash-hook
	@./install.sh -y
	@$(MAKE) direnv-allow
	@echo ""
	@echo "✓ Done. 新しいシェルを開いて 'cd ~/dotfiles' すると flake が自動展開されます。"

check-nix:
	@command -v nix >/dev/null 2>&1 || { \
	  echo "ERROR: Nix が必要です。先にインストールしてください:"; \
	  echo "  sh <(curl -L https://nixos.org/nix/install) --daemon"; \
	  exit 1; \
	}
	@mkdir -p $(HOME)/.config/nix
	@grep -q "experimental-features.*flakes" $(HOME)/.config/nix/nix.conf 2>/dev/null || { \
	  echo 'experimental-features = nix-command flakes' >> $(HOME)/.config/nix/nix.conf; \
	  echo "  → flake 有効化 (~/.config/nix/nix.conf)"; \
	}

nix-deps:
	@command -v direnv >/dev/null 2>&1 || nix profile add nixpkgs#direnv nixpkgs#nix-direnv
	@echo "  → direnv + nix-direnv: OK"

direnv-config:
	@mkdir -p $(HOME)/.config/direnv
	@grep -q nix-direnv $(HOME)/.config/direnv/direnvrc 2>/dev/null || { \
	  echo 'source $$HOME/.nix-profile/share/nix-direnv/direnvrc' >> $(HOME)/.config/direnv/direnvrc; \
	  echo "  → ~/.config/direnv/direnvrc を作成"; \
	}
	@echo "  → direnv 設定: OK"

bash-hook:
	@grep -q "direnv hook bash" $(HOME)/.bashrc 2>/dev/null || { \
	  echo 'command -v direnv >/dev/null 2>&1 && eval "$$(direnv hook bash)"' >> $(HOME)/.bashrc; \
	  echo "  → ~/.bashrc に direnv hook を追加"; \
	}
	@echo "  → bash hook: OK (zsh は core.zsh で自動有効化)"

direnv-allow:
	@direnv allow . 2>&1 | sed 's/^/  /' || true

# -----------------------------------------------------------------------------
# Stow 操作
# -----------------------------------------------------------------------------
install:
	cd $(STOW_DIR) && stow -t $(HOME) -v $(PACKAGES)

uninstall:
	cd $(STOW_DIR) && stow -t $(HOME) -D -v $(PACKAGES)

reinstall: uninstall install

check:
	cd $(STOW_DIR) && stow -t $(HOME) -nv $(PACKAGES)
