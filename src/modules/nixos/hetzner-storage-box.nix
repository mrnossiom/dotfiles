{
  flake.nixosModules.hetzner-storage-box =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.hetzner.storageBoxes;
      enabledBoxes = lib.filterAttrs (name: box: box.enable) cfg;
      hasCifs = lib.any (box: box.protocol == "cifs") (lib.attrValues enabledBoxes);
    in
    {
      options.services.hetzner.storageBoxes = lib.mkOption {
        description = "Declarative configuration for multiple Hetzner Storage Boxes.";
        default = { };
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, config, ... }: {
              options = {
                enable = lib.mkEnableOption "this Hetzner Storage Box mount";

                username = lib.mkOption {
                  type = lib.types.str;
                  example = "u123456";
                  description = "The main username or sub-account username of the Storage Box.";
                };

                credentialsFile = lib.mkOption {
                  type = lib.types.path;
                  description = ''
                    Path to the credentials file.
                    The file must contain:
                      username=uXXXXXX
                      password=your-password
                  '';
                };

                owner = lib.mkOption {
                  type = lib.types.str;
                };

                group = lib.mkOption {
                  type = lib.types.str;
                  default = config.owner;
                };

                mountPoint = lib.mkOption {
                  type = lib.types.str;
                  default = "/mnt/storagebox-${name}";
                  description = "Absolute path to the local mount point.";
                };

                share = lib.mkOption {
                  type = lib.types.str;
                  default = config.username;
                  description = ''
                    The share name. For main accounts, this is usually "backup".
                    For sub-accounts, it is typically the sub-account username itself.
                  '';
                };

                protocol = lib.mkOption {
                  type = lib.types.enum [ "cifs" ];
                  default = "cifs";
                  description = "Protocol to use (CIFS/SMB is recommended for Linux performance).";
                };

                extraMountOptions = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [ ];
                  description = "Extra mount options passed to the file system.";
                };
              };
            }
          )
        );
      };

      config = lib.mkIf (enabledBoxes != { }) {
        environment.systemPackages = lib.optional hasCifs pkgs.cifs-utils;

        fileSystems = lib.mapAttrs' (
          name: box:
          let
            host = "${box.username}.your-storagebox.de";
            device = "//${host}/${box.share}";
            allOptions = [
              "credentials=${box.credentialsFile}"
              "nofail" # prevent boot stalls if the storage box is unreachable
              "_netdev" # wait for network stack to be online before mounting
              "seal" # encrypt smb connection (recommended by hetzner)
              "uid=${box.owner}"
              "gid=${box.group}"
              "file_mode=0660"
              "dir_mode=0770"
              "x-systemd.automount"
              "x-systemd.mount-timeout=30s"
            ]
            ++ box.extraMountOptions;
          in
          lib.nameValuePair box.mountPoint {
            inherit device;
            fsType = box.protocol;
            options = allOptions;
          }
        ) enabledBoxes;
      };
    };
}
