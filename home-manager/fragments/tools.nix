{ config
, lib
, pkgs
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
      csvlens
      delta
      dogdns
      dust
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
      perf
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
