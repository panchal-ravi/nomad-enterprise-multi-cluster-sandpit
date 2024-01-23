module "nomad_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-nomad-server"
  description = "Nomad Security Group for server agents"
  vpc_id      = var.infra_aws.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 4646
      to_port     = 4648
      protocol    = "tcp"
      description = "nomad http/rpc/serf"
      cidr_blocks = var.infra_aws.vpc_cidr_block
    }
  ]

  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Bastion to SSH"
      source_security_group_id = var.infra_aws.bastion_security_group_id
    },
    {
      from_port                = 4646
      to_port                  = 4646
      protocol                 = "tcp"
      description              = "LB to Nomad API"
      source_security_group_id = var.infra_aws.elb_security_group_id
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "nomad_client_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-nomad-client"
  description = "Nomad Security Group for client agente"
  vpc_id      = var.infra_aws.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 4646
      to_port     = 4647
      protocol    = "tcp"
      description = "nomad http/rpc for client agents"
      cidr_blocks = var.infra_aws.vpc_cidr_block
    },
    {
      from_port   = 20000
      to_port     = 32000
      protocol    = "tcp"
      description = "dynamic ports assigned by nomad tasks"
      cidr_blocks = var.infra_aws.vpc_cidr_block
    },
    {
      from_port   = 8080
      to_port     = 9100
      protocol    = "tcp"
      description = "static ports assigned for nomad tasks"
      cidr_blocks = var.infra_aws.vpc_cidr_block
    }
  ]


  ingress_with_source_security_group_id = [
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      description              = "Bastion to SSH"
      source_security_group_id = var.infra_aws.bastion_security_group_id
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
