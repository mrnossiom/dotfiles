rec {
  default = dotfiles;

  dotfiles = {
    path = ../.;
    description = "mrnossiom's dotfiles";
    welcomeText = ''
      Wait, someone cloned my dotfiles?
    '';
  };

  blank = {
    path = ./blank;
    description = "Flake for default/blank setup";
    welcomeText = "`direnv allow`";
  };

  rust = {
    path = ./rust;
    description = "Flake for Rust setup";
    welcomeText = "`direnv allow`";
  };

  rust-pkg = {
    path = ./rust-pkg;
    description = "Flake for Rust setup with intent to package";
    welcomeText = "`direnv allow`";
  };
}
