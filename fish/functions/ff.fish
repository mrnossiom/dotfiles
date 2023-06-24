function ff -d "Fuzzy find: let you select a folder that matches"
    set -f name "$argv[1]"
    set -f dir "$argv[2]"

    if test -z $name
        echo "Error: No name specified" 1>&2
        echo "Usage: fzcd [name] <directory>" 1>&2
        return 1
    end

    # No directory specified
    test -z $dir
    and set -f dir $PROJECTS

    set -f dir (fd -td $name $dir | fzf)

    if test -z "$dir"
        echo "No directory found" 1>&2
        return 1
    end

    echo $dir
end
