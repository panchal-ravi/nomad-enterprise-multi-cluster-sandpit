terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


provider "consul" {
  alias          = "cluster1"
  address        = "${module.infra_aws.this.elb_http_addr}:${local.consul_elb_ports[0]}"
  scheme         = "https"
  datacenter     = local.consul_datacenters[0]
  insecure_https = true
  token          = module.consul_cluster1.consul_management_token
}

provider "consul" {
  alias          = "cluster2"
  address        = "${module.infra_aws.this.elb_http_addr}:${local.consul_elb_ports[1]}"
  scheme         = "https"
  datacenter     = local.consul_datacenters[1]
  insecure_https = true
  token          = module.consul_cluster2.consul_management_token
}


provider "vault" {
  address         = "https://${module.infra_aws.this.elb_http_addr}:8200"
  token           = module.infra_aws.this.vault_token
  skip_tls_verify = true
  tls_server_name = "demo.server.vault"
  skip_child_token = true
  # ca_cert_file = module.infra_aws.vault_ca_crt
}
