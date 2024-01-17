{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-sloth";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ecumene";
    repo = pname;
    rev = "c2ba76199cf8727d2eb7c60a60817ecd9fcd4058";
    hash = "sha256-r//ifFQgsSU+MS7eHL2jOKr7gBCBHg/mDMW98q4gPXA=";
  };

  cargoHash = "sha256-FFnmMhoaEagatQkMdkSi7slsYZ7uL3l91S2azYF8LQU=";

  meta = with lib; {
    description = "A 3D software rasterizer... for the terminal!";
    homepage = "https://github.com/ecumene/rust-sloth";
    license = licenses.isc;
    maintainers = [ "mrnossiom" ];
    mainProgram = "sloth";
  };
}
