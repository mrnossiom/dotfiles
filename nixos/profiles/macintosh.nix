{ lib
, pkgs
, ...
}:

with lib;

{
  # Hardware is imported in the flake to be machine specific
  imports = map (modPath: ../fragments/${modPath}) [
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

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
  ];
}
