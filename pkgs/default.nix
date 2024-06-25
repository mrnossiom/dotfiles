{ self, system, ... }@pkgs:

let
  inherit (self.inputs) agenix git-leave mind radicle wakatime-lsp;
in
{
  arduino-udev-rules = pkgs.callPackage ./arduino-udev-rules.nix { };
  find-unicode = pkgs.callPackage ./find-unicode.nix { };
  git-along = pkgs.callPackage ./git-along.nix { };
  lazyjj = pkgs.callPackage ./lazyjj.nix { };
  names = pkgs.callPackage ./names.nix { };
  otree = pkgs.callPackage ./otree.nix { };
  probe-rs-udev-rules = pkgs.callPackage ./probe-rs-udev-rules.nix { };
  sweep = pkgs.callPackage ./sweep.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (mind.packages.${system}) mind;
  inherit (radicle.packages.${system}) radicle;
  inherit (wakatime-lsp.packages.${system}) wakatime-lsp;
}
