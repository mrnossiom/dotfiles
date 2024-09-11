{ lib
, config
, isDarwin
, ...
}:

let
  cfg = config.local.fragment.kitty;
in
{
  options.local.fragment.kitty.enable = lib.mkEnableOption ''
    Kitty related

    Depends on: `fish`
  '';

  config = lib.mkIf cfg.enable {
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


