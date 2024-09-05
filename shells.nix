{ self
, lib
, lpkgs
, system
, ...
}@pkgs:

with lib;

let
  inherit (self.outputs) packages;

  allSelfPackages = mapAttrsToList (_: value: value) packages.${system};

  mkPackageShell = packages: pkgs.mkShell { inherit packages; };
in

with pkgs;

{
  # Import packages of this flake along with useful tools for managing dotfiles
  default = mkPackageShell (with pkgs; [ just lpkgs.agenix ]);

  # Add presets that I can quickly use

  rust = mkPackageShell [ rustup ];

  go = mkPackageShell [ go ];

  python =
    let pythonEnv = python3.withPackages (ps: with ps; [ ipython ]);
    in mkPackageShell [ pythonEnv ];
}
