{ isDarwin
, ...
}:

{
  config = {
    assertions = [
      { assertion = !isDarwin; message = "this is a HM non-darwin config"; }
    ];

    local.flags.onlyCached = true;

    local.fragment.shell.enable = true;
  };
}

