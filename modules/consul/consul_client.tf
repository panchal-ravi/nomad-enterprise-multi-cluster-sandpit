resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_instance.consul_server]

  create_duration = "30s"
}

resource "consul_acl_token" "consul_client_tokens" {
  count = var.consul_client_count

  description = "Token for consul agent on consul-client-${count.index}"
  node_identities {
    node_name  = "consul-client-${count.index}"
    datacenter = var.consul_datacenter
  }
  depends_on = [time_sleep.wait_30_seconds]
}

data "consul_acl_token_secret_id" "consul_client_tokens" {
  count       = var.consul_client_count
  accessor_id = element(consul_acl_token.consul_client_tokens, count.index).id
}


resource "aws_instance" "consul_client" {
  count                  = var.consul_client_count
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.infra_aws.aws_keypair_keyname
  vpc_security_group_ids = [var.infra_aws.consul_client_security_group_id]
  subnet_id              = element(var.infra_aws.private_subnets, count.index % length(var.infra_aws.private_subnets))
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_config${var.consul_version}.hcl.tpl", {
      index        = count.index,
      server_count = var.consul_client_count,
      datacenter   = var.consul_datacenter,
      private_ip   = self.private_ip,
      gossip_key   = var.gossip_key,
      node_name    = "consul-client-${count.index}",
    })
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_acl_config.hcl.tpl", {
      agent_token = data.consul_acl_token_secret_id.consul_client_tokens[count.index].secret_id
    })
    destination = "/tmp/consul-acl.hcl"
  }

  provisioner "file" {
    content     = templatefile("${path.root}/files/consul/consul.service.tpl", {})
    destination = "/tmp/consul.service"
  }

  provisioner "file" {
    /* content     = tls_self_signed_cert.ca_cert.cert_pem */
    content     = join("\n", [var.vault.intermediate_ca, var.vault.root_ca])
    destination = "/tmp/consul-ca.crt"
  }

  provisioner "file" {
    source      = "${path.root}/files/consul/license.hclic"
    destination = "/tmp/license.hclic"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/consul.d/tls",
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo mv /tmp/consul-acl.hcl /etc/consul.d/consul-acl.hcl",
      "sudo mv /tmp/license.hclic /etc/consul.d/license.hclic",
      "sudo mv /tmp/consul-ca.crt /etc/consul.d/tls/ca.crt",
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
    Name              = "${var.deployment_id}-consul-client-${count.index}"
    consul_datacenter = "${var.consul_datacenter}"
    owner             = var.owner
  }

  connection {
    bastion_host        = var.infra_aws.bastion_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = var.infra_aws.ssh_key //file("${path.root}/generated/ssh_key") //tls_private_key.ssh.private_key_openssh

    host        = self.private_ip
    user        = "ubuntu"
    private_key = var.infra_aws.ssh_key
  }
}
