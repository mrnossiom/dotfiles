{ inputs
, outputs
, lib
, config
, pkgs
, ...
}: {
  imports = [
    (inputs.home-manager-unstable + /modules/services/darkman.nix)

    ./vm.nix
    ./git.nix
    ./shell.nix
  ];

  nixpkgs = {
    overlays = with outputs.overlays; [
      additions
      modifications
      unstable-packages
    ];
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "authy"
        "discord"
        "spotify"
        "vscode"
        "thorium-browser"
        "unrar"
      ];
    };
  };

  programs.home-manager.enable = true;

  home = {
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "23.05";
    username = "milomoisson";
    homeDirectory = "/home/milomoisson";

    sessionVariables = {
      EDITOR = "${pkgs.helix}/bin/hx";
    };

    packages = with pkgs; [
      # Unfree packages
      authy
      discord
      spotify
      thorium

      spotify-tui

      cinnamon.nemo
      firefox
      # Firefox needs speedd for voice synthesis web api
      speechd
      transmission

      xdg-utils
      rustup

      # For VSCode nix ext, find workaround for this not to be in path
      rnix-lsp

      # Cli tools
      bat
      fd
      delta
      ripgrep

      imv
      mpv
      wl-clipboard
      wf-recorder
    ];
  };

  xdg.mimeApps = {
    enable = true;
    associations.added = {
      "application/pdf" = [ "firefox.desktop" ];
    };
    defaultApplications = {
      "application/pdf" = [ "firefox.desktop" ];
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.qutebrowser.enable = true;

  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;

      # foreground = "#${config.colorScheme.colors.base05}";
      # background = "#${config.colorScheme.colors.base00}";
    };
  };

  programs.vscode = {
    enable = true;
    # package = pkgs.unstable.vscode;
  };

  # TODO: configure
  services.spotifyd.enable = true;

  programs.gpg = {
    enable = true;

  };


  programs.topgrade = {
    enable = true;
    package = pkgs.unstable.topgrade;
    settings = {
      misc = {
        # Don't ask for confirmations
        assume_yes = true;

        # Run `sudo -v` to cache credentials at the start of the run; this avoids a
        # blocking password prompt in the middle of a possibly-unattended run.
        pre_sudo = true;

        skip_notify = true;
        disable = [ "rustup" ];
        no_retry = true;
        cleanup = true;
      };

      # TODO: sepcify via global config 
      git.repos = [ "~/Documents/Developement/*/*" "~/.config/dotfiles" ];
    };
  };
}
