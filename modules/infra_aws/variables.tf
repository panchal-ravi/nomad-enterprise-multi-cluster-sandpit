variable "region" {
  default = "ap-south-1"
}

variable "deployment_id" {
  type = string
}

variable "vpc_cidr" {
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