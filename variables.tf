variable "cluster_name"                   { type = string }
variable "rancher_url"                    { type = string }
variable "rancher_token"                  { type = string }
variable "domain"                         { type = string }
variable "rancher_conn_insecure" {
  type    = bool
  default = true
}

variable "namespace" {
  type    = string
  default = "gitlab"
}

variable "saml_enabled" {
  type    = bool
  default = false
}

variable "assertion_consumer_service_url" {
  type    = string
  default = ""
}

variable "idp_cert_fingerprint" {
  type    = string
  default = ""
}

variable "idp_sso_target_url" {
  type    = string
  default = ""
}

variable "issuer" {
  type    = string
  default = ""
}

variable "external_psql" {
  type    = bool
  default = false
}

variable "psql_host" {
  type    = string
  default = ""
}

variable "psql_port" {
  type    = number
  default = 5432
}

variable "psql_db" {
  type    = string
  default = "gitlabhq_production"
}

variable "psql_user" {
  type    = string
  default = "gitlab"
}

variable "psql_password" {
  type    = string
}

