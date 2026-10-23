{
  flake.modules.homeManager.zed = { lib, upkgs, ... }: {
    config = {
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
  };
}
