function sd -a name dir -d "Return the first subdirectory of directory that matches name"
    test -z "$name"
    and return 1

    if test "$dir" = dev
        set -f dir ~/Documents/Developement/
    end

    fd -td $name $dir | head -n1
end
