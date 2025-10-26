{ self
, config
, pkgs

, isDarwin
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

let
  inherit (self.inputs) agenix;
in
{
  imports = [
    agenix.homeManagerModules.default
    {
      # This allows us to decrypt user space secrets without having to use a
      # passwordless ssh key as you cannot interact with age in the service.
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
    }
  ];

  config = {
    assertions = [
      { assertion = isDarwin; message = "this is a HM darwin-only config"; }
    ];

    local.fragment = {
      aws.enable = true;
      git.enable = true;
      jujutsu.enable = true;
      shell.enable = true;
      tools.enable = true;
      # vscodium.enable = true;
    };

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
}
