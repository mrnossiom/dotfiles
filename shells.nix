{ self, lib, system, ... }@pkgs:

with lib;

let
  inherit (self.outputs) packages;

  allSelfPackages = mapAttrsToList (_: value: value) packages.${system};

  mkPackageShell = packages: pkgs.mkShell { inherit packages; };

in
{
  # Import packages of this flake along with useful tools for managing dotfiles
  default = mkPackageShell (allSelfPackages ++ [ ]);

  # Add presets that I can quicky use

  rust = mkPackageShell (with pkgs; [ cargo ]);
}
