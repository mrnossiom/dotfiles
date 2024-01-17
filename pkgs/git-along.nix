{ lib, fetchFromGitHub, buildGoModule }:

buildGoModule rec {
  pname = "git-along";
  version = "0.0.0";

  src = fetchFromGitHub {
    # owner = "nyarly";
    owner = "mrnossiom";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-2pjaA0llShG8dxILWCvP45VgLFWhFbinAiNiOLM7ovg=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "Manage project configuration and environment in side branches";
    homepage = "https://github.com/nyarly/git-along";
    maintainers = [ "mrnossiom" ];
    mainProgram = "git-along";
  };
}

