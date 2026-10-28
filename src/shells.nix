{
  perSystem = { pkgs, inputs', ... }: {
    # Useful tools for managing these dotfiles
    devShells.default = pkgs.mkShellNoCC {
      packages = with pkgs; [
        inputs'.agenix.packages.agenix
        home-manager
        just
        nixos-anywhere

        nix-inspect
        nix-output-monitor
        nix-tree

        opentofu
        tofu-ls
      ];
    };
  };
}
