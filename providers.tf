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
  address        = "${module.infra_aws.elb_http_addr}:8501"
  scheme         = "https"
  datacenter     = var.consul_datacenter
  insecure_https = true
  token          = module.consul.consul_management_token
}


provider "vault" {
  address         = "https://${module.infra_aws.elb_http_addr}:8200"
  token           = module.infra_aws.vault_token
  skip_tls_verify = true
  tls_server_name = "demo.server.vault"
  # ca_cert_file = module.infra_aws.vault_ca_crt
}
