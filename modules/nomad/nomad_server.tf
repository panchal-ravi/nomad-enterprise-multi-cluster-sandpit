data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-consul-nomad-enterprise*"]
  }
}
/*
resource "consul_acl_policy" "nomad_server_agent" {
  count = var.nomad_server_count
  name  = "nomad-server-agent-${count.index}"
  rules = file("${path.root}/files/consul/consul_acl_policy_for_nomad_server.hcl")
}

resource "consul_acl_token" "nomad_server" {
  count = var.nomad_server_count

  description = "Token for consul agent on nomad-server-${count.index}"
  node_identities {
    node_name  = "nomad-server-${count.index}"
    datacenter = var.consul_datacenter
  }
  policies = ["${consul_acl_policy.nomad_server_agent[count.index].name}"]
}

data "consul_acl_token_secret_id" "nomad_server" {
  count       = var.nomad_server_count
  accessor_id = element(consul_acl_token.nomad_server, count.index).id
}
*/

resource "aws_instance" "nomad_server" {
  count                  = var.nomad_server_count
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.aws_keypair_keyname
  vpc_security_group_ids = [module.nomad_server_sg.security_group_id]
  # vpc_security_group_ids = [module.nomad_server_sg.security_group_id, var.consul_client_security_group_id]
  subnet_id            = element(var.private_subnets, count.index % length(var.private_subnets))
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/nomad/nomad_server_config.hcl.tpl", {
      index                      = count.index,
      server_count               = var.nomad_server_count,
      nomad_region               = var.nomad_region,
      nomad_authoritative_region = var.nomad_authoritative_region,
      private_ip                 = self.private_ip,
      gossip_key                 = var.gossip_key,
      node_name                  = "nomad-server-${count.index}",
      zone                       = var.zones[count.index % length(var.zones)]
      nomad_datacenter           = var.consul_datacenter,
      replication_token          = trimspace(file("${path.root}/generated/nomad_management_token"))
      # consul_token     = data.consul_acl_token_secret_id.nomad_server[count.index].secret_id,
    })
    destination = "/tmp/nomad.hcl"
  }

  /*
  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_config${var.consul_version}.hcl.tpl", {
      index      = count.index,
      datacenter = var.consul_datacenter,
      private_ip = self.private_ip,
      gossip_key = var.gossip_key,
      node_name  = "nomad-server-${count.index}",
    })
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_acl_config.hcl.tpl", {
      agent_token = data.consul_acl_token_secret_id.nomad_server[count.index].secret_id
    })
    destination = "/tmp/consul_acl.hcl"
  }

  provisioner "file" {
    source      = "${path.root}/generated/connect_ca.crt"
    destination = "/tmp/connect_ca.crt"
  }

    provisioner "file" {
    content     = templatefile("${path.root}/files/consul/consul.service.tpl", {})
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    content     = var.consul_ca_crt
    destination = "/tmp/consul_ca.crt"
  }

  provisioner "file" {
    source      = "${path.root}/files/consul/license.hclic"
    destination = "/tmp/consul_license.hclic"
  }
  */

  provisioner "file" {
    content = templatefile("${path.root}/files/nomad/nomad.service.tpl", {
      agent_type = "server",
    })
    destination = "/tmp/nomad.service"
  }

  provisioner "file" {
    source      = "${path.root}/files/nomad/license.hclic"
    destination = "/tmp/nomad_license.hclic"
  }


  provisioner "file" {
    content     = var.ca_cert //tls_self_signed_cert.ca_cert.cert_pem
    destination = "/tmp/nomad_ca.pem"
  }

  provisioner "file" {
    content     = tls_locally_signed_cert.nomad_server_signed_cert.cert_pem
    destination = "/tmp/nomad_cert.pem"
  }

  provisioner "file" {
    content     = tls_private_key.nomad_server_private_key.private_key_pem
    destination = "/tmp/nomad_key.pem"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/nomad.d/tls",
      "sudo mv /tmp/nomad.hcl /etc/nomad.d/nomad.hcl",
      "sudo mv /tmp/nomad_license.hclic /etc/nomad.d/license.hclic",
      "sudo mv /tmp/nomad_ca.pem /etc/nomad.d/tls/ca.crt",
      "sudo mv /tmp/nomad_key.pem /etc/nomad.d/tls/nomad.key",
      "sudo mv /tmp/nomad_cert.pem /etc/nomad.d/tls/nomad.crt",
      "sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo chown -R nomad:nomad /etc/nomad.d",

      /*
      "sudo mkdir -p /etc/consul.d/tls",
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo mv /tmp/consul_license.hclic /etc/consul.d/license.hclic",
      "sudo mv /tmp/consul_acl.hcl /etc/consul.d/consul_acl.hcl",
      "sudo mv /tmp/consul_ca.crt /etc/consul.d/tls/ca.crt",
      "sudo mv /tmp/connect_ca.crt /etc/consul.d/tls/connect_ca.crt",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo chown -R consul:consul /etc/consul.d",
      */

      /* "sudo chmod 400 /home/ubuntu/ssh_key", */

      "sudo systemctl daemon-reload",
      # "sudo systemctl start consul",
      # "sleep 5",
      "sudo systemctl start nomad",
      "sleep 5",
    ]
  }

  tags = {
    Name       = "${var.deployment_id}-nomad-server-${var.nomad_region}-${count.index}"
    nomad_role = "server_${var.nomad_region}"
    owner      = var.owner
  }

  connection {
    bastion_host        = var.bastion_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = var.ssh_key //file("${path.root}/generated/ssh_key") //tls_private_key.ssh.private_key_openssh

    host        = self.private_ip
    user        = "ubuntu"
    private_key = var.ssh_key
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.owner
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.owner
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
  inline_policy {
    name   = "${var.deployment_id}-metadata-access"
    policy = data.aws_iam_policy_document.metadata_access.json
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metadata_access" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
}
