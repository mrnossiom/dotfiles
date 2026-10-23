{ self, ... }:
{
  flake.modules.nixos.profile-macintosh = { ... }: {
    imports = [
      self.modules.nixos.agenix
      self.modules.nixos.fonts
      self.modules.nixos.helix
      self.modules.nixos.nix
      self.modules.nixos.yabai
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
