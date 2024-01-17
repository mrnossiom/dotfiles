{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "rusty-rain";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "cowboy8625";
    repo = pname;
    # rev = "v${version}";
    rev = "803c739e885881c0009d1d45394c0da54e743b52";
    hash = "sha256-jlupmHvnOPkbtYvGugHi1HMRPztxkqTHliXiVMLMIlg=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  cargoLock.lockFile = ./Cargo.lock;

  meta = with lib; {
    description = "A cross platform matrix rain made with Rust";
    homepage = "https://github.com/cowboy8625/rusty-rain";
    license = licenses.asl20;
    maintainers = [ "mrnossiom" ];
    mainProgram = "rusty-rain";
  };
}
