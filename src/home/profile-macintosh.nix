{ self, ... }:
{
  flake.modules.homeManager.profile-macintosh = { config, pkgs, ... }: {
    imports = with self.modules.homeManager; [
      git
      jujutsu
      shell
      tools
    ];

    config = {
      assertions = [
        {
          assertion = pkgs.stdenv.isDarwin;
          message = "this is a HM darwin-only config";
        }
      ];

      home.packages = with pkgs; [
        just
      ];

      programs.bat = {
        enable = true;
        config = {
          style = "plain";
        };
      };

      programs.gpg = {
        enable = true;
        homedir = "${config.xdg.dataHome}/gnupg";
      };
    };
  };
}
