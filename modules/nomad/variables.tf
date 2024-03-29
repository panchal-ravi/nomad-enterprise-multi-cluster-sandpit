variable "deployment_id" {
  type = string
}
variable "owner" {
  type = string
}
variable "instance_type" {
  type = string
}
/*
variable "public_subnets" {
  description = "Public subnets"
  type        = list(any)
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(any)
}
variable "bastion_security_group_id" {
  type = string
}
variable "elb_security_group_id" {
  type = string
}
variable "consul_client_security_group_id" {
  type = string
}
variable "vpc_id" {
}
variable "vpc_cidr_block" {
}
variable "aws_keypair_keyname" {
}
variable "bastion_ip" {
}
variable "ssh_key" {
}
variable "elb_arn" {}
variable "elb_http_addr" {}
variable "ca_key" {}
variable "ca_cert" {}
variable "vault_ip" {}
*/
variable "consul_datacenter" { }
variable "consul_ca_crt" {}
variable "gossip_key" {}
variable "nomad_server_count" {
  type = number
}
variable "nomad_client_count" {
  type = number
}
variable "nomad_region" {
  type = string
}
variable "nomad_authoritative_region" {
  type = string
}
variable "zones" {}
variable "consul_version" {}
variable "elb_listener_port" {}

variable "node_pools" {}
variable "replication_token" {
  default = ""
}

variable "consul_auth_method_name" {}

variable "infra_aws" {
  type = object({
    vpc_id                          = string
    vpc_cidr_block                  = string
    private_subnets                 = list(string)
    public_subnets                  = list(string)
    bastion_ip                      = string
    bastion_security_group_id       = string
    elb_security_group_id           = string
    aws_keypair_keyname             = string
    ssh_key                         = string
    elb_arn                         = string
    elb_http_addr                   = string
    consul_client_security_group_id = string
    consul_server_security_group_id = string
    vault_ip                        = string
    ca_key                          = string
    ca_cert                         = string
  })
}
