variable "owner" {
  type        = string
  description = "Owner tag to which the artifacts belong"
  default     = "rp"
}
variable "nomad_version" {
  type = string
  description = "Three digit Nomad version to work with"
  default = "1.5.5+ent"
}
variable "aws_region" {
  type        = string
  description = "AWS Region for image"
  default     = "ap-southeast-1"
}
variable "aws_instance_type" {
  type        = string
  description = "Instance Type for Image"
  default     = "t2.small"
}
