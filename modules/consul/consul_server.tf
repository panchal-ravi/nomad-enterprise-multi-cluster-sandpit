data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-consul-nomad-enterprise*"]
  }
}

resource "random_uuid" "management_token" {
}

resource "vault_token" "connect_ca" {
  policies  = [var.vault.vault_connect_ca_polcy]
  renewable = true
  no_parent = true
  ttl       = "720h"
  metadata = {
    purpose = "consul-service-account"
  }
}


resource "aws_instance" "consul_server" {
  count                  = var.consul_server_count
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.infra_aws.aws_keypair_keyname
  vpc_security_group_ids = [var.infra_aws.consul_server_security_group_id]
  subnet_id              = element(var.infra_aws.private_subnets, count.index % length(var.infra_aws.private_subnets))
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_server_config.hcl.tpl", {
      index                  = count.index,
      server_count           = var.consul_server_count,
      datacenter             = var.consul_datacenter,
      private_ip             = self.private_ip,
      gossip_key             = var.gossip_key,
      vault_connect_ca_token = vault_token.connect_ca.client_token,
      elb_http_addr          = var.infra_aws.elb_http_addr,
      zone                   = var.zones[count.index % length(var.zones)]
    })
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_server_acl_config.hcl.tpl", {
      management_token = random_uuid.management_token.id
    })
    destination = "/tmp/consul-acl.hcl"
  }

  provisioner "file" {
    content     = templatefile("${path.root}/files/consul/consul.service.tpl", {})
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    source      = "${path.root}/files/consul/license.hclic"
    destination = "/tmp/license.hclic"
  }

  provisioner "file" {
    /* content     = tls_self_signed_cert.ca_cert.cert_pem */
    content     = join("\n", [var.vault.intermediate_ca, var.vault.root_ca])
    destination = "/tmp/consul-ca.crt"
  }

  provisioner "file" {
    /* content     = tls_locally_signed_cert.consul_server_signed_cert.cert_pem */
    content     = var.vault.consul_server_crt
    destination = "/tmp/consul.crt"
  }

  provisioner "file" {
    /* content     = tls_private_key.consul_server_private_key.private_key_pem */
    content     = var.vault.consul_server_key
    destination = "/tmp/consul.key"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/consul.d/tls",
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo mv /tmp/license.hclic /etc/consul.d/license.hclic",
      "sudo mv /tmp/consul-acl.hcl /etc/consul.d/consul-acl.hcl",
      "sudo mv /tmp/consul-ca.crt /etc/consul.d/tls/ca.crt",
      "sudo mv /tmp/consul.key /etc/consul.d/tls/consul.key",
      "sudo mv /tmp/consul.crt /etc/consul.d/tls/consul.crt",
      "sudo mv /tmp/consul.service /etc/systemd/system/consul.service",
      "sudo chown -R consul:consul /etc/consul.d",
      "sudo usermod -aG docker $USER",

      "sudo chmod 400 /home/ubuntu/ssh_key",

      "sudo systemctl daemon-reload",
      "sudo systemctl start consul",
      "sleep 10",
    ]
  }

  tags = {
    Name              = "${var.deployment_id}-consul-server-${count.index}"
    consul_datacenter = "${var.consul_datacenter}"
    owner             = var.owner
  }

  connection {
    bastion_host        = var.infra_aws.bastion_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = var.infra_aws.ssh_key

    host        = self.private_ip
    user        = "ubuntu"
    private_key = var.infra_aws.ssh_key
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
