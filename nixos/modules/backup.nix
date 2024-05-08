{ lib
, config
, pkgs
, ...
}:

with lib;

let
  inherit (config.age) secrets;

  hostname = config.networking.hostName;
  mainUsername = config.local.user.username;
in
{
  config.services.restic.backups = {
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
        ${getExe pkgs.restic} unlock || true

        ${getExe pkgs.rsync} \
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

      timerConfig = {
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
    };

    # Backup documents and large files
    archaic-bak = {
      initialize = true;
      passwordFile = secrets.backup-restic-key.path;
      paths = [ "/home/${mainUsername}/Documents" ];
      # TODO
      repository = "/mnt/${mainUsername}/ArchaicBak/Backups/${hostname}";
    };
  };
}
