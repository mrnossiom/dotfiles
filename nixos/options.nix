{
  lib,
  config,
  ...
}:

let

  portSubmodule = lib.types.submodule (
    { name, config, ... }:
    {
      options = {
        number = lib.mkOption {
          type = lib.types.port;
          description = "The port number for ${name}.";
        };
        string = lib.mkOption {
          type = lib.types.str;
          readOnly = true;
          description = "The string representation of the port number.";
        };
        description = lib.mkOption {
          type = lib.types.str;
          default = "";
        };
        public = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether this port should be accessible from the public internet.";
        };
        tcp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable TCP for this port.";
        };
        udp = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable UDP for this port.";
        };
      };

      config = {
        string = toString config.number;
      };
    }
  );

  portType = lib.types.coercedTo lib.types.int (num: { number = num; }) portSubmodule;
in
{
  options = {
    local.ports = lib.mkOption {
      description = "Mapping of service names to port numbers with uniqueness validation.";
      type = lib.types.attrsOf portType;
      default = { };
    };
  };

  config = {
    assertions =
      let
        # map port numbers to a list of port names
        portToNames = lib.groupBy 
          (name: config.local.ports.${name}.string) 
          (lib.attrNames config.local.ports);
        clashes = lib.filterAttrs (port: names: (lib.length names) > 1) portToNames;
        clashStrings = lib.mapAttrsToList (
          port: names: "Port ${port} is shared by: ${lib.concatStringsSep ", " names}"
        ) clashes;

      in
      [
        {
          assertion = (lib.length clashStrings) == 0;
          message = ''
            Conflict in `local.ports`!
            ${lib.concatStringsSep "\n" clashStrings}
          '';
        }
      ];

    networking.firewall =
      let
        publicPorts = lib.filterAttrs (name: portConf: portConf.public) config.local.ports;
      in
      {
        allowedTCPPorts = lib.mapAttrsToList (n: p: p.number) (lib.filterAttrs (n: p: p.tcp) publicPorts);
        allowedUDPPorts = lib.mapAttrsToList (n: p: p.number) (lib.filterAttrs (n: p: p.udp) publicPorts);
      };
  };
}
