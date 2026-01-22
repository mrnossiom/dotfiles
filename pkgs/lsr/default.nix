{
  lib,
  stdenv,
  installShellFiles,
  fetchgit,
  zig_0_14,
  callPackage,
  versionCheckHook,
}:

let
  zig = zig_0_14;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lsr";
  version = "1.0.0";

  src = fetchgit {
    url = "https://tangled.sh/@rockorager.dev/lsr";
    rev = "bbd03ced6db54c0a3f12cdfa6f737e01e2f0cf94";
    sparseCheckout = [
      "src"
      "docs"
    ];
    hash = "sha256-SDtuRr6N/QefGhj0WsryqTRRU7IPYbrAaL3W4dBg/eE=";
  };

  postPatch = ''
    ln -s ${callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
  '';

  nativeBuildInputs = [
    installShellFiles
    (zig.hook.overrideAttrs {
      # the default release=safe crashes lsr
      zig_default_flags = "-Dcpu=baseline --release=fast";
    })
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    homepage = "https://tangled.sh/@rockorager.dev/lsr";
    description = "ls but with io_uring";
    changelog = "https://tangled.sh/@rockorager.dev/lsr/tags";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ddogfoodd ];
    platforms = lib.platforms.linux;
    mainProgram = "lsr";
  };
})
