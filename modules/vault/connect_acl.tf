resource "vault_policy" "connect_ca" {
  name = "connect-ca"

  policy = file("${path.root}/files/vault/vault_policy_connect_ca.hcl")
}
