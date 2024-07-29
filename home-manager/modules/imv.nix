{ ... }:

{
  config = {
    programs.imv = {
      enable = true;
      settings = {
        aliases = {
          echo_current_file = "exec echo $imv_current_file";
        };
        binds = {
          # Kinda like Lightroom© quick selection feature
          b = "echo_current_file";
        };
      };
    };
  };
}
