# {
#   self,
#   inputs,
#   withSystem,
#   ...
# }:
# {
#   flake.nixosConfigurations.apple-wiro = withSystem "aarch64-darwin" (
#     { pkgs, ... }:
#     inputs.nix-darwin.lib.darwinSystem {
#       inherit pkgs;
#       modules = [
#         self.modules.nixos.profile-laptop

#         ({ ... }: {
#           config = {
#             system.configurationRevision = self.rev or self.dirtyRev;

#             # Used for backwards compatibility, please read the changelog before changing.
#             # $ darwin-rebuild changelog
#             system.stateVersion = 4;

#             nixpkgs.hostPlatform = "aarch64-darwin";
#           };
#         })
#       ];
#     }
#   );
# }
{ }
