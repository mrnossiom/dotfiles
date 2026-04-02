{
  lpkgs,
  ...
}@pkgs:

let
  mkPackageShell = packages: pkgs.mkShell { inherit packages; };
in

{
  # Import packages of this flake along with useful tools for managing dotfiles
  default = mkPackageShell (
    with pkgs;
    [
      lpkgs.agenix
      home-manager
      just
      nix-inspect
      nixos-anywhere
      nix-tree
      opentofu
      tofu-ls
    ]
  );
}
