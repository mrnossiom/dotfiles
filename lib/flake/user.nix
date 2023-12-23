name: { description, config, user ? { } }:

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
      description = "The name of the user account.";
    };
  };

  config = {
    local.user.username = name;

    users.users.${name} = {
      isNormalUser = true;
      inherit description;
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.fish;

      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      openssh.authorizedKeys.keys = [ ];
    } // user;

    home-manager = {
      extraSpecialArgs = { inherit self; };
      backupFileExtension = "bak";

      useUserPackages = false;
      useGlobalPkgs = false;

      users.${name} = import config;
    };
  };
}
