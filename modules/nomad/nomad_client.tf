/*
resource "consul_acl_policy" "nomad_client_agent" {
  count = var.nomad_client_count
  name  = "nomad-client-agent-${count.index}"
  rules = file("${path.root}/files/consul/consul_acl_policy_for_nomad_client.hcl")
}

resource "consul_acl_token" "nomad_client" {
  count = var.nomad_client_count

  description = "Token for consul agent on nomad-client-${count.index}"
  node_identities {
    node_name  = "nomad-client-${count.index}"
    datacenter = var.consul_datacenter
  }
  policies = ["${consul_acl_policy.nomad_client_agent[count.index].name}"]
}

data "consul_acl_token_secret_id" "nomad_client" {
  count       = var.nomad_client_count
  accessor_id = element(consul_acl_token.nomad_client, count.index).id
}
*/

resource "aws_instance" "nomad_client" {
  count                  = var.nomad_client_count
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.aws_keypair_keyname
  vpc_security_group_ids = [module.nomad_client_sg.security_group_id]
  subnet_id              = element(var.private_subnets, count.index % length(var.private_subnets))
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  # vpc_security_group_ids = [module.nomad_client_sg.security_group_id, var.consul_client_security_group_id]

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/nomad/nomad_client_config.hcl.tpl", {
      index            = count.index,
      nomad_region     = var.nomad_region,
      private_ip       = self.private_ip,
      nomad_datacenter = "dc1",
      node_name        = "nomad-client-${count.index}",
      node_pool        = element(var.node_pools, count.index % length(var.node_pools))
      vault_ip         = var.vault_ip
      # consul_token     = data.consul_acl_token_secret_id.nomad_client[count.index].secret_id,
    })
    destination = "/tmp/nomad.hcl"
  }
  /*
  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_config${var.consul_version}.hcl.tpl", {
      index = count.index,
      datacenter = var.consul_datacenter,
      private_ip = self.private_ip,
      gossip_key = var.gossip_key,
      node_name  = "nomad-client-${count.index}",
    })
    destination = "/tmp/consul.hcl"
  }

  provisioner "file" {
    content = templatefile("${path.root}/files/consul/consul_client_acl_config.hcl.tpl", {
      agent_token = data.consul_acl_token_secret_id.nomad_client[count.index].secret_id
    })
    destination = "/tmp/consul_acl.hcl"
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
    source      = "${path.root}/generated/connect_ca.crt"
    destination = "/tmp/connect_ca.crt"
  }

  provisioner "file" {
    source      = "${path.root}/files/consul/license.hclic"
    destination = "/tmp/consul_license.hclic"
  }
  */

  provisioner "file" {
    content = templatefile("${path.root}/files/nomad/nomad.service.tpl", {
      agent_type = "client",
    })
    destination = "/tmp/nomad.service"
  }

  provisioner "file" {
    content     = var.ca_cert //tls_self_signed_cert.ca_cert.cert_pem
    destination = "/tmp/nomad_ca.pem"
  }

  provisioner "file" {
    content     = tls_locally_signed_cert.nomad_client_signed_cert.cert_pem
    destination = "/tmp/nomad_cert.pem"
  }

  provisioner "file" {
    content     = tls_private_key.nomad_client_private_key.private_key_pem
    destination = "/tmp/nomad_key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/nomad.d/tls",
      "sudo mv /tmp/nomad.hcl /etc/nomad.d/nomad.hcl",
      "sudo mv /tmp/nomad_ca.pem /etc/nomad.d/tls/ca.crt",
      "sudo mv /tmp/nomad_key.pem /etc/nomad.d/tls/nomad.key",
      "sudo mv /tmp/nomad_cert.pem /etc/nomad.d/tls/nomad.crt",
      "sudo mv /tmp/nomad.service /etc/systemd/system/nomad.service",
      "sudo chown -R nomad:nomad /etc/nomad.d",

      /*
      "sudo mkdir -p /etc/consul.d/tls",
      "sudo mv /tmp/consul.hcl /etc/consul.d/consul.hcl",
      "sudo mv /tmp/consul_acl.hcl /etc/consul.d/consul_acl.hcl",
      "sudo mv /tmp/consul_license.hclic /etc/consul.d/license.hclic",
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
    Name       = "${var.deployment_id}-nomad-client-${var.nomad_region}-${count.index}"
    nomad_role = "client_${var.nomad_region}"
    owner      = var.owner
  }

  connection {
    bastion_host        = var.bastion_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = var.ssh_key //file("${path.root}/generated/ssh_key") 

    host        = self.private_ip
    user        = "ubuntu"
    private_key = var.ssh_key //file("${path.root}/generated/ssh_key") 
  }
}
