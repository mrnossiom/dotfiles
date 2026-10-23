{ self, inputs, ... }:
let
  mkUserModule =
    isDarwin:
    {
      config,
      lib,
      pkgs,
      upkgs,
      ...
    }:
    let
      cfg = config.local.user;
    in
    {
      imports = [
        (
          if isDarwin then
            inputs.home-manager.darwinModules.home-manager
          else
            inputs.home-manager.nixosModules.home-manager
        )
      ];

      options = {
        local.user = {
          username = lib.mkOption { type = lib.types.str; };
          description = lib.mkOption { type = lib.types.str; };
          shell = lib.mkOption { type = lib.types.package; };
          profile = lib.mkOption { type = lib.types.str; };
          keys = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          elevated = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      };

      config = {
        users.users.${cfg.username} = {
          inherit (cfg) description shell;
          openssh.authorizedKeys.keys = cfg.keys;
        }
        // (
          if isDarwin then
            {
              home = "/Users/${cfg.username}";
            }
          else
            {
              home = "/home/${cfg.username}";
              isNormalUser = true;
              extraGroups = [
                "networkmanager"
              ]
              ++ lib.optionals cfg.elevated [
                "wheel" # root access
                "tss" # tpm access
                "dialout" # serial device access
              ];
            }
        );

        home-manager = {
          extraSpecialArgs = {
            inherit pkgs upkgs;
            osConfig = config;
          };

          useUserPackages = false;
          useGlobalPkgs = true;

          users.${cfg.username} = { ... }: {
            imports = [
              self.modules.homeManager.base
              self.modules.homeManager.options
              self.modules.homeManager."profile-${cfg.profile}"
            ];
          };
        };

      };
    };
in
{
  flake.modules.nixos.option-user = mkUserModule false;
  flake.modules.darwin.option-user = mkUserModule true;
}
