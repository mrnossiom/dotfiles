{ self
, config
, lib
, upkgs
, ...
}:

# https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md

let
  inherit (self.inputs) lanzaboote;

  cfg = config.local.fragment.secure-boot;
in
{
  imports = [
    lanzaboote.nixosModules.lanzaboote
  ];

  options.local.fragment.secure-boot.enable = lib.mkEnableOption ''
    Secure boot related
  '';

  config = lib.mkIf cfg.enable {
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    boot.initrd.systemd.enable = true;

    environment.systemPackages = [
      # For debugging and troubleshooting Secure Boot
      upkgs.sbctl
    ];
  };
}


