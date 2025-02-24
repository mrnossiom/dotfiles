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
      du-dust
      encfs
      fastfetch
      fd
      ffmpeg
      file
      fzf
      jq
      just
      killall
      libnotify
      lsof
      mediainfo
      ouch
      parallel
      pv
      restic
      ripgrep
      speedtest-go
      srgn
      sshfs
      tealdeer
      termimage
      tokei
      trash-cli
      wcurl
    ]) ++ lib.optionals (!flags.onlyCached) [
      lpkgs.otree
      lpkgs.sweep
    ];
  };
}
