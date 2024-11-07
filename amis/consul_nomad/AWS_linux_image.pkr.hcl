source "amazon-ebs" "ubuntu-image" {
  ami_name = "${var.owner}-consul-nomad-enterprise-{{timestamp}}"
  region = "${var.aws_region}"
  instance_type = var.aws_instance_type
  tags = {
    Name = "${var.owner}-consul-nomad-enterprise"
    consul_version = "${var.consul_version}"
    nomad_version = "${var.nomad_version}"
  }
  source_ami_filter {
      filters = {
        virtualization-type = "hvm"
        name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
        root-device-type = "ebs"
      }
      owners = ["099720109477"]
      most_recent = true
  }
  communicator = "ssh"
  ssh_username = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu-image"
  ]

  provisioner "shell" {
    inline = [
      "curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -",
      "sudo apt-add-repository \"deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main\"",
      "sudo apt-get update",
      "sudo apt-get install unzip -y",
      "sudo apt-get install default-jre -y",
      "sudo apt-get install net-tools -y",
      "sudo apt-get install jq -y",
      "sudo apt install zsh -y",
      "sh -c \"$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\"",
      "echo \"plugins=(git zsh-autosuggestions fast-syntax-highlighting)\" >> ~/.zshrc",
      "sudo usermod -s /usr/bin/zsh ubuntu",
    ]
  }

  provisioner "shell" {
    inline = [
      "sleep 10",
      "export ENVOY_VERSION_STRING=${var.envoy_version}",
      "curl -L https://func-e.io/install.sh | sudo bash -s -- -b /usr/local/bin",
      "export FUNC_E_PLATFORM=linux/amd64",
      "func-e use $ENVOY_VERSION_STRING",
      "sudo cp ~/.func-e/versions/$ENVOY_VERSION_STRING/bin/envoy /usr/local/bin/",
    ]
  }

  provisioner "shell" {
    inline = [
      // Install docker
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
      "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",

      // Install CNI Plugins
      "export ARCH_CNI=$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)",
      "export CNI_PLUGIN_VERSION=${var.cni_plugin_version}",
      "curl -L -o cni-plugins.tgz \"https://github.com/containernetworking/plugins/releases/download/$CNI_PLUGIN_VERSION/cni-plugins-linux-$ARCH_CNI-$CNI_PLUGIN_VERSION\".tgz",
      "sudo mkdir -p /opt/cni/bin",
      "sudo tar -C /opt/cni/bin -xzf cni-plugins.tgz",
      "sudo modprobe bridge",
      "sudo modprobe br_netfilter",

      // Install Consul-CNI plugin
      # "curl -L -o consul-cni.zip \"https://releases.hashicorp.com/consul-cni/1.5.0/consul-cni_1.5.3_linux_$ARCH_CNI\".zip",
      # "sudo unzip consul-cni.zip -d /opt/cni/bin -x LICENSE.txt",

      "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-arptables",
      "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-ip6tables",
      "echo 1 | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables",
      "echo \"net.bridge.bridge-nf-call-arptables = 1\" | sudo tee -a /etc/sysctl.d/iptables.conf",
      "echo \"net.bridge.bridge-nf-call-ip6tables = 1\" | sudo tee -a /etc/sysctl.d/iptables.conf",
      "echo \"net.bridge.bridge-nf-call-iptables = 1\" | sudo tee -a /etc/sysctl.d/iptables.conf",

      // Download Nomad
      "echo Downloading \"https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_amd64.zip\"",
      "curl -k -O \"https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_amd64.zip\"",
      "unzip -o nomad_${var.nomad_version}_linux_amd64.zip",
      "sudo mv nomad /usr/local/bin/nomad",
      "sudo adduser --system --group nomad || true",
      "sudo mkdir -p /etc/nomad.d/data",
      "sudo chown -R nomad:nomad /etc/nomad.d",
      "sudo chown nomad:nomad /usr/local/bin/nomad",
      "sudo mkdir -p /var/log/nomad/audit",
      "sudo chown -R nomad:nomad /var/log/nomad/audit",
    ]
  }


  provisioner "shell" {
    inline = [
      "sleep 5",
      // Download Consul
      "echo Downloading \"https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip\"",
      "curl -k -O \"https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_amd64.zip\"",
      "unzip -o consul_${var.consul_version}_linux_amd64.zip",
      "sudo mv consul /usr/local/bin/consul",
      "sudo adduser --system --group consul || true",
      "sudo mkdir -p /etc/consul.d/data",
      "sudo chown -R consul:consul /etc/consul.d",
      "sudo chown consul:consul /usr/local/bin/consul",
      "sudo mkdir -p /var/log/consul",
      "sudo chown -R consul:consul /var/log/consul",

    ]
  }
}
