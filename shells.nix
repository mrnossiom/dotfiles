{ lpkgs
, ...
}@pkgs:

let
  mkPackageShell = packages: pkgs.mkShell { inherit packages; };
in

{
  # Import packages of this flake along with useful tools for managing dotfiles
  default = mkPackageShell (with pkgs; [
    lpkgs.agenix
    home-manager
    just
    nix-tree
  ]);

  # Add presets that I can quickly use

  rust = mkPackageShell (with pkgs; [ rustup ]);

  go = mkPackageShell (with pkgs; [ go ]);

  python =
    let pythonEnv = pkgs.python3.withPackages (ps: with ps; [ ipython ]);
    in mkPackageShell [ pythonEnv ];
}
