{ lib

, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "names";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "fnichol";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-C0JEVTOgxtgvCgSSdYxMCMtAVRU1A7DEczNj4zY8q20=";
  };

  cargoHash = "sha256-qaYiyfANQNJSpRhNJ9XQONC32KdEGx7QFqAxZ5E8uHk=";

  meta = with lib; {
    description = "Random name generator";
    homepage = "https://github.com/fnichol/names";
    license = licenses.mit;
    maintainers = [ "mrnossiom" ];
    mainProgram = "names";
  };
}
