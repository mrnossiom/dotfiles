{ ... }:

{
  config = {
    # TODO: comply to the fk*** XDG config directory specification, include updating hm aws module
    # home.sessionVariables = {
    #   AWS_SHARED_CREDENTIALS_FILE = "${config.xdg.configHome}/aws/credentials";
    #   AWS_CONFIG_FILE = "${config.xdg.configHome}/aws/config";
    # };

    programs.awscli = {
      enable = true;

      settings = {
        # Wiro Logiciel Libre
        "sso-session wirolibre-sso" = {
          sso_start_url = "https://wirolibre.awsapps.com/start/#";
          sso_region = "eu-west-3";
          sso_registration_scopes = "sso:account:access";
        };

        "profile wirolibre" = {
          sso_session = "wirolibre-sso";
          sso_account_id = 637423417480;
          sso_role_name = "AdministratorAccess";
        };
      };

      credentials = {
        # wirolibre.credential_process = "echo password";
      };
    };
  };
}
