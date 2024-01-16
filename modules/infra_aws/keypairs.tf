locals {
  key_name = "ssh_key"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "aws_key_pair" "this" {
  key_name   = "${var.deployment_id}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh.private_key_openssh
  filename = "${path.root}/generated/${local.key_name}"

  provisioner "local-exec" {
    command = "chmod 400 ${path.root}/generated/${local.key_name}"
  }
}
