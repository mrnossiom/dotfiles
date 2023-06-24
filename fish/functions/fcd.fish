function fcd -d "Fuzzy find: let you select a folder that matches"
    set -f output (ff $argv)
    test -z $output
    or cd $output
end
