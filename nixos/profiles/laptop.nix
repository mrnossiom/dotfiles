{ self
, lib
, config
, pkgs
, upkgs
, ...
}:

with lib;

let
  inherit (self.outputs) nixosModules;
in
{
  # Hardware is imported in the flake to be machine specific
  imports = [
    # Replaces nixpkgs module with a custom one that support fallback static location
    nixosModules.geoclue2
  ] ++ map (modPath: ../modules/${modPath}) [
    "agenix.nix"
    "backup.nix"
    "gaming.nix"
    "info.nix"
    "logiops.nix"
    "nix.nix"
    "security.nix"
    "virtualisation.nix"
    "wireless.nix"
  ];

  networking.hosts = {
    "127.0.0.1" = [ "www.youtube.com" ];
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  boot = {
    kernelParams = [ "quiet" ];

    kernelPackages = upkgs.linuxKernel.packages.linux_zen;
    extraModulePackages = with config.boot.kernelPackages; [ apfs perf xone ];

    loader = {
      systemd-boot.enable = true;
      systemd-boot.consoleMode = "auto";
      efi.canTouchEfiVariables = true;
    };

    # This is needed to build cross platform ISOs in `apps/flash-installer.nix`
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Once in a while, the session stop job hangs and lasts the full default
  # time (1min30). I just want to shutdown my computer please.
  systemd.extraConfig = ''
    DefaultTimeoutStopSec = 10s
  '';

  programs.dconf.enable = true;

  time.timeZone = "Europe/Paris";

  services.ntpd-rs.enable = true;

  i18n =
    let
      english-locale = "en_US.UTF-8";
      french-locale = "fr_FR.UTF-8";
    in
    {
      defaultLocale = english-locale;
      extraLocaleSettings = {
        LC_ADDRESS = french-locale;
        LC_IDENTIFICATION = french-locale;
        LC_MEASUREMENT = french-locale;
        LC_MONETARY = french-locale;
        LC_NAME = french-locale;
        LC_NUMERIC = french-locale;
        LC_PAPER = french-locale;
        LC_TELEPHONE = french-locale;
        LC_TIME = french-locale;
      };
    };

  programs.command-not-found.enable = false;

  # This is needed for services like `darkman` and `gammastep`
  services.geoclue2 = {
    enable = true;

    # Fallback using custom geoclue2 module waitng for an alternative to MLS
    # (Mozilla Location Services). See related module in repo.
    # INFO:   lat vvvv  vvv long → Paris rough location
    staticFile = "48.8\n2.3\n0\n0\n";
  };

  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      font-awesome
    ];
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
  users.users.${config.local.user.username}.extraGroups = [ "wireshark" "plugdev" ];

  # This option is already filled with aliases that snowball and have 
  # priority on fish internal `ls` aliases
  environment.shellAliases = { ls = null; ll = null; l = null; };
  programs.fish.enable = true;

  services.udev.packages = with pkgs; [
    arduino-udev-rules
    numworks-udev-rules
    probe-rs-udev-rules
  ];

  users.groups.plugdev.name = "plugdev";

  services.devmon.enable = true;

  services.gvfs.enable = true;

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
