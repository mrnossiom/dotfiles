{ self, ... }:
{
  flake.modules.homeManager.profile-lightweight = { pkgs, lib, ... }: {
    imports = with self.modules.homeManager; [
      git
      helix
      jujutsu
      shell
      zellij
    ];

    config = {
      local.flags.onlyCached = true;

      programs.jujutsu.settings.signing.key = lib.mkForce self.keys.epita;

      home.packages = with pkgs; [
        # GUIs
        pavucontrol

        # CLIs
        wf-recorder
        wl-clipboard
        xdg-utils
      ];

      programs.alacritty = {
        enable = true;
        package = null;
        settings = {
          terminal.shell = "fish";
          bell.duration = 1000;
        };
      };

      programs.bat = {
        enable = true;
        config = {
          style = "plain";
        };
      };

      fonts.fontconfig.defaultFonts = {
        monospace = "JetBrainsMono Nerd Font";
      };

      services.autotiling = {
        enable = true;
        package = pkgs.autotiling-rs;
      };
    };
  };
}
