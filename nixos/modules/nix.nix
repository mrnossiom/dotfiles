{ self
, lib
, config
, ...
}:

with lib;

{
  config = {
    nix = {
      # Make system registry consistent with flake inputs
      # Add `self` registry input that refers to flake
      registry = mapAttrs (_: value: { flake = value; }) (self.inputs // { inherit self; });

      # Make NixOS system's legacy channels consistent with registry and flake inputs
      nixPath = mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      gc = {
        automatic = true;
        dates = "weekly";
      };

      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        auto-optimise-store = true;

        # Disable flake registry to keep system pure and
        # avoid network calls each nix invoation.
        flake-registry = "";

        keep-going = true;

        trusted-users = [ config.local.user.username ];
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://mrnossiom.cachix.org"
          "https://radicle.cachix.org"
        ];
        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "mrnossiom.cachix.org-1:WKo+xfDFaT6pRP4YiIFsEXvyBzI/Pm9uGhURgF1wlQg="
          "radicle.cachix.org-1:x7jrVNzziAP6GAAJF2wvgJBndqRhmh2EylgWr93ofx0="
        ];
      };
    };
  };
}
