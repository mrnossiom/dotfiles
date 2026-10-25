{ self, inputs, ... }:
{
  flake.modules.homeManager.profile-macintosh = { config, pkgs, ... }: {
    imports = [
      inputs.agenix.homeManagerModules.default
      {
        # This allows us to decrypt user space secrets without having to use a
        # passwordless ssh key as you cannot interact with age in the service.
        age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
      }
    ]
    ++ (with self.modules.homeManager; [
      git
      jujutsu
      shell
      tools
    ]);

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
