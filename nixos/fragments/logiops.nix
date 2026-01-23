{
  self,
  config,
  lib,
  ...
}:

let
  inherit (self.outputs) nixosModules;

  cfg = config.local.fragment.logiops;
in
{
  imports = [ nixosModules.logiops ];

  options.local.fragment.logiops.enable = lib.mkEnableOption ''
    LogiOps related
  '';

  config.services.logiops = lib.mkIf cfg.enable {
    enable = true;

    settings =
      let
        cid = {
          # Control IDs │ reprog? │ fn key? │ mouse key? │ gesture support?
          #        0x50 │         │         │ YES        │
          #        0x51 │         │         │ YES        │
          #        0x52 │ YES     │         │ YES        │ YES
          #        0x53 │ YES     │         │ YES        │ YES
          #        0x56 │ YES     │         │ YES        │ YES
          #        0xD7 │ YES     │         │            │ YES
          #        0xFD │ YES     │         │ YES        │ YES
          leftMouse = 80;
          rightMouse = 81;
          middleMouse = 81;
          back = 83;
          forward = 86;
          switchReceivers = 215;
          mouseSensitivity = 253;
        };
      in
      {
        devices = [
          {
            name = "MX Vertical Advanced Ergonomic Mouse";

            dpi = 1500;

            hiresscroll = {
              hires = true;
              invert = false;
              target = false;
            };

            buttons = [
              {
                cid = cid.forward;
                action = {
                  type = "Keypress";
                  keys = [ "KEY_FORWARD" ];
                  # type = "Gestures";
                  # gestures = [
                  # {
                  #   direction = "Left";
                  #   mode = "OnThreshold";
                  #   action = {
                  #     type = "Keypress";
                  #     keys = ["KEY_LEFTMETA" "KEY_LEFTCTRL" "KEY_LEFTSHIFT" "KEY_TAB"];
                  #   };
                  # }
                  # ];
                };
              }
              {
                cid = cid.back;
                action = {
                  type = "Keypress";
                  keys = [ "KEY_BACK" ];
                };
              }
              {
                cid = cid.mouseSensitivity;
                action = {
                  type = "Keypress";
                  keys = [ "KEY_LEFTMETA" ];
                };
              }
              {
                cid = cid.switchReceivers;
                action.type = "None";
              }
            ];
          }
        ];
      };
  };
}
