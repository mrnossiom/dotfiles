{ self
, config
, lib
, ...
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
          #                  Control IDs │ reprog? │ fn key? │ mouse key? │ gesture support?
          leftMouse = 80; #         0x50 │         │         │ YES        │ 
          rightMouse = 81; #        0x51 │         │         │ YES        │ 
          middleMouse = 81; #       0x52 │ YES     │         │ YES        │ YES
          back = 83; #              0x53 │ YES     │         │ YES        │ YES
          forward = 86; #           0x56 │ YES     │         │ YES        │ YES
          switchReceivers = 215; #  0xD7 │ YES     │         │            │ YES
          mouseSensitivity = 253; # 0xFD │ YES     │         │ YES        │ YES
        };
      in
      {
        devices = [{
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
        }];
      };
  };
}

