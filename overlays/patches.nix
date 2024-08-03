final: prev:

with final.lib;

{
  figma-linux = prev.figma-linux.overrideAttrs (prevAttrs: {
    buildInputs = prevAttrs.buildInputs ++ [ prev.makeWrapper ];
    installPhase = ''
      runHook preInstall

      mkdir -p $out/lib && cp -r opt/figma-linux/* $_
      mkdir -p $out/bin && ln -s $out/lib/figma-linux $_/figma-linux

      cp -r usr/* $out

      wrapProgramShell $out/bin/figma-linux \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--enable-features=UseOzonePlatform --ozone-platform=wayland}}"

      runHook postInstall
    '';
  });

  # TODO: remove once github:swaywm/swaylock#369 is merged
  swaylock = prev.swaylock.overrideAttrs (old: {
    src = prev.fetchFromGitHub {
      owner = "mrnossiom";
      repo = "swaylock";
      rev = "0e09892e93b82f6de2fcf10a773d5fbf9de61d73";
      hash = "sha256-IzgrQv/oJEyvlVlZCm/2LOhpxR4KfSz7llSq3s9t/qM=";
    };
  });
}
