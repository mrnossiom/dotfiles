{ self, ... }:
let
  isDarwin = false;
in
{
  flake.modules.homeManager.profile-lightweight = { pkgs, lib, ... }: {
    imports = [
      # self.modules.homeManager.agenix
      self.modules.homeManager.git
      self.modules.homeManager.helix
      self.modules.homeManager.jujutsu
      self.modules.homeManager.shell
      # self.modules.homeManager.tools
      self.modules.homeManager.zellij
    ];

    config = {
      assertions = [
        {
          assertion = !isDarwin;
          message = "this is a HM non-darwin config";
        }
      ];

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
