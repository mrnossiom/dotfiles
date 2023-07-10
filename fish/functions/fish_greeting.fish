function fish_greeting
    set platform (uname)

    # If on WSL, change to home directory
    if test (pwd) = /mnt/c/Users/milom
        cd ~
    end

    echo 'Hello '(set_color brblue)(whoami)(set_color normal)' you are on '(set_color brred)$platform(set_color normal)'.'
    echo 'Current directory is '(set_color brgreen)(pwd)(set_color normal)
end
