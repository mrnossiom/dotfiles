{ self, ... }:
{
  flake.modules.darwin.profile-macintosh = { ... }: {
    imports = [
      self.modules.darwin.agenix
      self.modules.darwin.fonts
      self.modules.darwin.nix
      self.modules.darwin.yabai
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
