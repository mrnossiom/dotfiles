{ self
, lib
, pkgs
, lpkgs

, modulesPath
, ...
}:

let
  inherit (self.inputs) nixos-hardware;

  keys = import ../../secrets/keys.nix;

  binName = drv: drv.meta.mainProgram;

  flakeUri = "github:mrnossiom/dotfiles";

  ## Formatting related

  # Does the whole destroy, format, mount disko cycle
  # disko-cycle <hostname>
  disko-cycle = pkgs.writeShellScriptBin "disko-cycle" ''
    if [ -z "$1" ]; then echo "Hostname unset"; exit; fi

    echo "Running disko destroy, format and mount script for $1"
    nix build ${flakeUri}#nixosConfigurations.$1.config.system.build.diskoScript
    sudo bash result
  '';

  ## NixOS install related

  # Generates hardware related config and uploads it to a paste service
  # link-hardware-config [root]
  link-hardware-config = pkgs.writeShellScriptBin "link-hardware-config" ''
    nixos-generate-config --root ''${1:-/mnt} --show-hardware-config | ${lib.getExe lpkgs.paste-rs}
  '';

  # Install specified flake system to /mnt
  # install-system <hostname>
  install-system = pkgs.writeShellScriptBin "install-system" ''
    if [ -z "$1" ]; then echo "Hostname unset"; exit; fi

    echo "Installing $1"
    nixos-install --system ${flakeUri}#$1
  '';
in
{
  imports = [
    nixos-hardware.nixosModules.raspberry-pi-4
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
  ];

  config = {
    sdImage.compressImage = false;

    boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      extra-substituters = [
        "https://nix-community.cachix.org"
        "https://mrnossiom.cachix.org"
      ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mrnossiom.cachix.org-1:WKo+xfDFaT6pRP4YiIFsEXvyBzI/Pm9uGhURgF1wlQg="
      ];
    };

    users.users.nixos = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      # Add our keys to default users for better remote experience
      openssh.authorizedKeys.keys = keys.users;
    };

    # Start wpa_supplicant right away
    systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];

    services.getty.helpLine = ''
      Available custom tools:
      - File System: ${binName disko-cycle}
      - Installation: ${binName link-hardware-config}, ${binName install-system}

      Troubleshoot:
      - If the disko installer fails to finish due to a dark error just wipe the disk table
        $ parted /dev/<disk-id> -- mklabel gpt
    '';

    environment.systemPackages = [
      disko-cycle
      link-hardware-config
      install-system
    ];

    services.openssh.enable = true;

    security.sudo.wheelNeedsPassword = false;
  };
}
