rec {
  default = dotfiles;

  dotfiles = {
    path = ../.;
    description = "";
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
