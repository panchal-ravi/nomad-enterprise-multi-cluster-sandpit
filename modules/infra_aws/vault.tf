resource "random_string" "vault_token" {
  length  = 24
  lower   = true
  upper   = true
  numeric = true
  special = false
}

resource "aws_instance" "vault" {
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.this.key_name
  vpc_security_group_ids = [module.vault_sg.security_group_id]
  subnet_id              = element(module.vpc.private_subnets, 0)

  tags = {
    Name  = "${var.deployment_id}-vault-server"
    owner = var.owner
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/vault/vault.service")
    destination = "/tmp/vault_base64.service"
  }

  provisioner "file" {
    content     = file("${path.root}/files/vault/license.hclic")
    destination = "/tmp/license.hclic"
  }

  provisioner "file" {
    content     = filebase64("${path.root}/files/vault/vault_config.hcl")
    destination = "/tmp/vault-config-base64.hcl"
  }

  provisioner "file" {
    content = join("\n", [tls_locally_signed_cert.vault_server_signed_cert.cert_pem, tls_self_signed_cert.ca_cert.cert_pem])
    destination = "/tmp/vault.crt"
  }
  provisioner "file" {
    content = tls_private_key.vault_server_private_key.private_key_pem
    destination = "/tmp/vault.key"
  }

  provisioner "remote-exec" {
    inline = [
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt update && sudo apt install vault-enterprise",
      "sudo mkdir -p /etc/vault.d/data",
      "sudo base64 -d /tmp/vault-config-base64.hcl > /tmp/vault_config.hcl",
      "sudo mv /tmp/vault_config.hcl /etc/vault.d/vault.hcl",
      "sudo mv /tmp/license.hclic /etc/vault.d/license.hclic",
      "sudo mv /tmp/vault.crt /etc/vault.d/vault.crt",
      "sudo mv /tmp/vault.key /etc/vault.d/vault.key",
      "sudo base64 -d /tmp/vault_base64.service > /tmp/vault.service",
      "sudo mv /tmp/vault.service /etc/systemd/system/vault.service",
      "sudo chown -R vault:vault /opt/vault/data",
      "sudo chown -R vault:vault /etc/vault.d/data",
      "sudo chmod 664 /etc/systemd/system/vault.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable vault",
      "sudo systemctl start vault",
      "sleep 20",
      "export VAULT_ADDR=https://127.0.0.1:8200",
      "export VAULT_SKIP_VERIFY=true",
      "export VAULT_TLS_SERVER_NAME=demo.server.vault",
      "sudo -E vault operator init -n 1 -t 1 -format=json > /home/ubuntu/init.json",
      "sudo -E vault operator unseal \"`jq -r '.unseal_keys_b64[0]' init.json`\"",
      "sudo jq -r .root_token init.json > /home/ubuntu/vault_token",
      "export VAULT_TOKEN=$(cat /home/ubuntu/vault_token)",
      "sudo -E vault token create -id ${random_string.vault_token.result} -policy root",
      "echo \".................................Done setup.........................................\""
    ]
  }

  /*
  provisioner "local-exec" {
    command = <<-EOT
      ssh -o StrictHostKeyChecking=no -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip} "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i /home/ubuntu/ssh_key ubuntu@${self.private_ip}:/home/ubuntu/vault_token /home/ubuntu/vault_token"  
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${path.root}/generated/${local.key_name} ubuntu@${aws_instance.bastion.public_ip}:/home/ubuntu/vault_token ./generated/
      EOT
  }
  */

  connection {
    bastion_host        = aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    agent               = false
    bastion_private_key = tls_private_key.ssh.private_key_openssh

    host        = self.private_ip
    user        = "ubuntu"
    private_key = tls_private_key.ssh.private_key_openssh
  }

  depends_on = [
    module.vpc,
    local_file.private_key
  ]
}

resource "null_resource" "delete_vault_token" {

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOD
      rm ${path.root}/generated/vault_token || true
      EOD
  }
}
