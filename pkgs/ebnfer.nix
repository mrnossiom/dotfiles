{
  lib,

  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage rec {
  pname = "ebnfer";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "DanielHauge";
    repo = pname;
    # rev = "v${version}";
    rev = "f1c3a506859f6b62e14b898f5b5e59781dfe3278";
    hash = "sha256-CSe2HCToYW7ivH6jpJwqHKH/yZDZgW8el8FVCmq75cU=";
  };

  cargoHash = "sha256-URT4jTKkCkK7Mr94ll1DloSEcrbkUJk8HFxkTmePf/w=";

  meta = with lib; {
    description = "A language server for EBNF";
    homepage = "https://github.com/DanielHauge/ebnfer";
    # license = licenses.mit;
    maintainers = [ "mrnossiom" ];
    mainProgram = "ebnfer";
  };
}
