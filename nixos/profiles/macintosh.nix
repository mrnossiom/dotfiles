{ pkgs
, ...
}:

{
  config = {
    local.fragment.agenix.enable = true;
    local.fragment.nix.enable = true;
    local.fragment.yabai.enable = true;

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
  };
}
