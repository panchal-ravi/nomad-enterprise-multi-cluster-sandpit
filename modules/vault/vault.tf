resource "vault_jwt_auth_backend" "jwt" {
  description        = "Nomad JWT Auth method"
  path               = "jwt-nomad"
  type               = "jwt"
  jwks_url           = "${var.nomad_http_addr}/.well-known/jwks.json"
  jwt_supported_algs = ["RS256", "EdDSA"]
  jwks_ca_pem        = trimspace(var.nomad_ca_cert)
  default_role       = "nomad-workloads"
}

resource "vault_jwt_auth_backend_role" "jwt" {
  backend                 = vault_jwt_auth_backend.jwt.path
  role_name               = "nomad-workloads"
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

data "vault_policy_document" "nomad_workloads" {
  rule {
    path         = "kv/data/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt.accessor}.metadata.nomad_job_id}}/*"
    capabilities = ["read"]
  }
  rule {
    path         = "kv/data/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt.accessor}.metadata.nomad_namespace}}/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt.accessor}.metadata.nomad_job_id}}"
    capabilities = ["read"]
  }
  rule {
    path         = "kv/metadata/{{identity.entity.aliases.${vault_jwt_auth_backend.jwt.accessor}.metadata.nomad_namespace}}/*"
    capabilities = ["list"]
  }
  rule {
    path         = "kv/metadata/*"
    capabilities = ["list"]
  }

}

resource "vault_policy" "nomad_workloads" {
  name   = "nomad-workloads"
  policy = data.vault_policy_document.nomad_workloads.hcl
}


resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_v2" "secret" {
  mount               = vault_mount.kvv2.path
  name                = "default/api/config" //{nomad_namespace}/{nomad_job_id}/*
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      root_password = "secret-password",
    }
  )
}

/* resource "vault_kv_secret_v2" "api_dev" {
  mount               = vault_mount.kvv2.path
  name                = "api-dev/api/config" //{nomad_namespace}/{nomad_job_id}/*
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      root_password = "secret-password",
    }
  )
}
 */