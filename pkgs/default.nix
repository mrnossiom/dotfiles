{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix git-leave helix radicle wakatime-ls;
in
{
  asak = pkgs.callPackage ./asak.nix { };
  find-unicode = pkgs.callPackage ./find-unicode.nix { };
  # lazyjj = pkgs.callPackage ./lazyjj.nix { };
  names = pkgs.callPackage ./names.nix { };
  otree = pkgs.callPackage ./otree.nix { };
  probe-rs-udev-rules = pkgs.callPackage ./probe-rs-udev-rules.nix { };
  sweep = pkgs.callPackage ./sweep.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (helix.packages.${system}) helix;
  inherit (radicle.packages.${system}) radicle;
  inherit (wakatime-ls.packages.${system}) wakatime-ls;
}
