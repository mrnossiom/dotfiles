{
  flake.templates = rec {
    default = dotfiles;

    dotfiles = {
      path = ../.;
      description = "mrnossiom's dotfiles";
      welcomeText = ''
        Wait, someone cloned my dotfiles?
      '';
    };

    blank = {
      path = ./_templates/blank;
      description = "Flake for default/blank setup";
      welcomeText = "`direnv allow`";
    };

    c = {
      path = ./_templates/c;
      description = "Flake for C setup";
      welcomeText = "`direnv allow`";
    };

    rust = {
      path = ./_templates/rust;
      description = "Flake for Rust setup";
      welcomeText = "`direnv allow`";
    };

    rust-pkg = {
      path = ./_templates/rust-pkg;
      description = "Flake for Rust setup with intent to package";
      welcomeText = "`direnv allow`";
    };
  };
}
