{
  description = "koinunopochi minimal dotfiles — vim / tmux / zsh";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        vimWithPlugins = pkgs.vim-full.customize {
          name = "vim";
          vimrcConfig.customRC = builtins.readFile ./stow/vim/.vimrc;
          vimrcConfig.packages.dotfiles = with pkgs.vimPlugins; {
            start = [ vim-oscyank ];
          };
        };
      in
      {
        packages = {
          vim = vimWithPlugins;
          default = vimWithPlugins;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            vimWithPlugins
            pkgs.tmux
            pkgs.zsh
            pkgs.stow
            pkgs.direnv
            pkgs.git
          ];

          shellHook = ''
            echo "dotfiles dev shell — vim/tmux/zsh + stow"
          '';
        };
      });
}
