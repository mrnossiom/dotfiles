{ lib, config, inputs, outputs, modulesPath, pkgs, ... }:

with lib;

let
  disko = pkgs.writeShellScriptBin "disko" ''${config.system.build.diskoScript}'';
  diskoFormat = pkgs.writeShellScriptBin "disko-format" "${config.system.build.formatScript}";
  diskoMount = pkgs.writeShellScriptBin "disko-mount" "${config.system.build.mountScript}";

  system = outputs.nixosConfigurations.archaic-wiro-laptop.config.system.build.toplevel;

  installSystem = pkgs.writeShellApplication {
    name = "install-system";
    runtimeInputs = [ diskoFormat diskoMount ];

    text = ''
      echo "Formatting disks..."
      disko-format

      echo "Mounting disks..."
      disko-mount

      echo "Installing system..."
      nixos-install --system ${system}

      echo "Done!"
    '';
  };

in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix"

    inputs.disko.nixosModules.disko
    ../layout/luks-btrfs.nix
  ];

  config = {
    # Default compression is never-ending, this gets done in a minute with better results
    isoImage.squashfsCompression = "zstd -Xcompression-level 10";

    # Disable annoying warning
    boot.swraid.enable = lib.mkForce false;

    # we don't want to generate filesystem entries on this image
    disko.enableConfig = lib.mkDefault false;

    services.getty.helpLine = ''
      You can use `${installSystem.meta.mainProgram}` to format and mount disks.
      It then installs the selected system : ${"<system>"}.
    '';

    environment.systemPackages = [ disko diskoFormat diskoMount installSystem ];
  };
}
