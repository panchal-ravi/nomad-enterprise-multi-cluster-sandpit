
variable "deployment_name" {
  type = string
}

variable "owner" {
  description = "Resource owner identified using an email address"
  type        = string
  default     = "rp"
}

variable "ttl" {
  description = "Resource TTL (time-to-live)"
  type        = number
  default     = 48
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR"
  type        = string
  default     = "192.168.0.0/16"
}

variable "aws_private_subnets" {
  description = "AWS private subnets"
  type        = list(any)
  default     = ["192.168.20.0/24", "192.168.21.0/24"]
}

variable "aws_public_subnets" {
  description = "AWS public subnets"
  type        = list(any)
  default     = ["192.168.10.0/24", "192.168.11.0/24"]
}

variable "aws_instance_type" {
  description = "AWS instance type"
  type        = string
  default     = "t3.micro"
}
variable "nomad_server_count" {
  type = number
}
variable "nomad_region" {
  type = string
  default = ""
}
variable "nomad_client_count" {
  type = number
}
/*
variable "consul_datacenter" {
  type = string
}
variable "consul_server_count" {
  type = string
}
variable "consul_client_count" {
  type = number
}
variable "consul_version" {
  type = string
  default = ""
}
*/