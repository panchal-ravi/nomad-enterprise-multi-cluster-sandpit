/*
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "bastion_security_group_id" {
  value = module.bastion_sg.security_group_id
}

output "elb_security_group_id" {
  value = module.elb_sg.security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "aws_keypair_keyname" {
  value = aws_key_pair.this.key_name
}

output "ssh_key" {
  value = tls_private_key.ssh.private_key_openssh
}

output "elb_arn" {
  value = aws_lb.http_lb.arn
}

output "elb_http_addr" {
  value = aws_lb.http_lb.dns_name
}
output "vault_ca_crt" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "ca_key" {
  value = tls_private_key.ca_private_key.private_key_pem
}

output "ca_cert" {
  value = tls_self_signed_cert.ca_cert.cert_pem
}

output "vault_token" {
  value = random_string.vault_token.result
}

output "vault_ip" {
  value = aws_instance.vault.private_ip
}

output "consul_server_security_group_id" {
  value = module.consul_server_sg.security_group_id
}
output "consul_client_security_group_id" {
  value = module.consul_client_sg.security_group_id
}
*/

output "this" {
  value = {
    vpc_id                          = module.vpc.vpc_id,
    vpc_cidr_block                  = module.vpc.vpc_cidr_block,
    private_subnets                 = module.vpc.private_subnets,
    public_subnets                  = module.vpc.public_subnets,
    bastion_ip                      = aws_instance.bastion.public_ip,
    bastion_security_group_id       = module.bastion_sg.security_group_id,
    elb_security_group_id           = module.elb_sg.security_group_id,
    aws_keypair_keyname             = aws_key_pair.this.key_name,
    ssh_key                         = tls_private_key.ssh.private_key_openssh,
    elb_arn                         = aws_lb.http_lb.arn,
    elb_http_addr                   = aws_lb.http_lb.dns_name,
    consul_client_security_group_id = module.consul_client_sg.security_group_id,
    consul_server_security_group_id = module.consul_server_sg.security_group_id,
    vault_ip                        = aws_instance.vault.private_ip,
    vault_token                     = random_string.vault_token.result,
    ca_key                          = tls_private_key.ca_private_key.private_key_pem,
    ca_cert                         = tls_self_signed_cert.ca_cert.cert_pem,
  }
}
