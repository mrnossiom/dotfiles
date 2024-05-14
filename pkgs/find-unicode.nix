{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "find_unicode";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "pierrechevalier83";
    repo = pname;
    rev = "3afc33a7056f6fadd3e1d1d216d89a2f78e3ed67";
    hash = "sha256-hfTOUrFSlqOEzh2X3SnRx4UkmgCNDDfOjUT9325XSP8=";
  };

  cargoHash = "sha256-Ap7aLgmwh1xJWUxL/PQcPo6KxlJNE47LFs+WNxLFWi8=";

  meta = with lib; {
    description = "Find Unicode characters, the easy way! A simple command line application to find unicode characters with minimum effort.";
    homepage = "https://github.com/pierrechevalier83/find_unicode";
    maintainers = [ "mrnossiom" ];
    mainProgram = "fu";
  };
} 
