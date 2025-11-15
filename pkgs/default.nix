{ self, system, ... }@pkgs:

let
  inherit (self.inputs)
    agenix
    git-leave
    wakatime-ls
    ;
in
{
  asak = pkgs.callPackage ./asak.nix { };
  ebnfer = pkgs.callPackage ./ebnfer.nix { };
  find-unicode = pkgs.callPackage ./find-unicode.nix { };
  names = pkgs.callPackage ./names.nix { };
  probe-rs-udev-rules = pkgs.callPackage ./probe-rs-udev-rules.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (wakatime-ls.packages.${system}) wakatime-ls;
}
