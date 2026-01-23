{
  lib,
  config,
  upkgs,
  ...
}:

let
  cfg = config.local.fragment.zed;
in
{
  options.local.fragment.zed.enable = lib.mkEnableOption ''
    Zed related
  '';

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = upkgs.zed-editor;

      userSettings = {
        theme = lib.mkForce "Alabaster Dark";

        helix_mode = true;
        disable_ai = true;

        autosave = "on_focus_change";
      };
    };
  };
}
