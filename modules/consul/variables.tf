variable "deployment_id" {
  type = string
}
variable "public_subnets" {
  description = "Public subnets"
  type        = list(any)
}
variable "private_subnets" {
  description = "Private subnets"
  type        = list(any)
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
variable "gossip_key" {}
variable "elb_arn" {}
variable "consul_server_key" {}

variable "consul_server_crt" {}

variable "intermediate_ca" {}

variable "root_ca" {}
variable "elb_http_addr" {}
variable "vault_connect_ca_polcy" {}
variable "zones" {}
variable "consul_version" {}
