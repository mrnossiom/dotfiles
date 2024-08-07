{ lib

, stdenv
, rustPlatform
, fetchFromGitHub
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "otree";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "fioncat";
    repo = pname;
    # rev = "v${version}";
    rev = "bbaf9d53659e242eb7e85517c2d8aacefcac7d25";
    hash = "sha256-xqTfNFot8wXSTxsQVwM+4hD+z0BIbblC/lpd9uBJf8I=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "tui-tree-widget-0.20.0" = "sha256-/uLp63J4FoMT1rMC9cv49JAX3SuPvFWPtvdS8pspsck=";
    };
  };

  buildInputs = [ ]
    ++ lib.optionals stdenv.isDarwin [ darwin.apple_sdk.frameworks.IOKit ];

  meta = with lib; {
    description = "A command line tool to view objects (JSON/YAML/TOML) in TUI tree widget";
    homepage = "https://github.com/fioncat/otree";
    license = licenses.mit;
    maintainers = with maintainers; [ mrnossiom ];
    mainProgram = "otree";
  };
}
