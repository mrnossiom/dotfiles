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
      ls "$MOUNT_DIR" >/dev/null || mkdir -v "$MOUNT_DIR"
      sshfs -o reconnect "$USERNAME@ssh.cri.epita.fr:$REMOTE_DIR" "$MOUNT_DIR"
    '';
  };
in
{
  options.local.fragment.epita.enable = lib.mkEnableOption ''
    EPITA related
  '';

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      package = pkgs.openssh_gssapi;

      # Needed for sshfs
      enable = true;
      matchBlocks."ssh.cri.epita.fr" = {
        extraOptions = {
          GSSAPIAuthentication = "yes";
          GSSAPIDelegateCredentials = "yes";
        };
      };
    };

    # The forge uses master as its default branch
    programs.git.includes = [{
      condition = "gitdir:~/Development/forge.epita.fr/";
      contents = {
        init.defaultBranch = "master";
      };
    }];

    home.packages = [
      # Useful to connect to EPITA related services
      pkgs.krb5
      mount-epita-afs
    ];
  };
}
