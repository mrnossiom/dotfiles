{ ... }:

let
  gap = 0;
in
{
  config = {
    services.yabai = {
      enable = true;

      config = {
        menubar_opacity = 0.5;

        mouse_follows_focus = "off";
        focus_follows_mouse = "off";

        display_arrangement_order = "default";

        window_origin_display = "default";
        window_placement = "second_child";
        window_zoom_persist = "on";

        insert_feedback_color = "0xffd75f5f";

        split_ratio = 0.5;
        split_type = "auto";
        auto_balance = "off";

        window_gap = gap;
        top_padding = gap;
        bottom_padding = gap;
        left_padding = gap;
        right_padding = gap;

        layout = "bsp";

        mouse_modifier = "fn";
        mouse_action1 = "move";
        mouse_action2 = "resize";
        mouse_drop_action = "swap";
      };
    };

    services.skhd = {
      enable = true;

      skhdConfig = '''';
    };
  };
}
