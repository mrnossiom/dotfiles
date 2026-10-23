{ moduleWithSystem, ... }:
{
  flake.modules.homeManager.tools = moduleWithSystem (
    { self', ... }:
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        home.packages =
          (with pkgs; [
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
            doggo
            dust
            encfs
            fastfetch
            fd
            ffmpeg
            file
            fzf
            git-pages-cli
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
          ])
          ++ lib.optionals (!config.local.flags.onlyCached) [
            self'.packages.nix-alien
          ];

        programs.fish.shellAbbrs = {
          # Use newer tools
          cat = "#"; # bat
          clear = "#"; # <ctrl-l>
          rm = "#"; # trash-put
          tr = "#"; # srgn

          tp = "trash-put";
        };

        programs.bat = {
          enable = true;
          config = {
            style = "plain";
          };
        };
      };
    }
  );
}
