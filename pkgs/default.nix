{
  self,

  stdenv,
  callPackage,
  ...
}:

let
  inherit (stdenv.hostPlatform) system;

  inherit (self.inputs)
    agenix
    git-leave
    nix-alien
    wakatime-ls
    ;
in
{
  ebnfer = callPackage ./ebnfer.nix { };
  find-unicode = callPackage ./find-unicode.nix { };
  lsr = callPackage ./lsr { };
  names = callPackage ./names.nix { };
  probe-rs-udev-rules = callPackage ./probe-rs-udev-rules.nix { };

  # Import packages defined in foreign repositories
  inherit (agenix.packages.${system}) agenix;
  inherit (git-leave.packages.${system}) git-leave;
  inherit (nix-alien.packages.${system}) nix-alien;
  inherit (wakatime-ls.packages.${system}) wakatime-ls;
}
