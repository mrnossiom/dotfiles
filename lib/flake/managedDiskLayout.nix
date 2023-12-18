device: layout:

{ inputs, outputs, pkgs, lib, ... }:

with lib;

let

  inherit (inputs) disko;

in
{
  imports = [ disko.nixosModules.disko layout ];

  options = {
    local.disk.device = mkOption {
      type = types.str;
      default = "/dev/${device}";
      description = "The identifier of the disk (/dev/<device>)";
    };
  };

  config = { };
}
