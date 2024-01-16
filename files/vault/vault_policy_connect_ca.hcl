path "/sys/mounts/connect_root" {
  capabilities = [ "read" ]
}

path "/sys/mounts/connect_dc1_inter" {
  capabilities = [ "read" ]
}

path "/sys/mounts/connect_dc1_inter/tune" {
  capabilities = [ "update" ]
}

path "/connect_root/" {
  capabilities = [ "read" ]
}

path "/connect_root/root/sign-self-issued" {
  capabilities = [ "update", "sudo" ]
}

path "/connect_root/root/generate/internal" {
  capabilities = [ "update", "sudo" ]
}

path "/connect_root/root/sign-intermediate" {
  capabilities = [ "update" ]
}

path "/connect_dc1_inter/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}
