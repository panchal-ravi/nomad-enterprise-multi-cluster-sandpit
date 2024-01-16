data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-consul-nomad-enterprise*"]
  }
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.an_image.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.this.key_name
  subnet_id       = element(module.vpc.public_subnets, 1)
  security_groups = [module.bastion_sg.security_group_id]

  tags = {
    Name  = "${var.deployment_id}-bastion"
    owner = var.owner
  }

  lifecycle {
    ignore_changes = all
  }

  provisioner "file" {
    content     = tls_private_key.ssh.private_key_openssh
    destination = "/home/ubuntu/ssh_key"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/${local.key_name}",
    ]
  }

  connection {
    host        = self.public_ip
    user        = "ubuntu"
    agent       = false
    private_key = tls_private_key.ssh.private_key_openssh
  }

}


resource "null_resource" "delete_generated" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
        rm ${path.root}/generated/nomad_management_token || true
        rm ${path.root}/generated/connect_ca.crt || true
        
    EOT
  }
}