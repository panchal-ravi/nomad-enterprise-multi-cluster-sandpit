module "bastion_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "${var.deployment_id}-bastion"
  description = "bastion inbound sg"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["ssh-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

module "elb_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-elb"
  description = "Allow web traffic from internet"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8200
      to_port     = 8200
      protocol    = "tcp"
      description = "vault http"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "nomad https"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      description = "nomad https"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8501
      to_port     = 8501
      protocol    = "tcp"
      description = "consul https"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
}

module "vault_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.deployment_id}-vault"
  description = "vault inbound"
  vpc_id      = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 8200
      to_port     = 8201
      protocol    = "tcp"
      description = "vault http/cluster"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
  ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = module.bastion_sg.security_group_id
    },
    {
      from_port                = 8200
      to_port                  = 8200
      protocol                 = "tcp"
      description              = "LB to Vault API"
      source_security_group_id = module.elb_sg.security_group_id
    }
  ]
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
