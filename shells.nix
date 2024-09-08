{ self
, lib
, lpkgs
, system
, ...
}@pkgs:

let
  inherit (self.outputs) packages;

  allSelfPackages = lib.mapAttrsToList (_: value: value) packages.${system};

  mkPackageShell = packages: pkgs.mkShell { inherit packages; };
in

{
  # Import packages of this flake along with useful tools for managing dotfiles
  default = mkPackageShell (with pkgs; [ just lpkgs.agenix ]);

  # Add presets that I can quickly use

  rust = mkPackageShell (with pkgs; [ rustup ]);

  go = mkPackageShell (with pkgs; [ go ]);

  python =
    let pythonEnv = pkgs.python3.withPackages (ps: with ps; [ ipython ]);
    in mkPackageShell [ pythonEnv ];
}
