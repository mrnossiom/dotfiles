# Personal DotFiles of @MrNossiom

## Notes

### Cli

-   `timedatectl set-local-rtc 1`: (Dual boot) change time mode for Linux. This is needed to prevent time drift when using Windows.
-   `set LD_LIBRARY_PATH ''`: Disables brew packages preloading and prevent extremely annoying behaviour on Linux systems.

-   `set -Ua dirnext $next && set -Ua dirprev $previous && set -U __fish_cd_direction prev`: So you can use `cdh` across sessions.

### Firefox

-   `layout.css.system-ui.enabled` to `false`: I prefer to use the website preferred font

### XInput

-   `xinput enable/disable 13`: for touch-screen
