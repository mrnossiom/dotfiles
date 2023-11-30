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

        ui = "!${pkgs.gitui}/bin/gitui";

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

      extraConfig = {
        fetch.prune = true;
        color.ui = true;
        init.defaultBranch = "main";

        # TODO: connect to a SSOT
        github.user = "mrnossiom";

        credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
        "credentials \"https://github.com\"".helper = "!${pkgs.gh}/bin/gh auth git-credential";

        leaveTool.defaultFolder = "~/Documents";
      };
    };

    programs.gh = {
      enable = true;
      # extensions = with pkgs; [ gh-dash ];
    };

    # TODO: unstable hm
    # programs.gh-dash.enable = true;
  };
}
