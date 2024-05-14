{ lib

, fetchFromGitHub
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "sweep";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "woubuc";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-HpapdWs7F3zB/ZpUXGxXODNin3zifzkZpB95mOKDWyk=";
  };

  cargoHash = "sha256-XoGFw/ramHsK0viOS+NAn+DpuM+MSlY4eDPbwkyZuJA=";

  meta = with lib; {
    description = "Reduce the disk usage of your projects by removing dependencies & builds";
    homepage = "https://github.com/woubuc/sweep";
    license = licenses.mit;
    maintainers = with maintainers; [ "mrnossiom" ];
    mainProgram = "swp";
  };
}

