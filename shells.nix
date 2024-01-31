{ self
, lib
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
  default = mkPackageShell (allSelfPackages ++ [ ]);

  # Add presets that I can quicky use

  rust = mkPackageShell [ cargo ];

  python =
    let pythonEnv = python3.withPackages (ps: with ps; [ ipython ]);
    in mkPackageShell [ pythonEnv ];
}
