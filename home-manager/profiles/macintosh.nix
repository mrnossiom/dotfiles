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
  inherit (self.inputs) agenix nix-colors;

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

    # Nix colors
    nix-colors.homeManagerModules.default
    { config.colorScheme = llib.colorSchemes.oneDark; }
  ];

  config = {
    local.fragment.aws.enable = true;
    local.fragment.git.enable = true;
    local.fragment.shell.enable = true;
    # local.fragment.tools.enable = true;
    # # local.fragment.vscodium.enable = true;

    programs.home-manager.enable = osConfig == null;

    home = {
      stateVersion = "24.05";

      homeDirectory = "/Users/milomoisson";

      packages = with pkgs; [
        just
      ];
    };

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };

    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = "no";
        macos_option_as_alt = "left";
      } // lib.optionalAttrs isDarwin {
        # Workaround to avoid launching fish as a login shell
        shell = "zsh -c fish";
      };
    };

    programs.gpg = {
      enable = true;
      homedir = "${config.xdg.dataHome}/gnupg";
    };
  };
}
