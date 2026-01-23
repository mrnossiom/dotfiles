{
  isDarwin,
  ...
}:

{
  config = {
    assertions = [
      {
        assertion = !isDarwin;
        message = "this is a HM non-darwin config";
      }
    ];

    local.fragment.shell.enable = true;
  };
}
