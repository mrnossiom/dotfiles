name: { description, profile, keys ? [ ], user ? { } }:

{ self, pkgs, lib, ... }:

with lib;

let
  inherit (self.inputs) home-manager;
  inherit (self.flake-lib) specialModuleArgs;
in
{
  imports = [ home-manager.nixosModules.home-manager ];

  options = {
    local.user.username = mkOption {
      type = types.str;
      description = "The name of the main user account";
    };
  };

  config = {
    local.user.username = name;

    users.users.${name} = {
      isNormalUser = true;
      inherit description;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.fish;

      openssh.authorizedKeys.keys = keys;
    } // user;

    home-manager = {
      extraSpecialArgs = specialModuleArgs pkgs;

      useUserPackages = false;
      useGlobalPkgs = true;

      users.${name} = import ../../home-manager/profiles/${profile}.nix;
    };
  };
}
