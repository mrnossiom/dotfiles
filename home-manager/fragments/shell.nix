{ config
, lib
, pkgs
, lpkgs

, isDarwin
, ...
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
          format = "via [$symbol$state]($style) "; # Remove nix shell name
          symbol = " ";
        };
      };
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    # Entering in shells is indicated by starship
    home.sessionVariables.DIRENV_LOG_FORMAT = "";

    programs.nushell = {
      enable = true;

      extraConfig = ''
        $env.config = {
          show_banner: false,
        }
      '';
    };

    programs.zoxide = {
      enable = true;
      options = [ "--cmd cd" ];
    };
    home.sessionVariables._ZO_EXCLUDE_DIRS = "$HOME:/nix/store/*:/tmp/*";

    programs.fish = {
      enable = true;

      interactiveShellInit = ''
        abbr -a !! --position anywhere --function last_history_item
      '';

      shellAliases = {
        # Use `eza` for `ls` invocations
        #
        # This is also a more pure version than using `__fish_ls_*` variables
        # that depends on fish internal ls wrappers and can be overridden by
        # bad configuration. (e.g. NixOS `environment.shellAliases` default)
        ls = "${lib.getExe pkgs.eza} --color=auto --icons=auto --hyperlink";

        tb = "nc termbin.com 9999";
      };

      shellAbbrs = {
        # One letter abbrs
        c = "cargo";
        d = "docker";
        dc = "docker compose";
        g = "git";
        j = "just";
        n = "nix";

        # Edit utilities
        cp = "cp -iv";
        ln = "ln -v";
        mv = "mv -iv";
        mkdir = "mkdir -v";
        tp = "trash-put";

        # Listing utilities
        l = "ls -aF";
        ll = "ls -lhaF";
        tree = "ls -T";

        # Nix-related
        ur = " unlink result";

        # Use newer tools
        clear = "#"; # <ctrl-l>
        cat = "#"; # bat
        rm = "#"; # trash-put
        tr = "#"; # srgn

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

        # Quickly explore a derivation (using registry syntax)
        # e.g. `cdd nixpkgs#fontforge` or `cdd nixpkgs-unstable#fontforge` 
        cdd = "cd (nix build --no-link --print-out-paths $argv | ${lib.getExe pkgs.fzf})";
      } // lib.optionalAttrs (!flags.onlyCached) {
        # Quickly get outta here to test something
        cdtmp = ''
          set -l name $argv[1] (${lib.getExe lpkgs.names})
          set -l dir /tmp/$name[1]

          mkdir $dir
          cd $dir
        '';
      } // lib.optionalAttrs (!isDarwin) {
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
