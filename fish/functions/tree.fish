# Defined in - @ line 1
function tree --wraps='exa --tree' --description 'alias tree=exa --tree'
  exa --tree $argv;
end
