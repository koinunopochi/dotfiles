{ config, pkgs, ... }:

# 普段使う CLI ツールを宣言的に管理する。
# 反映: `make hm-switch`
#
# 設定ファイル (.zshrc / .tmux.conf / .vimrc) は引き続き stow で symlink する。
# home-manager の programs.* への移行は Phase 2 として後日検討。
{
  home.username = "debian";
  home.homeDirectory = "/home/debian";

  # 初回 home-manager 導入時のリリース。値を変えると挙動が変わるので固定する。
  # See: https://nix-community.github.io/home-manager/options.html#opt-home.stateVersion
  home.stateVersion = "25.05";

  # `home-manager` コマンド自体を利用可能にする
  programs.home-manager.enable = true;

  # 新規ツールはここに追記して `make hm-switch`
  home.packages = with pkgs; [
    direnv
    nix-direnv
    zsh
    lazygit
  ];
}
