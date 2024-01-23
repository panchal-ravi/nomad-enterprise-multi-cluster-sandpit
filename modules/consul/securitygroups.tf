/*
module "consul_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-consul-server"
  description = "Consul Security Group for server agents"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8300
      to_port     = 8302
      protocol    = "tcp"
      description = "consul rpc/lan-serf/wan-serf"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 8500
      to_port     = 8502
      protocol    = "tcp"
      description = "consul http/https/grpc"
      cidr_blocks = var.vpc_cidr_block
    }
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Bastion to SSH"
      source_security_group_id = var.bastion_security_group_id
    },
    {
      from_port                = 8500
      to_port                  = 8501
      protocol                 = "tcp"
      description              = "LB to Consul HTTP/HTTPS API"
      source_security_group_id = var.elb_security_group_id
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}


module "consul_client_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-consul-client"
  description = "Consul Security Group for client agents"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8300
      to_port     = 8302
      protocol    = "tcp"
      description = "consul rpc/lan-serf/wan-serf"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 8500
      to_port     = 8502
      protocol    = "tcp"
      description = "consul http/https/grpc"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 19000
      to_port     = 32000
      protocol    = "tcp"
      description = "consul connect ports"
      cidr_blocks = var.vpc_cidr_block
    },
    
  ]
  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Bastion to SSH"
      source_security_group_id = var.bastion_security_group_id
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
*/