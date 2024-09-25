{ config
, lib
, pkgs
, ...
}:

let
  cfg = config.local.fragment.epita;

  epita-forge-username = "milo.moisson";

  mount-epita-afs = pkgs.writeShellApplication {
    name = "mount-epita-afs";
    runtimeInputs = with pkgs; [ krb5 sshfs ];
    text = ''
      USERNAME="${epita-forge-username}"

      REMOTE_DIR="/afs/cri.epita.fr/user/''${USERNAME:0:1}/''${USERNAME:0:2}/$USERNAME/u/"
      MOUNT_DIR="$XDG_RUNTIME_DIR/afs-epita"

      klist || kinit -f "$USERNAME@CRI.EPITA.FR"
      ls "$MOUNT_DIR" || mkdir "$MOUNT_DIR"
      sshfs -o reconnect "$USERNAME@ssh.cri.epita.fr:$REMOTE_DIR" "$MOUNT_DIR"
    '';
  };
in
{
  options.local.fragment.epita.enable = lib.mkEnableOption ''
    EPITA related

    Depends on: SSH
  '';

  config = lib.mkIf cfg.enable {
    # Needed for sshfs
    programs.ssh = {
      # TODO: should depends on ssh module, may conflict later
      enable = true;

      matchBlocks."ssh.cri.epita.fr" = {
        extraOptions = {
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
        };
      };
    };

    home.packages = [
      # Useful to connect to EPITA related services
      pkgs.krb5
      mount-epita-afs
    ];
  };
}
