{ lib, pkgs, ... }:

with lib;

{
  imports = [
    ./helix.nix
    ./workstyle
    ./zellij
  ];

  config = {
    programs.starship = {
      enable = true;
      settings.nix_shell = {
        format = "via [$symbol$state]($style) "; # Remove nix shell name
        symbol = " ";
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

    programs.fish = {
      enable = true;

      loginShellInit = ''
        if test (id --user $USER) -ge 1000 && test (tty) = "/dev/tty1"
          exec sway
        end
      '';

      interactiveShellInit = ''
        abbr -a !! --position anywhere --function last_history_item
      '';

      shellAliases = {
        # Use `eza` for `ls` invocations
        #
        # This is also a more pure version than using `__fish_ls_*` variables
        # that depends on fish internal ls wrappers and can be overriden by
        # bad configuration. (e.g. NixOS `environment.shellAliases` default)
        ls = "${getExe pkgs.eza} --color=auto --icons=auto --hyperlink";

        tb = "nc termbin.com 9999";
      };

      shellAbbrs = {
        # One letter abbrs
        c = "cargo";
        d = "docker";
        g = "git";
        j = "just";
        n = "nix";

        # Edit utilities
        rm = "rm -i";
        rmd = "rm -rd";
        cp = "cp -iv";
        ln = "ln -v";
        mv = "mv -iv";
        mkdir = "mkdir -v";

        # Listing utilities
        l = "ls -Fa";
        ll = "ls -lhFa";
        ld = "ls -FD";
        tree = "ls -T";

        # Nix-related
        ur = " unlink result";

        # Do not keep these commands in history
        shutdown = " shutdown";
        clr = " clear";
        reboot = " reboot";
        history = " history";
        exit = " exit";
      };

      functions = {
        # Executed on interactive shell start, greet with a short quote
        fish_greeting = "${getExe pkgs.fortune} -s";

        # Used in interactiveShellInit
        last_history_item = "echo $history[1]";

        # Quickly get outta here to test something
        cdtmp = ''
          set -l name $argv[1] (${getExe pkgs.names})
          set -l dir /tmp/$name[1]

          mkdir $dir
          cd $dir
        '';

        change-mac = ''
          set dev (nmcli --get-values GENERAL.DEVICE,GENERAL.TYPE device show | sed '/^wifi/!{h;d;};x;q')
          sudo ip link set $dev down
    
          if test "$argv[1]" = "reset";
              sudo ${getExe pkgs.macchanger} --permanent $dev
          else;
              sudo ${getExe pkgs.macchanger} --ending --another $dev
          end

          sudo ip link set $dev up
        '';

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

        nix-develop = "nix develop $argv --command fish";

        # Quickly explore a derivation (using registry syntax)
        # e.g. `cdd nixpkgs#fontforge` or `cdd nixpkgs-unstable#fontforge` 
        cdd = "cd (nix build --no-link --print-out-paths $argv | ${getExe pkgs.fzf})";
      };
    };
  };
}
