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
    description = "Blank flake setup";
    welcomeText = ''
      You may want to run
      $ direnv allow
    '';
  };

  rust = {
    path = ./rust;
    description = "Rust flake setup";
    welcomeText = ''
      You may want to run
      $ direnv allow
    '';
  };
}
