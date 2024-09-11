{ lib
, config
, ...
}:

let
  cfg = config.local.fragment.zellij;
in
{
  options.local.fragment.zellij.enable = lib.mkEnableOption ''
    Zellij related
  '';

  config = lib.mkIf cfg.enable {
    # Don't use settings, nix and KDL is much unfit
    # See https://github.com/NixOS/nixpkgs/issues/198655#issuecomment-1453525659
    programs.zellij = {
      enable = true;
    };

    xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  };
}
