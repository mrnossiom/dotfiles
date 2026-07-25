{
  config,
  pkgs,

  isDarwin,
  ...
}:

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
      agenix.enable = true;
      git.enable = true;
      helix.enable = true;
      jujutsu.enable = true;
      shell.enable = true;
      # tools.enable = true;
      zellij.enable = true;
    };

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
