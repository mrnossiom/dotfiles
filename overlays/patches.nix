final: prev:

with final.lib;

{
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
