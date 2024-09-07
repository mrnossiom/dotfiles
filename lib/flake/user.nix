name: { description, profile, keys ? [ ], user ? { } }:

{ self
, pkgs
, lib
, isDarwin
, ...
}:

with lib;

let
  inherit (self.inputs) home-manager;
  inherit (self.flake-lib) specialModuleArgs;
in
{
  imports = [
    (if isDarwin then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager)
  ];

  options = {
    local.user.username = mkOption {
      type = types.str;
      description = "The name of the main user account";
    };
  };

  config = {
    local.user.username = name;

    users.users.${name} = {
      inherit description;
      shell = pkgs.fish;

      openssh.authorizedKeys.keys = keys;
    } // (if isDarwin then {
      home = "/Users/${name}";
    } else {
      home = "/home/${name}";
      extraGroups = [ "wheel" "networkmanager" ];
      isNormalUser = true;
    }) // user;

    home-manager = {
      extraSpecialArgs = specialModuleArgs pkgs;

      useUserPackages = false;
      useGlobalPkgs = true;

      users.${name} = { ... }: {
        imports = [
          ../../home-manager/profiles/${profile}.nix
          ../../home-manager/fragments/default.nix
          ../../home-manager/options.nix
        ];
      };
    };
  };
}
