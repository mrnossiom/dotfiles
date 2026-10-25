{ self, ... }:
{
  flake.modules.darwin.profile-macintosh = { ... }: {
    imports = with self.modules.darwin; [
      agenix
      fonts
      nix
      yabai
    ];

    config = {
      # Having a hard time with setting fish as default shell
      programs.zsh.enable = true;

      services.nix-daemon.enable = true;

      security.pam.enableSudoTouchIdAuth = true;

      system.keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
    };
  };
}
