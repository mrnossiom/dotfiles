{ pkgs, ... }:

{
  config = {
    home.packages = with pkgs; [
      # TUIs
      btop
      glow
      gping
      otree
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
      pv
      ripgrep
      speedtest-go
      upkgs.srgn
      sshfs
      sweep
      tealdeer
      termimage
      tokei
      trash-cli
    ];
  };
}
