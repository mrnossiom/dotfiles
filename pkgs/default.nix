{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix ghostty git-leave helix jujutsu wakatime-ls;
in
{
  asak = pkgs.callPackage ./asak.nix { };
  cura = pkgs.callPackage ./cura.nix { };
  ebnfer = pkgs.callPackage ./ebnfer.nix { };
  find-unicode = pkgs.callPackage ./find-unicode.nix { };
  names = pkgs.callPackage ./names.nix { };
  otree = pkgs.callPackage ./otree.nix { };
  probe-rs-udev-rules = pkgs.callPackage ./probe-rs-udev-rules.nix { };
  sweep = pkgs.callPackage ./sweep.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (ghostty.packages.${system}) ghostty;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (helix.packages.${system}) helix;
  inherit (jujutsu.packages.${system}) jujutsu;
  inherit (wakatime-ls.packages.${system}) wakatime-ls;
}
