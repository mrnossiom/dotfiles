{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:

{
  # Hardware is imported in the flake to be machine specific
  imports = [
    ../modules/backup.nix

    inputs.disko.nixosModules.disko

    inputs.agenix.nixosModules.default
    ../../secrets
    { age.identityPaths = [ "/home/${config.users.main.username}/.ssh/id_ed25519" ]; }
  ];


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


  services.udev.packages = with pkgs; [ numworks-udev-rules ];

  services.devmon.enable = true;

  # security.sudo-rs.enable = true;


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

