system:
{ lib, config, inputs, outputs, modulesPath, pkgs, ... }:

with lib;

let
  inherit (inputs) disko;
  inherit (pkgs) writeShellScriptBin writeShellApplication;

  # If the disk layout is managed, add disko bin and commands to install script
  diskLayoutIsManaged = system.config.local.disk.id;

  diskoCli = writeShellScriptBin "disko" ''${system.config.system.build.diskoScript}'';
  diskoFormat = writeShellScriptBin "disko-format" "${system.config.system.build.formatScript}";
  diskoMount = writeShellScriptBin "disko-mount" "${system.config.system.build.mountScript}";

  installSystem = writeShellApplication {
    name = "install-system";
    runtimeInputs = [ diskoFormat diskoMount ];

    text = ''
      echo "Wiping initial disk table..."
      parted /dev/${system.config.local.disk.id} -- mklabel gpt

      echo "Formatting disks..."
      disko-format

      echo "Mounting disks..."
      disko-mount

      echo "Installing system..."
      nixos-install --system ${system.config.system.build.toplevel}

      echo "Done!"
    '';
  };

in
{
  imports = [ "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel.nix" ];

  config = {
    # Default compression is never-ending, this gets done in a minute with better results
    isoImage.squashfsCompression = "zstd -Xcompression-level 10";

    # Disable annoying warning
    boot.swraid.enable = mkForce false;

    services.getty.helpLine = ''
      You can use `${installSystem.meta.mainProgram}` to format and mount disks.
      It then installs the selected system : ${"<system>"}.
    '';

    environment.systemPackages = [ diskoCli diskoFormat diskoMount installSystem ];
  };
}
