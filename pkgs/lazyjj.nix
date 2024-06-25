{ lib

, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "lazyjj";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Cretezy";
    repo = pname;
    # rev = "v${version}";
    rev = "c4e604b1b91ec9df479f19d8b27397d072a10660";
    hash = "sha256-IdhWFME2HCxRbsQECt9Aapl7S2tSpZE9e+lHhPsLa6Q=";
  };

  cargoHash = "sha256-2HccTmARFgyV0r9w2LuHLjnGET03L25ocB1t1AGGx2o=";

  RUSTC_BOOTSTRAP = true;

  meta = with lib; {
    description = "TUI for jujutsu";
    homepage = "https://github.com/Cretezy/lazyjj";
    # license = licenses.apache;
    maintainers = [ "mrnossiom" ];
    mainProgram = "lazyjj";
  };
}

