{ ...
}:

{
  config = {
    local.fragment = {
      agenix.enable = true;
      fonts.enable = true;
      helix.enable = true;
      nix.enable = true;
      yabai.enable = true;
    };

    # Having a hard time with setting fish as default shell
    programs.zsh.enable = true;

    services.nix-daemon.enable = true;

    security.pam.enableSudoTouchIdAuth = true;

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
