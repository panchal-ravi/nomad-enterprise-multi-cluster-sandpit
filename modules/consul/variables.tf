variable "deployment_id" {
  type = string
}
variable "owner" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "consul_server_count" {
  type = number
}
variable "consul_client_count" {
  type = number
}
variable "consul_datacenter" {
  type = string
}

variable "gossip_key" {}
variable "zones" {}
variable "consul_version" {}
variable "elb_listener_port" {}


/*
variable "public_subnets" {
  description = "Public subnets"
  type        = list(any)
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(any)
}
variable "elb_security_group_id" {
  type = string
}
variable "bastion_security_group_id" {
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
variable "consul_server_security_group_id" {}
variable "consul_client_security_group_id" {}
variable "consul_server_key" {}
variable "consul_server_crt" {}
variable "intermediate_ca" {}
variable "root_ca" {}
variable "vault_connect_ca_polcy" {}
*/

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
  })
}

variable "vault" {
  type = object({
    consul_server_crt      = string
    consul_server_key      = string
    intermediate_ca        = string
    root_ca                = string
    vault_connect_ca_polcy = string
  })
}
