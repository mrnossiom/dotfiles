{ lib
, pkgs

, modulesPath
, ...
}:

let
  inherit (pkgs) writeShellScriptBin pastebinit;

  keys = import ../../secrets/keys.nix;

  binName = drv: drv.meta.mainProgram;

  flakeUri = "github:mrnossiom/dotfiles/nixos";

  ## Wireless related

  # connect-wifi <interface> <BSSID>
  connect-wifi = writeShellScriptBin "connect-wifi" ''
    if [ -z "$1" ]; then echo "Interface unset"; exit; fi
    if [ -z "$2" ]; then echo "SSID unset"; exit; fi
    
    CONFIG=$(mktemp)
    wpa_passphrase $2 > $CONFIG 
    sudo wpa_supplicant -B -i$1 -c$CONFIG
  '';

  ## Formatting related

  # Does the whole destroy, format, mount disko cycle
  # disko-cycle <hostname>
  disko-cycle = writeShellScriptBin "disko-cycle" ''
    if [ -z "$1" ]; then echo "Hostname unset"; exit; fi

    echo "Running disko destroy, format and mount script for $1"
    nix build ${flakeUri}#nixosConfigurations.$1.config.system.build.diskoScript
    sudo bash result
  '';

  ## NixOS install related

  # Generates hardware related config and uploads it to pastebin
  # link-hardware-config [root]
  link-hardware-config = writeShellScriptBin "link-hardware-config" ''
    nixos-generate-config --root ''${1:-/mnt} --show-hardware-config | ${lib.getExe' pastebinit "pastebinit"}
  '';

  # Install specified flake system to /mnt
  # install-system <hostname>
  install-system = writeShellScriptBin "install-system" ''
    if [ -z "$1" ]; then echo "Hostname unset"; exit; fi

    echo "Installing $1"
    nixos-install --system ${flakeUri}#$1
  '';

in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix" ];

  config = {
    # Default compression is never-ending, this gets done in a minute with better results
    isoImage.squashfsCompression = "zstd -Xcompression-level 10";

    # Disable annoying warning
    boot.swraid.enable = lib.mkForce false;

    boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_6_6;

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

    # Add our keys to default users for better remote experience
    users.users.nixos.openssh.authorizedKeys.keys = keys.users;

    # Start wpa_supplicant right away
    systemd.services.wpa_supplicant.wantedBy = lib.mkForce [ "multi-user.target" ];

    services.getty.helpLine = ''
      Available custom tools:
      - Networking: ${binName connect-wifi}
      - File System: ${binName disko-cycle}
      - Installation: ${binName link-hardware-config}, ${binName install-system}

      Troubleshoot:
      - If the disko installer fails to finish due to a dark error just wipe the disk table
        $ parted /dev/<disk-id> -- mklabel gpt
    '';

    environment.systemPackages = [
      connect-wifi
      disko-cycle
      link-hardware-config
      install-system
    ];
  };
}
