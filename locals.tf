locals {
  saml_secret_tmpl = <<EOT
name: 'saml'
label: 'SSO login'
args:
  assertion_consumer_service_url: '%s'
  idp_cert_fingerprint: '%s'
  idp_sso_target_url: '%s'
  issuer: '%s'
  name_identifier_format: 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'
EOT
  saml_config = <<EOT
    omniauth:
      enabled: true
      autoSignInWithProvider:
      syncProfileFromProvider: []
      syncProfileAttributes: ['email']
      allowSingleSignOn: ['saml']
      blockAutoCreatedUsers: true
      autoLinkLdapUser: false
      autoLinkSamlUser: true
      autoLinkUser: []
      externalProviders: []
      allowBypassTwoFactor: []
      providers:
        - secret: saml-provider
          key: provider
EOT
  psql_config_tmpl = <<EOT
  psql:
    host: %s
    port: %d
    database: %s
    username: %s
    password:
      useSecret: true
      secret: gitlab-postgres
      key: psql-password
EOT
}
