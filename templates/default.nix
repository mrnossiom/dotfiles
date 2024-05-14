rec {
  default = dotfiles;

  dotfiles = {
    path = ../.;
    description = "mrnossiom's dotfiles";
    welcomeText = ''
      Wait, someone cloned my dotfiles?
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
