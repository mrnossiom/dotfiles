{ ... }:

{
  perSystem = { pkgs, inputs', ... }: {
    packages = {
      ebnfer = pkgs.callPackage ./_packages/ebnfer.nix { };
      find-unicode = pkgs.callPackage ./_packages/find-unicode.nix { };
      names = pkgs.callPackage ./_packages/names.nix { };
      probe-rs-udev-rules = pkgs.callPackage ./_packages/probe-rs-udev-rules.nix { };
      swaylock = pkgs.callPackage ./_packages/swaylock.nix { };
      swic = pkgs.callPackage ./_packages/swic.nix { };

      # Import packages defined in foreign repositories
      inherit (inputs'.agenix.packages) agenix;
      inherit (inputs'.git-leave.packages) git-leave;
      inherit (inputs'.git-pages.packages) git-pages;
      inherit (inputs'.helix.packages) helix;
      inherit (inputs'.nix-alien.packages) nix-alien;
    };
  };
}
