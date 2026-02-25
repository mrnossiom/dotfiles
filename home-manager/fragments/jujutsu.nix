{
  config,
  lib,
  pkgs,
  upkgs,
  ...
}:

let
  keys = import ../../secrets/keys.nix;

  cfg = config.local.fragment.jujutsu;
in
{
  options.local.fragment.jujutsu.enable = lib.mkEnableOption ''
    Jujutsu related
  '';

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      package = upkgs.jujutsu;

      settings = {
        user = {
          name = "Milo Moisson";
          email = "milo@wiro.world";
        };

        signing = {
          behavior = "own";
          backend = "ssh";
          key = keys.milo-ed25519;
          git.sign-on-push = true;
        };

        template-aliases = {
          custom_log_compact = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  separate(" ",
                    format_short_change_id_with_change_offset(self),
                    format_short_signature_oneline(author),
                    bookmarks,
                    tags,
                    working_copies,
                    if(conflict, label("conflict", "conflict")),
                    if(config("ui.show-cryptographic-signatures").as_boolean(),
                      format_short_cryptographic_signature(signature)),
                    if(empty, label("empty", "(empty)")),
                    if(description,
                      description.first_line(),
                      label(if(empty, "empty"), description_placeholder),
                    ),
                  ) ++ "\n",
                ),
              )
            )
          '';
        };

        templates = {
          log = "custom_log_compact";
          git_push_bookmark = ''"push-" ++ change_id.short()'';
        };

        revset-aliases = {
          "current()" = "(::@ ~ ::trunk())";
          "open()" = "((::tracked_remote_bookmarks() | mine()) ~ ::trunk())::";
          "visible_open()" = "(open() & ::visible_heads())::";
          # Useful to rebase all branches with `jj r -s "all:visible_open_roots()" -d main/master/develop/..`
          "visible_open_roots()" = "roots(visible_open())";
        };

        ui = {
          default-command = "log";

          conflict-marker-style = "snapshot";

          diff-editor = ":builtin";
          merge-editor = ":builtin";
          pager = ":builtin";

          diff-formatter = [
            "difft"
            "--color=always"
            "--display=inline"
            "$left"
            "$right"
          ];
        };

        aliases = {
          ui = [
            "util"
            "exec"
            "--"
            "${lib.getExe pkgs.lazyjj}"
          ];
        };

        git = {
          private-commits = ''description(glob:"LOCAL:*")'';
        };
      };
    };

    home.packages = with pkgs; [
      difftastic
    ];
  };
}
