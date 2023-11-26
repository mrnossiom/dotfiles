{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:

let

  hostname = "archaic-wiro-laptop";
  main-user = "milomoisson";

in
{
  # Hardware is imported in the flake to be machine specific

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    gc = {
      automatic = true;
      dates = "weekly";
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
  };

  nixpkgs = {
    overlays = with outputs.overlays; [ additions modifications unstable-packages ];
    config.allowUnfree = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  security.pam.services.swaylock.text = "auth include login";
  programs.dconf.enable = true;

  services.blueman.enable = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" "9.9.9.9" ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  fonts = {
    fonts = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) inter noto-fonts noto-fonts-emoji font-awesome ];
    fontconfig = {
      # Set `Noto Sans` as fallback font
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans" ];
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Inter" "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.fish.enable = true;

  users.users.milomoisson = {
    isNormalUser = true;
    description = "Milo Moisson";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
    packages = with pkgs; [ ];

    openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
    ];
  };

  services.udev.packages = with pkgs; [ numworks-udev-rules ];

  services.devmon.enable = true;

  # security.sudo-rs.enable = true;

  services.restic.backups = {
    # Backup documents and repos code
    google-drive = {
      repository = "rclone:googledrive:/Backups/${hostname}";
      initialize = true;
      passwordFile = config.age.secrets.restic-backup-pass.path;
      rcloneConfigFile = config.age.secrets.googledrive-rclone-config.path;

      paths = [
        "/home/${main-user}/Documents"
        # Equivalent of `~/Developement` but needs extra handling as explained below
        "/home/${main-user}/.local/backup/repos"
      ];

      # Extra handling for Developement folder to respect `.gitignore` files.
      #
      # Backup folder sould be stored somewhere to avoid changing ctimes
      # which would cause otherwise unchanged files to be backed up again.
      # Since `--link-dest` is used, file contents won't be duplicated on disk.
      backupPrepareCommand = ''
        # Remove stale Restic locks
        ${pkgs.restic}/bin/restic unlock || true

        ${pkgs.rsync}/bin/rsync \
          ${"\\" /* Archive mode and delete files that are not in the source directory. `--mkpath` is like `mkdir`'s `-p` option */}
          --archive --delete --mkpath \
          ${"\\" /* `:-` operator uses .gitignore files as exclude patterns */}
          --filter=':- .gitignore' \
          ${"\\" /* Exclude nixpkgs repository because they have some weird symlink test files that break rsync */}
          --exclude 'nixpkgs' \
          ${"\\" /* Hardlink files to avoid taking up more space */}
          --link-dest=/home/${main-user}/Developement \
          /home/${main-user}/Developement/ /home/${main-user}/.local/backup/repos
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
      passwordFile = config.age.secrets.restic-backup-pass.path;
      paths = [ "/home/${main-user}/Documents" ];
      repository = "/mnt/${main-user}/ArchaicBak/Backups/${hostname}";
    };
  };

  security.polkit.enable = true;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # TODO: see if it works on neo laptop
  services.fprintd.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # TODO: should not be here
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  services.upower.enable = true;

  services.logind = {
    lidSwitch = "lock";
    lidSwitchDocked = "suspend";
    lidSwitchExternalPower = "lock";
    extraConfig = lib.generators.toKeyValue { } {
      IdleAction = "lock";
      # Don’t shutdown when power button is short-pressed
      HandlePowerKey = "lock";
      HandlePowerKeyLongPress = "suspend";
    };
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  hardware.bluetooth.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}

