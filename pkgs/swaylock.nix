{
  swaylock,
  fetchFromGitHub,
  ...
}:

# TODO: remove once github:swaywm/swaylock#369 is merged
swaylock.overrideAttrs (old: {
  src = fetchFromGitHub {
    owner = "mrnossiom";
    repo = "swaylock";
    rev = "1e949610081ea0788d9fba6f0d7c909d7b62e9e0";
    hash = "sha256-3YN6n5mYB7r1Xk22AGYMusNbA6aBD6OMU3Gn9OOuS6o=";
  };
})
