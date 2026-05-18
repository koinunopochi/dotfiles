PACKAGES := vim tmux zsh kawauso
STOW_DIR := stow

# home-manager configuration 名 (flake.nix の homeConfigurations のキー)
HM_NAME := debian@workspace-1

.PHONY: help setup install uninstall reinstall check check-nix hm-switch direnv-config bash-hook direnv-allow login-shell

help:
	@echo "セットアップ:"
	@echo "  make setup        # 初期セットアップ一式（要 Nix）"
	@echo ""
	@echo "Home-Manager:"
	@echo "  make hm-switch    # nix/home.nix を反映（新規ツール追加時）"
	@echo ""
	@echo "Stow 操作:"
	@echo "  make install      # symlink を貼る"
	@echo "  make uninstall    # symlink を外す"
	@echo "  make reinstall    # 貼り直し"
	@echo "  make check        # ドライラン"

# -----------------------------------------------------------------------------
# 一発セットアップ
# -----------------------------------------------------------------------------
# 最後に exec で現在シェルを zsh に切替える（make recipe の subshell が
# zsh に置き換わるので、Ctrl-D で抜けると make 呼び出し元の bash に戻る）。
setup: check-nix hm-switch direnv-config bash-hook
	@nix develop --command ./install.sh -y
	@$(MAKE) direnv-allow
	@$(MAKE) login-shell
	@echo ""
	@echo "✓ Done. 今のシェルを zsh に切替えます (Ctrl-D で元の bash に戻ります)..."
	@exec $(HOME)/.nix-profile/bin/zsh -l

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

# -----------------------------------------------------------------------------
# Home-Manager
# -----------------------------------------------------------------------------
# nix/home.nix の home.packages を ~/.nix-profile/ に反映する。
# 旧 `nix profile add` (GLOBAL_NIX_PKGS) はこちらに統合済み。
# 初回 / 既存 nix profile と衝突する場合は -b hm-backup で .hm-backup に退避。
hm-switch:
	@echo "  → home-manager switch (.#$(HM_NAME))"
	@nix run home-manager -- switch --flake .#$(HM_NAME) -b hm-backup

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
# ログインシェルを zsh に切替
# -----------------------------------------------------------------------------
login-shell:
	@ZSH_PATH="$(HOME)/.nix-profile/bin/zsh"; \
	[ -x "$$ZSH_PATH" ] || { echo "ERROR: $$ZSH_PATH が無い。先に 'make hm-switch'"; exit 1; }; \
	if ! grep -qx "$$ZSH_PATH" /etc/shells 2>/dev/null; then \
	  echo "  → /etc/shells に $$ZSH_PATH を追加（sudo）"; \
	  echo "$$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null; \
	fi; \
	CURRENT="$$(getent passwd $$USER | awk -F: '{print $$7}')"; \
	if [ "$$CURRENT" = "$$ZSH_PATH" ]; then \
	  echo "  → ログインシェルは既に zsh"; \
	else \
	  echo "  → chsh で $$ZSH_PATH に切替（パスワード入力あり）"; \
	  chsh -s "$$ZSH_PATH"; \
	  echo "  ✓ 次回ログインから zsh"; \
	fi

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
