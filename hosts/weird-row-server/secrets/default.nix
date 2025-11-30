keys:
let
  inherit (keys) servers users;
  deploy = servers ++ users;
in
{
  # Defines `PDS_JWT_SECRET`, `PDS_ADMIN_PASSWORD`, `PDS_PLC_ROTATION_KEY_K256_PRIVATE_KEY_HEX`, `PDS_EMAIL_SMTP_URL`, `PDS_EMAIL_FROM_ADDRESS`.
  "pds-env.age".publicKeys = deploy;
  # Defines `LLDAP_JWT_SECRET`, `LLDAP_KEY_SEED`.
  "lldap-env.age".publicKeys = deploy;
  "lldap-user-pass.age".publicKeys = deploy;
  "headscale-oidc-secret.age".publicKeys = deploy;
  "grafana-oidc-secret.age".publicKeys = deploy;
  "authelia-jwt-secret.age".publicKeys = deploy;
  "authelia-issuer-private-key.age".publicKeys = deploy;
  "authelia-storage-key.age".publicKeys = deploy;
  "authelia-ldap-password.age".publicKeys = deploy;
  "authelia-smtp-password.age".publicKeys = deploy;
  "tuwunel-registration-tokens.age".publicKeys = deploy;
  # Defines `SMTP_PASSWORD`
  "vaultwarden-env.age".publicKeys = deploy;
  "miniflux-oidc-secret.age".publicKeys = deploy;
  # Defines `HYPIXEL_API_KEY`, `PROFILE_UUID`
  "hypixel-bank-tracker-main.age".publicKeys = deploy;
  "hypixel-bank-tracker-banana.age".publicKeys = deploy;
  "caddy-env.age".publicKeys = deploy;
}
