PACKAGES := vim tmux zsh
STOW_DIR := stow

.PHONY: install uninstall reinstall check help

help:
	@echo "make install    # stow で symlink を貼る"
	@echo "make uninstall  # stow の symlink を外す"
	@echo "make reinstall  # 貼り直し"
	@echo "make check      # 何が起きるかドライラン"

install:
	cd $(STOW_DIR) && stow -t $(HOME) -v $(PACKAGES)

uninstall:
	cd $(STOW_DIR) && stow -t $(HOME) -D -v $(PACKAGES)

reinstall: uninstall install

check:
	cd $(STOW_DIR) && stow -t $(HOME) -nv $(PACKAGES)
