output "consul_server_ips" {
  value = aws_instance.consul_server[*].private_ip
}

output "consul_client_ips" {
  value = aws_instance.consul_client[*].private_ip
}


output "consul_client_security_group_id" {
  value = module.consul_client_sg.security_group_id
}

output "consul_ca_crt" {
  value = join("\n", [var.intermediate_ca, var.root_ca])
}

output "consul_management_token" {
  value = random_uuid.management_token.id
}