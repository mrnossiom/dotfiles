layout: { device, swapSize }:

{ self, pkgs, lib, ... }:

with lib;

let
  inherit (self.inputs) disko;
in
{
  imports = [
    disko.nixosModules.disko
    ../../nixos/layout/${layout}.nix
  ];

  options.local.disk = {
    device = mkOption {
      type = types.str;
      default = "/dev/${device}";
      description = "Identifier of the disk (/dev/<device>)";
    };

    swapSize = mkOption {
      type = types.int;
      default = swapSize;
      description = ''
        Size (in GB) of the swap file

        The recommended amount from RedHat is:

        Amount of RAM    Recommended swap space       Recommended swap space 
        in the system                                 if allowing for hibernation
        ——————————————   ——————————————————————————   ———————————————————————————
        ⩽ 2 GB           2 times the amount of RAM    3 times the amount of RAM
        > 2 GB – 8 GB    Equal to the amount of RAM   2 times the amount of RAM
        > 8 GB – 64 GB   At least 4 GB                1.5 times the amount of RAM
        > 64 GB          At least 4 GB                Hibernation not recommended
      '';
    };
  };
}
