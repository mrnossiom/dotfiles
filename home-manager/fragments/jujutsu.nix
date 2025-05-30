{ config
, lib
, pkgs
, lpkgs
, ...
}:

let
  flags = config.local.flags;

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
      package = if flags.onlyCached then pkgs.jujutsu else lpkgs.jujutsu;

      settings = {
        user = {
          name = "Milo Moisson";
          email = "milo@wiro.world";
        };

        signing = {
          behavior = "own";
          backend = "ssh";
          key = keys.milomoisson;

          git.sign-on-push = true;
        };

        template-aliases = {
          custom_log_compact = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  separate(" ",
                    format_short_change_id_with_hidden_and_divergent_info(self),
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
        };

        ui = {
          default-command = "log";

          diff-editor = ":builtin";
          merge-editor = ":builtin";

          diff-formatter = [ "difft" "--color=always" "--display=inline" "$left" "$right" ];
        };

        aliases = {
          ui = [ "util" "exec" "--" "lazyjj" ];
        };

        git = {
          private-commits = ''description(glob:"private:*")'';
        };
      };
    };

    home.packages = with pkgs; [
      difftastic
    ];
  };
}
