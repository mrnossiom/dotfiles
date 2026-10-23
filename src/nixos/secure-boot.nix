{
  inputs,
  ...
}:
{
  # https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
  flake.modules.nixos.secure-boot = { lib, upkgs, ... }: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];

    config = {
      boot.loader.systemd-boot.enable = lib.mkForce false;

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";

        autoEnrollKeys.enable = true;
      };

      boot.initrd.systemd.enable = true;

      environment.systemPackages = [
        # For debugging and troubleshooting Secure Boot
        upkgs.sbctl
      ];
    };
  };
}
