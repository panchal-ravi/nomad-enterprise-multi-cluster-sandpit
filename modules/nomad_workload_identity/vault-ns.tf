locals {
  ns = "api-dev"
}

resource "vault_namespace" "ns" {
  path = local.ns
}

resource "vault_jwt_auth_backend" "jwt_ns" {
  description        = "Nomad JWT Auth method for api-dev namespace"
  path               = "jwt-nomad"
  namespace          = vault_namespace.ns.path
  type               = "jwt"
  jwks_url           = "${var.nomad_http_addr}/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]
  jwks_ca_pem        = trimspace(var.nomad_ca_cert)
  default_role       = "nomad-workloads"
}

resource "vault_jwt_auth_backend_role" "jwt_ns" {
  backend                 = vault_jwt_auth_backend.jwt_ns.path
  role_name               = "nomad-workloads"
  namespace               = vault_namespace.ns.path
  role_type               = "jwt"
  bound_audiences         = ["nomad.io"]
  user_claim              = "/nomad_job_id"
  user_claim_json_pointer = true

  claim_mappings = {
    nomad_namespace = "nomad_namespace",
    nomad_job_id    = "nomad_job_id",
    nomad_task      = "nomad_task"
  }

  token_type             = "service"
  token_policies         = ["nomad-workloads"]
  token_period           = 1800 // 30m
  token_explicit_max_ttl = 0
}

data "vault_policy_document" "nomad_workloads_ns" {
  rule {
    path         = "kv/data/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt_ns.accessor}.metadata.nomad_job_id}}/*"
    capabilities = ["read"]
  }
  rule {
    path         = "kv/data/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt_ns.accessor}.metadata.nomad_job_id}}"
    capabilities = ["read"]
  }
  rule {
    path         = "kv/metadata/*"
    capabilities = ["list"]
  }

}

resource "vault_policy" "nomad_workloads_ns" {
  name      = "nomad-workloads"
  namespace = vault_namespace.ns.path
  policy    = data.vault_policy_document.nomad_workloads_ns.hcl
}


resource "vault_mount" "kvv2_ns" {
  path        = "kv"
  type        = "kv"
  namespace   = vault_namespace.ns.path
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount for api-dev namespace"
}

resource "vault_kv_secret_v2" "kvv2_ns" {
  mount               = vault_mount.kvv2_ns.path
  namespace           = vault_namespace.ns.path
  name                = "api/config" // {nomad_job_id}/*
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      root_password = "secret-password-ns",
    }
  )
}