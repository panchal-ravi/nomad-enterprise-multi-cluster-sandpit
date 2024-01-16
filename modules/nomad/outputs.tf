output "nomad_server_ips" {
  value = aws_instance.nomad_server[*].private_ip
}

output "nomad_client_ips" {
  value = aws_instance.nomad_client[*].private_ip
}
