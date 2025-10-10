{ config
, lib

, isDarwin
, ...
}:

let
  cfg = config.local.fragment.kitty;
in
{
  options.local.fragment.kitty.enable = lib.mkEnableOption ''
    Kitty related

    Depends on:
    - (Darwin) `fish` program: launches fish on startup

      Has weird behavior if set as login shell
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = (!isDarwin) || config.programs.fish.enable; message = "`kitty` fragment depends on `fish` program on darwin platforms"; }
    ];

    home.sessionVariables.TERMINAL = lib.getExe config.programs.kitty.package;

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
  };
}


