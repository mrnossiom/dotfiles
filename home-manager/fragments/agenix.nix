{ self
, config
, lib
, ...
}:

let
  inherit (self.inputs) agenix;

  cfg = config.local.fragment.agenix;

  all-secrets = import ../../secrets;
in
{
  options.local.fragment.agenix.enable = lib.mkEnableOption ''
    Agenix related
  '';

  imports = [ agenix.homeManagerModules.default ];

  config = lib.mkIf cfg.enable {
    age.secrets = all-secrets.home-manager;
    # This allows us to decrypt user space secrets without having to use a
    # passwordless ssh key as you cannot interact with age in the service.
    age.identityPaths = [ "${config.home.homeDirectory}/.ssh/id_home_manager" ];
  };
}
