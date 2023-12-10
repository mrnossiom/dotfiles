final: prev: {
  # Geogebra locales clashes with Authy locales (why? I don't care)
  geogebra6 = prev.geogebra6.overrideAttrs (previousAttrs: {
    installPhase = previousAttrs.installPhase + ''rm -rf "$out/locales/"'';
  });

  # TODO: fix darkman Go patch
  _darkman =
    let
      version = "1.5.5.unreleased";

      src = final.fetchFromGitLab {
        owner = "milomoisson";
        repo = "darkman";
        rev = "91eef4fd162eaed7797facc703414f358686e883";
        hash = "sha256-Wx5GhKxG/GTEkb1YohSFKOXvaJ/qmxHoXYNEZw7P/R0=";
      };

      vendorHash = "sha256-7bglQlEMUP24q9fUZLeObKaCpoJBrFf5i4j7s2i3rRc=";
    in
    (final.callPackage "${final.path}/pkgs/applications/misc/darkman" {
      buildGoModule = args: final.buildGoModule (args // {
        inherit src version vendorHash;
      });
    });
}
