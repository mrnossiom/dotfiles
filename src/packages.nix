{
  perSystem = { pkgs, inputs', ... }: {
    packages = {
      ebnfer = pkgs.callPackage ./_packages/ebnfer.nix { };
      find-unicode = pkgs.callPackage ./_packages/find-unicode.nix { };
      names = pkgs.callPackage ./_packages/names.nix { };
      probe-rs-udev-rules = pkgs.callPackage ./_packages/probe-rs-udev-rules.nix { };
      swaylock = pkgs.callPackage ./_packages/swaylock.nix { };
      swic = pkgs.callPackage ./_packages/swic.nix { };
    };
  };
}
