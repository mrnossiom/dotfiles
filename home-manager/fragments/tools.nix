{ pkgs
, lpkgs
, ...
}:

{
  config = {
    home.packages = with pkgs; [
      # TUIs
      btop
      glow
      gping
      lpkgs.otree
      thokr

      # CLIs
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
      lsof
      mediainfo
      ouch
      pv
      ripgrep
      speedtest-go
      upkgs.srgn
      sshfs
      lpkgs.sweep
      tealdeer
      termimage
      tokei
      trash-cli
      upkgs.wcurl
    ];
  };
}
