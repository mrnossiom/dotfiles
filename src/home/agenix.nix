{ inputs, ... }:
{
  flake.modules.homeManager.agenix = { config, ... }: {
    imports = [ inputs.agenix.homeManagerModules.default ];

    config = {
      # This allows us to decrypt user space secrets without having to use a
      # passwordless ssh key as you cannot interact with age in the service.
      age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
    };
  };
}
