name: { description, config, user ? { } }:

{ inputs, outputs, pkgs, lib, ... }:

with lib;

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

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
      extraSpecialArgs = { inherit inputs outputs; };
      backupFileExtension = "bak";

      useUserPackages = true;
      useGlobalPkgs = false;

      users.${name} = import config;
    };
  };
}
