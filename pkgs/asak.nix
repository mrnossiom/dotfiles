{ lib
, rustPlatform
, fetchFromGitHub

, pkg-config
, alsa-lib
, jack2
}:

rustPlatform.buildRustPackage rec {
  pname = "asak";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "chaosprint";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yhR8xLCFSmTG2yqsbiP3w8vcvLz4dsn4cbMPFedzUFI=";
  };

  cargoHash = "sha256-ssHYQhx5rNkTH6KJuJh2wPcptIcIxP8BcDNriGj3btk=";

  nativeBuildInputs = [
    pkg-config
    alsa-lib
    jack2
  ];

  PKG_CONFIG_PATH = "${alsa-lib.dev}/lib/pkgconfig:${jack2.dev}/lib/pkgconfig";

  buildInputs = [ ];

  meta = with lib; {
    description = "A cross-platform audio recording/playback CLI tool with TUI";
    homepage = "https://github.com/chaosprint/asak";
    maintainers = [ "mrnossiom" ];
    mainProgram = "asak";
  };
}

