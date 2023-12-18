{ config, lib, pkgs, ... }:
with lib;
{
  config = {
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

      ignores = [ ".direnv/" ];

      aliases = {
        b = "branch --all";
        brm = "branch --delete";

        ll = "log --graph --oneline";
        lla = "log --graph --oneline --all";
        last = "log -1 HEAD --stat";

        st = "status --short --branch";

        cm = "commit --message";
        oups = "commit --amend";

        ui = "!${getExe pkgs.gitui}";

        rv = "remote --verbose";

        a = "add";
        al = "add --all";
        ac = "add .";
        ap = "add --patch";

        pu = "push";
        pl = "pull";

        f = "fetch";

        s = "switch";
        sc = "switch --create";

        ck = "checkout";

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
          export GITGUARDIAN_API_KEY="$(cat ${config.age.secrets.gitguardian-api-key.path})"
          ${getExe' pkgs.ggshield "ggshield"} secret scan pre-commit "$@"
        '';
      };


      extraConfig = {
        fetch.prune = true;
        color.ui = true;
        init.defaultBranch = "main";
        log.date = "human";

        # TODO: connect to a SSOT
        github.user = "mrnossiom";

        credential.helper = "${getExe' (pkgs.git.override { withLibsecret = true; }) "git-credential-libsecret"}";
        "credentials \"https://github.com\"".helper = "!${getExe pkgs.gh} auth git-credential";

        # TODO: change to $PROJECTS env var?
        leaveTool.defaultFolder = "~/Developement";
      };
    };

    home.packages = with pkgs; [ git-leave ];

    programs.gh.enable = true;

    programs.gh-dash.enable = true;
  };
}
