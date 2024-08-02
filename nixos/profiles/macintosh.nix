{ self
, lib
, config
, pkgs
, upkgs
, ...
}:

with lib;

let
  inherit (self.outputs) nixosModules;
in
{
  # Hardware is imported in the flake to be machine specific
  imports = map (modPath: ../modules/${modPath}) [
    "agenix.nix"
    # "logiops.nix"
    "nix.nix"
    "yabai.nix"
  ];

  security.pam.enableSudoTouchIdAuth = true;

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
}
