terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "1.22.2"
    }
  }
}

provider "rancher2" {
  api_url    = var.rancher_url
  token_key  = var.rancher_token
  insecure   = var.rancher_conn_insecure
}

variable module_depends_on {
  type    = any
  default = []
}

data "rancher2_cluster" "kube_cluster" {
  depends_on = [ var.module_depends_on ]
  name       = var.cluster_name
}

resource "rancher2_catalog_v2" "gitlab" {
  cluster_id  = data.rancher2_cluster.kube_cluster.id
  name        = "gitlab"
  url         = "https://charts.gitlab.io/"
}

resource "rancher2_project" "gitlab" {
  name        = "gitlab"
  cluster_id  = data.rancher2_cluster.kube_cluster.id
}

resource "rancher2_namespace" "gitlab" {
  name        = var.namespace
  project_id  = rancher2_project.gitlab.id
  description = "namespace for gitlab"
}

resource "rancher2_secret_v2" "psql_password" {
  depends_on = [ rancher2_namespace.gitlab ]    
  count      = var.external_psql ? 1 : 0
  cluster_id = data.rancher2_cluster.kube_cluster.id
  name       = "gitlab-postgres"
  namespace  = var.namespace
  data = {
    psql-password = var.psql_password
  }
}

resource "rancher2_app_v2" "gitlab" {
  depends_on = [ rancher2_catalog_v2.gitlab,
                 rancher2_secret_v2.psql_password ]
  lifecycle {
    ignore_changes  = all 
  }

  cluster_id = data.rancher2_cluster.kube_cluster.id
  name       = "gitlab"
  repo_name  = "gitlab"
  chart_name = "gitlab"
  namespace  = var.namespace
  values     = format(file("${path.module}/etc/gitlab-values.yaml"),
                  var.domain,
                  var.saml_enabled  ? local.saml_config : "",
                  var.external_psql ? format(local.psql_config_tmpl,
                        var.psql_host, var.psql_port, var.psql_db, var.psql_user)
                    : "",
                  var.external_psql ? "false" : "true")
}

resource "rancher2_secret_v2" "saml_provider" {
  depends_on = [ rancher2_namespace.gitlab ]
  count      = var.saml_enabled ? 1 : 0

  cluster_id = data.rancher2_cluster.kube_cluster.id
  name       = "saml-provider"
  namespace  = "gitlab"
  type       = "Opaque"

  data = {
    provider = format(local.saml_secret_tmpl,
      var.assertion_consumer_service_url,
      var.idp_cert_fingerprint,
      var.idp_sso_target_url,
      var.issuer)
  }
}

