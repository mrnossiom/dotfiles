# Personal Dotfiles of @MrNossiom

## Structure

```
├ dotbot/ Submodule that powers this config
├ fish/ fish related functions and config
├ scripts/ scripts that powers other functionalities
├ yarn/ global yarn packages and configuration
├ Brewfile brew dependencies
├ crates.toml global cargo crates
├ czrc.json commitizen configuration
├ gitconfig git configuration
├ install.config.yml dotbot configuration
├ install.sh setup script
├ prettierrc.json prettier configuration
├ profile.sh bash or zsh configuration
├ ssh_config ssh configuration
└ starship.toml starship prompt configuration
```

## Notes

### Cli

-   `timedatectl set-local-rtc 1`: (Dual boot) change time mode for Linux
-   `set LD_LIBRARY_PATH ''`: Disables brew packages preloading and do shit...

### Firefox

-   `layout.css.system-ui.enabled` to `false`: I prefer to use the website preferred font
