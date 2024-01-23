path "/sys/mounts/connect_root_${datacenter}" {
  capabilities = [ "read" ]
}

path "/sys/mounts/connect_${datacenter}_inter" {
  capabilities = [ "read" ]
}

path "/sys/mounts/connect_${datacenter}_inter/tune" {
  capabilities = [ "update" ]
}

path "/connect_root_${datacenter}/" {
  capabilities = [ "read" ]
}

path "/connect_root_${datacenter}/root/sign-self-issued" {
  capabilities = [ "update", "sudo" ]
}

path "/connect_root_${datacenter}/root/generate/internal" {
  capabilities = [ "update", "sudo" ]
}

path "/connect_root_${datacenter}/root/sign-intermediate" {
  capabilities = [ "update" ]
}

path "/connect_${datacenter}_inter/*" {
  capabilities = [ "create", "read", "update", "delete", "list" ]
}

path "auth/token/renew-self" {
  capabilities = [ "update" ]
}

path "auth/token/lookup-self" {
  capabilities = [ "read" ]
}
