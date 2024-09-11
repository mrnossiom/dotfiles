{ self
, lib
, llib
, config
, pkgs
, isDarwin
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:

if (!isDarwin) then throw "this is a HM darwin-only config" else

let
  inherit (self.outputs) homeManagerModules;
  inherit (self.inputs) agenix;

  all-secrets = import ../../secrets;
in
{
  imports = [
    agenix.homeManagerModules.default
    {
      age.secrets = all-secrets.home-manager;
      # This allows us to decrypt user space secrets without having to use a
      # passwordless ssh key as you cannot interact with age in the service.
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
    }

    homeManagerModules.color-scheme
    { config.local.colorScheme = llib.colorSchemes.oneDark; }
  ];

  config = {
    local.fragment = {
      aws.enable = true;
      git.enable = true;
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
