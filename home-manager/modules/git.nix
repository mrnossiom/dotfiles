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

        ui = "!${getExe pkgs.gitui}";

        rv = "remote --verbose";

        ri = "rebase --interactive";

        a = "add";
        al = "add --all";
        ac = "add .";
        ap = "add --patch";

        pu = "push";
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
          ${getExe' pkgs.ggshield "ggshield"} secret scan pre-commit "$@"
        '';
      };


      extraConfig = {
        fetch.prune = true;
        color.ui = true;
        init.defaultBranch = "main";

        pretty.custom = "format:%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cd) %C(bold blue)<%an>";
        log.date = "human";

        advice.addEmptyPathspec = false;

        # TODO: connect to a SSOT
        github.user = "mrnossiom";

        credential.helper = "${getExe' (pkgs.git.override { withLibsecret = true; }) "git-credential-libsecret"}";
        "credentials \"https://github.com\"".helper = "!${getExe pkgs.gh} auth git-credential";

        # TODO: change to $PROJECTS env var?
        leaveTool.defaultFolder = "~/Developement";
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

    home.packages = with pkgs; [ git-leave git-along radicle-cli radicle-httpd radicle-node ];

    programs.gh.enable = true;

    programs.gh-dash.enable = true;
  };
}
