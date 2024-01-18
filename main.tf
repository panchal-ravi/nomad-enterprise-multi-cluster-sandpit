locals {
  deployment_id           = lower("${var.deployment_name}-${random_string.suffix.result}")
  zones                   = ["z1", "z2", "z3"]
  consul_auth_method_name = "nomad-workloads"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "random_id" "gossip_key" {
  byte_length = 32
}

module "infra_aws" {
  source          = "./modules/infra_aws"
  deployment_id   = local.deployment_id
  owner           = var.owner
  vpc_cidr        = var.aws_vpc_cidr
  public_subnets  = var.aws_public_subnets
  private_subnets = var.aws_private_subnets
  instance_type   = var.aws_instance_type
}

module "vault" {
  source            = "./modules/vault"
  consul_datacenter = var.consul_datacenter
  elb_http_addr     = module.infra_aws.elb_http_addr
  depends_on        = [module.infra_aws]
}


module "consul" {
  source                    = "./modules/consul"
  instance_type             = var.aws_instance_type
  owner                     = var.owner
  deployment_id             = local.deployment_id
  vpc_id                    = module.infra_aws.vpc_id
  vpc_cidr_block            = module.infra_aws.vpc_cidr_block
  bastion_ip                = module.infra_aws.bastion_ip
  bastion_security_group_id = module.infra_aws.bastion_security_group_id
  elb_security_group_id     = module.infra_aws.elb_security_group_id
  private_subnets           = module.infra_aws.private_subnets
  public_subnets            = module.infra_aws.public_subnets
  aws_keypair_keyname       = module.infra_aws.aws_keypair_keyname
  ssh_key                   = module.infra_aws.ssh_key
  consul_server_count       = var.consul_server_count
  consul_client_count       = var.consul_client_count
  consul_datacenter         = var.consul_datacenter
  elb_arn                   = module.infra_aws.elb_arn
  elb_http_addr             = module.infra_aws.elb_http_addr
  gossip_key                = random_id.gossip_key.b64_std
  consul_server_crt         = module.vault.consul_server_crt
  consul_server_key         = module.vault.consul_server_key
  intermediate_ca           = module.vault.intermediate_ca
  root_ca                   = module.vault.root_ca
  vault_connect_ca_polcy    = module.vault.vault_connect_ca_polcy
  zones                     = local.zones
  consul_version            = var.consul_version
  depends_on                = [module.infra_aws, module.vault]
}

module "nomad_cluster1" {
  source                          = "./modules/nomad"
  instance_type                   = var.aws_instance_type
  owner                           = var.owner
  deployment_id                   = local.deployment_id
  vpc_id                          = module.infra_aws.vpc_id
  vpc_cidr_block                  = module.infra_aws.vpc_cidr_block
  bastion_ip                      = module.infra_aws.bastion_ip
  bastion_security_group_id       = module.infra_aws.bastion_security_group_id
  elb_security_group_id           = module.infra_aws.elb_security_group_id
  private_subnets                 = module.infra_aws.private_subnets
  public_subnets                  = module.infra_aws.public_subnets
  aws_keypair_keyname             = module.infra_aws.aws_keypair_keyname
  ssh_key                         = module.infra_aws.ssh_key
  nomad_server_count              = var.nomad_server_count
  nomad_client_count              = var.nomad_client_count
  nomad_region                    = "sg"
  nomad_authoritative_region      = "sg"
  gossip_key                      = random_id.gossip_key.b64_std
  elb_arn                         = module.infra_aws.elb_arn
  elb_http_addr                   = module.infra_aws.elb_http_addr
  elb_listener_port               = 8080
  zones                           = local.zones
  ca_cert                         = module.infra_aws.ca_cert
  ca_key                          = module.infra_aws.ca_key
  node_pools                      = ["dev", "sit"]
  vault_ip                        = module.infra_aws.vault_ip
  consul_client_security_group_id = module.consul.consul_client_security_group_id
  consul_datacenter               = var.consul_datacenter
  consul_ca_crt                   = module.consul.consul_ca_crt
  consul_version                  = var.consul_version
  consul_auth_method_name         = local.consul_auth_method_name
  depends_on                      = [null_resource.connect_ca, module.consul]
}

module "nomad_workload_identity" {
  source                  = "./modules/nomad_workload_identity"
  nomad_http_addr         = "https://${module.infra_aws.elb_http_addr}:8080"
  nomad_ca_cert           = module.infra_aws.ca_cert
  consul_auth_method_name = local.consul_auth_method_name
}

module "nomad_cluster2" {
  source                          = "./modules/nomad"
  instance_type                   = var.aws_instance_type
  owner                           = var.owner
  deployment_id                   = local.deployment_id
  vpc_id                          = module.infra_aws.vpc_id
  vpc_cidr_block                  = module.infra_aws.vpc_cidr_block
  bastion_ip                      = module.infra_aws.bastion_ip
  bastion_security_group_id       = module.infra_aws.bastion_security_group_id
  elb_security_group_id           = module.infra_aws.elb_security_group_id
  private_subnets                 = module.infra_aws.private_subnets
  public_subnets                  = module.infra_aws.public_subnets
  aws_keypair_keyname             = module.infra_aws.aws_keypair_keyname
  ssh_key                         = module.infra_aws.ssh_key
  nomad_server_count              = var.nomad_server_count
  nomad_client_count              = var.nomad_client_count
  nomad_region                    = "my"
  nomad_authoritative_region      = "sg"
  gossip_key                      = random_id.gossip_key.b64_std
  elb_arn                         = module.infra_aws.elb_arn
  elb_http_addr                   = module.infra_aws.elb_http_addr
  elb_listener_port               = 9090
  zones                           = local.zones
  ca_cert                         = module.infra_aws.ca_cert
  ca_key                          = module.infra_aws.ca_key
  node_pools                      = ["dev", "sit"]
  vault_ip                        = module.infra_aws.vault_ip
  consul_client_security_group_id = module.consul.consul_client_security_group_id
  consul_datacenter               = var.consul_datacenter
  consul_ca_crt                   = module.consul.consul_ca_crt
  consul_version                  = var.consul_version
  consul_auth_method_name         = local.consul_auth_method_name
  depends_on                      = [null_resource.connect_ca, module.consul]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [module.consul]

  create_duration = "30s"
}

resource "null_resource" "connect_ca" {
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<-EOD
      curl -s -k https://${module.infra_aws.elb_http_addr}:8501/v1/connect/ca/roots | jq '.Roots[] |(.IntermediateCerts[])+(.RootCert)' -r > ${path.root}/generated/connect_ca.crt
      EOD
  }
  depends_on = [time_sleep.wait_30_seconds]
}
