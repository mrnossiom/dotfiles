{ inputs, ... }: rec {
  all = [ local-lib additions patches unstable-packages ];

  # Bring our local lib
  local-lib = final: prev: { lib = { local = import ../lib final; } // prev.lib; };

  # Bring our custom packages from the `pkgs` directory
  additions = final: _prev: import ../pkgs final;

  patches = import ./patches.nix;

  # Makes the unstable nixpkgs set accessible through `pkgs.unstable`
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
