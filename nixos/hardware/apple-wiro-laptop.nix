{ self
, config
, lib
, ...
}:

{
  imports = [ ];

  config = {
    system.configurationRevision = self.rev or self.dirtyRev;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 4;

    nixpkgs.hostPlatform = "aarch64-darwin";
  };
}
