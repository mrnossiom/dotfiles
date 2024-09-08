{ lib
, isDarwin
, ...
}:

{
  imports = [
    ./agenix.nix
    ./backup.nix
    ./fonts.nix
    ./gaming.nix
    ./logiops.nix
    ./nix.nix
    ./security.nix
    ./virtualisation.nix
    ./wireless.nix
  ] ++ lib.optionals isDarwin [
    ./yabai.nix
  ];
}
