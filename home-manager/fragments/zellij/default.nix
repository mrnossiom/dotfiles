{ ... }:

# Don't use settings, nix and KDL is much unfit: https://github.com/NixOS/nixpkgs/issues/198655#issuecomment-1453525659
{
  config = {
    programs.zellij = {
      enable = true;

      # TODO: modify HM module to define layouts in here directly
    };

    xdg.configFile."zellij/config.kdl".source = ./config.kdl;
  };
}
