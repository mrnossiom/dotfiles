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

    Depends on: Agenix
  '';

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      # Disable annoying warning message
      GIT_DISCOVERY_ACROSS_FILESYSTEM = 0;
    };

    programs.git = {
      enable = true;
      lfs.enable = true;

      userName = "Milo Moisson";
      # TODO: this email should be behind a secret
      userEmail = "milomoisson@gmail.com";

      signing = {
        signByDefault = true;
        key = "3C01CA5E";
      };

      difftastic.enable = true;

      # Ignore very specific stuff that is not common to much repos
      ignores = [
        # Direnv cache
        ".direnv/"
        # Nix build result link
        "result"
      ];

      aliases = {
        b = "branch --all";
        brm = "branch --delete";

        ll = "log --graph --oneline --pretty=custom";
        lla = "log --graph --oneline --pretty=custom --all";
        last = "log -1 HEAD --stat";

        st = "status --short --branch";

        cm = "commit --message";
        oups = "commit --amend";

        ui = "!${lib.getExe pkgs.lazygit}";

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
        put = "push --tags";
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

      hooks = {
        git-guardian = pkgs.writeShellScript "git-guardian" ''
          export GITGUARDIAN_API_KEY="$(cat ${config.age.secrets.api-gitguardian.path})"
          ${lib.getExe' pkgs.ggshield "ggshield"} secret scan pre-commit "$@"
        '';
      };

      extraConfig = {
        fetch.prune = true;
        color.ui = true;
        init.defaultBranch = "main";

        rebase.autosquash = true;
        push.autoSetupRemote = true;
        pull.rebase = true;

        pretty.custom = "format:%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cd) %C(bold blue)<%an>";
        log.date = "human";

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

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Milo Moisson";
          email = "milomoisson@gmail.com";
        };
      };
    };

    home.packages = (with pkgs; [
      radicle-node
    ]) ++ lib.optionals (!flags.onlyCached) [
      lpkgs.git-leave
    ];

    programs.gh.enable = true;

    programs.gh-dash.enable = true;

    programs.lazygit.enable = true;
  };
}
