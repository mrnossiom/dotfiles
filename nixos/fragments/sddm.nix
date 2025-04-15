{ config
, lib
, pkgs
, lpkgs
, ...
}:

let
  cfg = config.local.fragment.sddm;
in

{
  options.local.fragment.sddm.enable = lib.mkEnableOption ''
    SDDM related
  '';

  # Hours wasted trying to add a working SDDM theme: 3h + 3h

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      # theme = "where_is_my_sddm_theme";
      theme = "catppuccin-mocha";
    };

    environment.systemPackages = [
      lpkgs.where-is-my-sddm-theme
      pkgs.catppuccin-sddm
    ];
  };
}

