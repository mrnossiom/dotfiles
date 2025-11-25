{ config
, lib
, pkgs
, lpkgs
, ...
}:

let
  flags = config.local.flags;
  cfg = config.local.fragment.git;
in
{
  options.local.fragment.git.enable = lib.mkEnableOption ''
    Git related
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      { assertion = config.local.fragment.agenix.enable; message = "`git` fragment depends on `agenix` fragment"; }
    ];

    home.sessionVariables = {
      # Disable annoying warning message
      GIT_DISCOVERY_ACROSS_FILESYSTEM = 0;
    };

    programs.git = {
      enable = true;
      lfs.enable = true;

      signing.signByDefault = true;
      signing.key = "~/.ssh/id_ed25519.pub";

      # Ignore very specific stuff that is not common to much repos
      ignores = [
        # Direnv cache
        ".direnv/"
        # Nix build result link
        "result"
      ];

      settings = {
        user = {
          name = "Milo Moisson";
          # TODO: this email should be behind a secret or at least a config
          email = "milo@wiro.world";
        };

        alias = {
          b = "branch --all";
          brm = "branch --delete";

          ll = "log --graph --oneline --pretty=custom";
          lla = "log --graph --oneline --pretty=custom --all";
          last = "log -1 HEAD --stat";

          st = "status --short --branch";

          cm = "commit --message";
          oups = "commit --amend";

          ui = "!lazygit";

          rv = "remote --verbose";

          ri = "rebase --interactive";
          ris = "!git ri $(git slc)";
          rc = "rebase --continue";
          rs = "rebase --skip";
          ra = "rebase --abort";

          # Select commit
          slc = "!git log --oneline --pretty=custom | fzf | awk '{printf $1}'";

          a = "add";
          al = "add --all";
          ac = "add .";
          ap = "add --patch";

          pu = "push";
          put = "push --follow-tags";
          puf = "push --force-with-lease";
          pl = "pull";

          f = "fetch";

          s = "switch";
          sc = "switch --create";

          ck = "checkout";

          cp = "cherry-pick";

          df = "diff";
          dfs = "diff --staged";
          dfc = "diff --cached";

          m = "merge";

          rms = "restore --staged";
          res = "restore";

          sh = "stash";
          shl = "stash list";
          sha = "stash apply";
          shp = "stash pop";
        };

        fetch.prune = true;
        color.ui = true;
        init.defaultBranch = "main";

        rebase.autosquash = true;
        push.autoSetupRemote = true;
        pull.rebase = true;

        diff.external = "difft --color=always --display=inline";

        pretty.custom = "format:%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cd) %C(bold blue)<%an>";
        log.date = "human";

        gpg.format = "ssh";

        advice = {
          addEmptyPathspec = false;
          forceDeleteBranch = false;
          skippedCherryPicks = false;
        };

        # TODO: connect to a SSOT
        github.user = "mrnossiom";

        "credentials \"https://github.com\"".helper = "!${lib.getExe pkgs.gh} auth git-credential";

        # TODO: change to $PROJECTS env var?
        leaveTool.defaultFolder = "~/Development";
      };
    };

    home.packages = (with pkgs; [
      glab

      lazyjj

      difftastic
    ]) ++ lib.optionals (!flags.onlyCached) [
      lpkgs.git-leave
    ];

    programs.gh.enable = true;

    programs.gh-dash.enable = true;

    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          showFileTree = false;
          showRandomTip = false;
          showCommandLog = false;
          border = "single";
        };

        git = {
          pagers.externalDiffCommand = "difft --color=always";
        };

        # to be declarative or not to be declarative?
        update.method = "never";
      };
    };
  };
}
