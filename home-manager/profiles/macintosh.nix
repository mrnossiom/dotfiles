{ self
, lib
, llib
, config
, pkgs
, upkgs
, isDarwin
  # Provides the NixOS configuration if HM was loaded through the NixOS module
, osConfig ? null
, ...
}:


with lib;

let
  _check = if (!isDarwin) then throw "this is a HM darwin-only config" else null;

  inherit (self.inputs) agenix nix-colors;

  all-secrets = import ../../secrets;

  toml-format = pkgs.formats.toml { };
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
  ] ++ map (modPath: ../modules/${modPath}) [
    "aws.nix"
    # "chromium.nix"
    # "firefox.nix"
    "git.nix"
    # "imv.nix"
    "shell.nix"
    # "thunderbird.nix"
    "tools.nix"
    # "vm"
    # "vscodium.nix"
  ];

  config = {
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
      } // optionalAttrs isDarwin {
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
