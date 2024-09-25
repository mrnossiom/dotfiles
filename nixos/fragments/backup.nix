{ config
, lib
, pkgs
, ...
}:

let
  inherit (config.age) secrets;

  cfg = config.local.fragment.backup;

  hostname = config.networking.hostName;
  mainUsername = config.local.user.username;
in
{
  options.local.fragment.backup.enable = lib.mkEnableOption ''
    Backup related
  '';

  config.services.restic.backups = lib.mkIf cfg.enable {
    # Backup documents and repos code
    google-drive = {
      repository = "rclone:googledrive:/Backups/${hostname}";
      initialize = true;
      passwordFile = secrets.backup-restic-key.path;
      rcloneConfigFile = secrets.backup-rclone-googledrive.path;

      paths = [
        "/home/${mainUsername}/Documents"
        # Equivalent of `~/Development` but needs extra handling as explained below
        "/home/${mainUsername}/.local/backup/repos"
      ];

      # Extra handling for Development folder to respect `.gitignore` files.
      #
      # Backup folder should be stored somewhere to avoid changing ctimes
      # which would cause otherwise unchanged files to be backed up again.
      # Since `--link-dest` is used, file contents won't be duplicated on disk.
      backupPrepareCommand = ''
        # Remove stale Restic locks
        ${lib.getExe pkgs.restic} unlock || true

        ${lib.getExe pkgs.rsync} \
          ${"\\" /* Archive mode and delete files that are not in the source directory. `--mkpath` is like `mkdir`'s `-p` option */}
          --archive --delete --mkpath \
          ${"\\" /* `:-` operator uses .gitignore files as exclude patterns */}
          --filter=':- .gitignore' \
          ${"\\" /* Exclude nixpkgs repository because they have some weird symlink test files that break rsync */}
          --exclude 'nixpkgs' \
          ${"\\" /* Hardlink files to avoid taking up more space */}
          --link-dest=/home/${mainUsername}/Development \
          /home/${mainUsername}/Development/ /home/${mainUsername}/.local/backup/repos
      '';

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-yearly 10"
      ];


      # TODO: fix config
      timerConfig = null;
      # timerConfig = {
      #   OnCalendar = "00:05";
      #   RandomizedDelaySec = "5h";
      # };
    };

    # Backup documents and large files
    archaic-bak = {
      initialize = true;
      passwordFile = secrets.backup-restic-key.path;
      paths = [ "/home/${mainUsername}/Documents" ];
      repository = "/run/media/${mainUsername}/ArchaicBak/Backups/${hostname}";

      # Should only be ran manually when the backup Disk is attached
      timerConfig = null;
    };
  };
}
