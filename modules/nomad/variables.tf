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
variable "bastion_security_group_id" {
  type = string
}
variable "elb_security_group_id" {
  type = string
}
# variable "consul_client_security_group_id" {
#   type = string
# }
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
variable "consul_datacenter" { default = "" }
# variable "consul_ca_crt" {}
variable "gossip_key" {}
variable "elb_arn" {}
variable "elb_http_addr" {}
variable "zones" {}
# variable "consul_version" {}
variable "elb_listener_port" {}
variable "ca_key" {}
variable "ca_cert" {}
variable "node_pools" {}
variable "replication_token" {
  default = ""
}
variable "vault_ip" {}