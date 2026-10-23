{ inputs, ... }:
{
  flake.modules.nixos.sops = {
    imports = [ inputs.sops-nix.nixosModules.default ];

    config = {
      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
  };
}
