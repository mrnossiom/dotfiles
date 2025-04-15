{ config
, lib
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

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "where-is-my-sddm-theme";
    };

    environment.systemPackages = [ lpkgs.where-is-my-sddm-theme ];
  };
}

