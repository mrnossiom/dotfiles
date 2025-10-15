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
      ouch
      parallel
      lpkgs.paste-rs
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
      unzip
      vlock
      wcurl
      wormhole-rs
    ]) ++ lib.optionals (!flags.onlyCached) [
      lpkgs.otree
    ];

    programs.bat = {
      enable = true;
      config = {
        style = "plain";
      };
    };
  };
}
