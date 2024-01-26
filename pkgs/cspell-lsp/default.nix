{ lib
, buildNpmPackage
, fetchFromGitHub
, typescript
}:

buildNpmPackage rec {
  pname = "cspell-lsp";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "vlabo";
    repo = pname;
    rev = "68b84953701a67e5e1f00c8553480019d87a93b6";
    hash = "sha256-u9PiaJDm8SapSSfjDU8XnjIzh7njvF9iZ2VAgAzj2ks=";
  };

  postPatch = ''
    rm package-lock.json
    cp ${./cspell-lsp/package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-TCinApesXIimAgt1cj1uv9h00pIBxbAIxXdYCTU88i4=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/vlabo/cspell-lsp";
    license = licenses.gpl3Only;
    maintainers = [ "mrnossiom" ];
    mainProgram = "cspell-lsp";

    broken = true; # TODO: doesn't build
  };
} 
