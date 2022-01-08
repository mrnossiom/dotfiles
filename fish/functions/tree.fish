# Defined in - @ line 1
function tree --wraps="exa -TalF --no-user --no-permissions --no-time --git-ignore --git -I '.git'" --description "alias tree=exa -TalF --no-user --no-permissions --no-time --git-ignore --git -I '.git'"
    exa -TalF --no-user --no-permissions --no-time --git-ignore --git -I '.git' $argv
end
