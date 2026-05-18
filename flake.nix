{
  description = "koinunopochi minimal dotfiles — vim / tmux / zsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager }:
    let
      mkVim = pkgs:
        pkgs.vim-full.customize {
          name = "vim";
          vimrcConfig.customRC = builtins.readFile ./stow/vim/.vimrc;
          vimrcConfig.packages.dotfiles = with pkgs.vimPlugins; {
            start = [ vim-oscyank ];
          };
        };
    in
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        vimWithPlugins = mkVim pkgs;
      in
      {
        packages = {
          vim = vimWithPlugins;
          default = vimWithPlugins;
        };

        # devShell では dotfiles を編集・操作するためのツールを揃える。
        devShells.default = pkgs.mkShell {
          buildInputs = [
            vimWithPlugins
            pkgs.tmux
            pkgs.zsh
            pkgs.stow
            pkgs.git
          ];

          shellHook = ''
            echo "dotfiles dev shell — vim/tmux/zsh + stow"
          '';
        };
      })) // {
        # ---------------------------------------------------------------------
        # home-manager: 普段使う CLI ツールを宣言的に管理
        # ---------------------------------------------------------------------
        # 反映: `make hm-switch`
        #       (= `nix run home-manager -- switch --flake .#debian@workspace-1`)
        # 新規ツールは nix/home.nix の home.packages に追記する。
        homeConfigurations."debian@workspace-1" =
          home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [ ./nix/home.nix ];
          };
      };
}
