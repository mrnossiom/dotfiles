{
  pkgs,
  lib,

  isDarwin,
  ...
}:

let
  keys = import ../../secrets/keys.nix;
in
{
  config = {
    assertions = [
      {
        assertion = !isDarwin;
        message = "this is a HM non-darwin config";
      }
    ];

    local.flags.onlyCached = true;

    local.fragment = {
      # agenix.enable = true;
      git.enable = true;
      helix.enable = true;
      jujutsu.enable = true;
      shell.enable = true;
      # tools.enable = true;
      zellij.enable = true;
    };

    programs.jujutsu.settings.signing.key = lib.mkForce keys.epita;

    home.packages = with pkgs; [
      # GUIs
      pavucontrol

      # CLIs
      wf-recorder
      wl-clipboard
      xdg-utils
    ];

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };

    fonts.fontconfig.defaultFonts = {
      monospace = "JetBrainsMono Nerd Font";
    };
  };
}
