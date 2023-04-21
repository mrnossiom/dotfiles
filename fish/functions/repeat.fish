function repeat -a command
    set -l command (string join ' ' $argv)

    while true
        # Prompt for package name
        read -P "\$ "(set_color brgreen)"$command "(set_color normal) package_name

        # Check if nothing was entered to quit
        test "$package_name" = "" && break

        # Run 'apt info' command with the provided package name
        fish -c "$command $package_name"
    end
end
