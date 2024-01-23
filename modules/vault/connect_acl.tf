resource "vault_policy" "connect_ca" {
  for_each = var.consul_datacenters
  name = "connect-ca-${each.key}"

  policy = templatefile("${path.root}/files/vault/vault_policy_connect_ca.hcl.tpl", {
    datacenter = each.key
  })
}
