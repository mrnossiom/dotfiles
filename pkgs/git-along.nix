{ lib, fetchFromGitHub, buildGoPackage, scdoc, nix-update-script }:

buildGoPackage rec {
  pname = "git-along";
  version = "1.5.4";


  goPackagePath = "github.com/nyarly/${pname}";

  src = fetchFromGitHub {
    owner = "nyarly";
    repo = pname;
    rev = "a1c51e8b554312173c4922bdfe3c10a9b500f7ce";
    sha256 = "sha256-q/XZrZ4jW9ZPVf8zcW6gsdMS42d56Ze/aF6HKAwM7XM=";
  };

  meta = with lib; {
    description = "Manage project configuration and environment in side branches";
    homepage = "https://github.com/nyarly/git-along";
    # license = licenses.isc;
    maintainers = [ "mrnossiom" ];
    platforms = platforms.linux;
    mainProgram = "git-along";
  };
}

