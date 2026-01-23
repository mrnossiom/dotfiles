{
  config,
  lib,
  pkgs,
  upkgs,
  lpkgs,

  isDarwin,
  ...
}:

let
  flags = config.local.flags;
  cfg = config.local.fragment.shell;
in
{
  options.local.fragment.shell.enable = lib.mkEnableOption ''
    Shell related
  '';

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = {
        git_branch.disabled = true;
        git_commit.disabled = true;
        git_metrics.disabled = false;
        git_state.disabled = true;
        git_status.disabled = true;

        nix_shell = {
          # remove nix shell name
          format = "via [$symbol]($style) ";
          symbol = " ";
        };
      };
    };

    programs.direnv = {
      enable = true;
      silent = true;

      nix-direnv.enable = true;

      stdlib = ''
        use angrr
      '';
    };
    # TODO: depend on osConfig
    xdg.configFile."direnv/lib/angrr.sh".text = ''
      use_angrr() {
        layout_dir="$(direnv_layout_dir)"
        log_status "angrr: touch GC roots $layout_dir"
        RUST_LOG="''${ANGRR_DIRENV_LOG:-angrr=error}" ${lib.getExe upkgs.angrr} touch "$layout_dir" --silent
      }
    '';

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    home.sessionVariables._ZO_EXCLUDE_DIRS = "$HOME:/nix/store/*:/tmp/*";

    programs.fish = {
      enable = true;
      package = pkgs.fish;

      interactiveShellInit = ''
        abbr -a !! --position anywhere --function last_history_item
      '';

      shellAliases = {
        # Use `eza` for `ls` invocations
        #
        # This is also a more pure version than using `__fish_ls_*` variables
        # that depends on fish internal ls wrappers and can be overridden by
        # bad configuration. (e.g. NixOS `environment.shellAliases` default)
        ls = "${lib.getExe lpkgs.lsr}";

        pasters = "${lib.getExe pkgs.curl} --data-binary @- https://paste.rs/";

        mkcd = "mkdir $argv[1] && builtin cd $argv[1]";
      };

      shellAbbrs = {
        # One letter abbrs
        c = "cargo";
        d = "docker";
        dc = "docker compose";
        g = "git";
        j = "just";
        n = "nix";
        m = "make";

        # Edit utilities
        cp = "cp -iv";
        ln = "ln -v";
        mv = "mv -iv";
        mkdir = "mkdir -v";
        tp = "trash-put";

        # Listing utilities
        l = "ls -A1";
        ll = "ls -Al";

        # Nix-related
        ur = " unlink result";

        # Do not keep these commands in history
        exit = " exit";
        history = " history";
        reboot = " reboot";
        shutdown = " shutdown";
      };

      functions = {
        # Executed on interactive shell start
        fish_greeting = ""; # do nothing

        # Used in interactiveShellInit
        last_history_item = "echo $history[1]";

        repeat = ''
          set -l command (string join ' ' -- $argv)

          while true
              # Prompt for package name
              read -P "\$ "(set_color brgreen)"$command "(set_color normal) package_name

              # Check if nothing was entered to quit
              test "$package_name" = "" && break

              # Run 'apt info' command with the provided package name
              fish -c "$command $package_name"
          end
        '';

        launch = ''nohup $argv &> /dev/null &'';

        # Transform a store link file to a real one
        # Useful when playing with config files
        unnix = ''
          set -l path $argv[1]
          set -l realpath (readlink $path)
          set -l nstore "/nix/store"
          test (echo $realpath | head -c(string length $nstore)) = "$nstore"

          unlink $path
          cp "$realpath" "$path"
          chmod 644 "$path"
        '';

        # Quickly explore a derivation (using registry syntax)
        # e.g. `cdd nixpkgs#fontforge` or `cdd unixpkgs#fontforge`
        cdd = "cd (nix build --no-link --print-out-paths $argv | ${lib.getExe pkgs.fzf})";
      }
      // lib.optionalAttrs (!flags.onlyCached) {
        # Quickly get outta here to test something
        cdtmp = ''
          set -l name $argv[1] (${lib.getExe lpkgs.names})
          set -l dir /tmp/$name[1]

          mkdir $dir
          cd $dir
        '';
      }
      // lib.optionalAttrs (!isDarwin) {
        change-mac = ''
          set dev (nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show | sed '/^wifi/!{h;d;};x;q')
          sudo ip link set $dev down

          if test "$argv[1]" = "reset";
              sudo ${lib.getExe pkgs.macchanger} --permanent $dev
          else;
              sudo ${lib.getExe pkgs.macchanger} --ending --another $dev
          end

          sudo ip link set $dev up
        '';
      };
    };
  };
}
