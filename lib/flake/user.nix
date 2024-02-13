name: { description, profile, user ? { } }:

{ self, pkgs, lib, ... }:

with lib;

let
  inherit (self.inputs) home-manager;
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

      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      openssh.authorizedKeys.keys = [ ];
    } // user;

    home-manager = {
      extraSpecialArgs = self.flakeLib.specialModuleArgs pkgs;

      useUserPackages = false;
      useGlobalPkgs = true;

      users.${name} = import ../../home-manager/profiles/${profile}.nix;
    };
  };
}
