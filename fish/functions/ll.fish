# Defined in - @ line 1
function ll --wraps='exa -lha --git' --description 'alias ll=exa -lha --git'
  exa -lha --git $argv;
end
