{ config
, lib
, pkgs
, lpkgs
, ...
}:

let
  flags = config.local.flags;
  cfg = config.local.fragment.tools;
in
{
  options.local.fragment.tools.enable = lib.mkEnableOption ''
    All sorts of CLIs, TUIs
  '';

  config = lib.mkIf cfg.enable {
    home.packages = (with pkgs; [
      # Man
      ascii
      man-pages

      # TUIs
      btop
      glow

      # CLIs
      asciinema
      calc
      delta
      dogdns
      du-dust
      encfs
      fastfetch
      fd
      ffmpeg
      file
      fzf
      inetutils
      jq
      just
      killall
      libnotify
      lsof
      mediainfo
      openssl
      otree
      ouch
      parallel
      pv
      restic
      ripgrep
      speedtest-go
      srgn
      sshfs
      termimage
      tlrc
      tokei
      trash-cli
      uni
      unzip
      vlock
      wcurl
      wormhole-rs
    ]) ++ lib.optionals (!flags.onlyCached) [ ];

    programs.fish.shellAbbrs = {
      # Use newer tools
      clear = "#"; # <ctrl-l>
      cat = "#"; # bat
      rm = "#"; # trash-put
      tr = "#"; # srgn
    };

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };
  };
}
