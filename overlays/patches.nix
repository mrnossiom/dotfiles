final: prev:

{
  bluesky-pds = prev.bluesky-pds.override {
    nodejs_24 = prev.nodejs_22;
  };
}
