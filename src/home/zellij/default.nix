{
  flake.modules.homeManager.zellij = { upkgs, ... }: {
    config = {
      # Don't use settings, nix and KDL is much unfit
      # See https://github.com/NixOS/nixpkgs/issues/198655#issuecomment-1453525659
      programs.zellij = {
        enable = true;
        package = upkgs.zellij;
      };

      xdg.configFile."zellij/config.kdl".source = ./config.kdl;
    };
  };
}
