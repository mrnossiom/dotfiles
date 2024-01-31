{ self
, lib
, config
, pkgs
, ...
}:

with lib;

{
  # Hardware is imported in the flake to be machine specific
  imports = [
    ../modules/agenix.nix
    ../modules/backup.nix
    ../modules/gaming.nix
    ../modules/info.nix
    ../modules/logiops.nix
    ../modules/nix.nix
    ../modules/security.nix
    ../modules/virtualisation.nix
    ../modules/wireless.nix
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.consoleMode = "auto";
    efi.canTouchEfiVariables = true;
  };

  boot.extraModulePackages = with config.boot.kernelPackages; [ apfs perf xone ];

  programs.dconf.enable = true;

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

  programs.command-not-found.enable = false;

  # This is needed for services like `darkman` and `gammastep`
  services.geoclue2.enable = true;

  fonts = {
    packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) inter noto-fonts noto-fonts-cjk-sans noto-fonts-emoji font-awesome ];
    fontconfig = {
      defaultFonts = rec {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Sans Mono" ];
        sansSerif = [ "Inter" "Noto Sans" "Noto Sans Japanese" "Noto Sans Korean" "Noto Sans Chinese" ];
        # Serif is ugly
        serif = sansSerif;
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
  users.users.${config.local.user.username}.extraGroups = [ "wireshark" ];

  # This option is already filled with aliases that snowball and have 
  # priority on fish internal `ls` aliases
  environment.shellAliases = { ls = null; ll = null; l = null; };
  programs.fish.enable = true;

  services.udev.packages = with pkgs; [ numworks-udev-rules ];

  services.devmon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  services.upower.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;

    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];

    config.common.default = "*";
  };
}
