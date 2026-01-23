{
  self,
  config,
  lib,
  pkgs,

  isDarwin,
  ...
}:

let
  clear-nix-env = false;

  cfg = config.local.fragment.nix;
in

{
  options.local.fragment.nix.enable = lib.mkEnableOption ''
    Nix related
  '';

  config = lib.mkIf cfg.enable {
    nix = {
      package = pkgs.lixPackageSets.stable.lix;

      # Make system registry consistent with flake inputs
      # Add `self` registry input that refers to flake
      registry = lib.mapAttrs (_: value: { flake = value; }) (self.inputs // { inherit self; });

      nixPath =
        if
          clear-nix-env
        # Actually make it empty to disable nix-* legacy commands
        then
          [ ]
        # Make NixOS system's legacy channels consistent with registry and flake inputs
        else
          lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      gc = {
        automatic = true;
        # absolute disk space saver, if you forget to run GC
        # once had it over 170gb and brought it back to 50gb
        options = "--delete-older-than 30d";
      }
      # Same option to say that GC is ran weekly at 3h15
      // (
        if isDarwin then
          {
            interval = {
              Weekday = 7;
              Hour = 3;
              Minute = 15;
            };
          }
        else
          {
            dates = "Sun *-*-* 03:15:00";
          }
      );

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        auto-optimise-store = true;

        # Disable flake registry to keep system pure and
        # avoid network calls at each nix invoation.
        flake-registry = "";

        use-xdg-base-directories = true;

        keep-going = true;

        extra-platforms = config.boot.binfmt.emulatedSystems;

        trusted-users = [ config.local.user.username ];
        extra-substituters = [ "https://nix-community.cachix.org" ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };

    # other disk space saver
    services.angrr = {
      enable = true;
      period = "2weeks";
      enableNixGcIntegration = true;
    };
  };
}
