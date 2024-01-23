job "api" {

  namespace = "api-dev"
  # datacenters = ["dc1"]
  group "api" {
    count = 1
    network {
      # mode = "bridge"
      port "http" {}
    }

    consul {
      namespace = "api-dev"
    }

    service {
      provider = "consul"
      name     = "api"
      port     = "http"
      tags     = ["http"]
    }
    
    task "api" {
      driver = "docker"

      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
      }

      vault {
        namespace = "api-dev"
        change_mode   = "signal"
        change_signal = "SIGUSR1"
      }

      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
        MESSAGE     = "api-service"
      }

      template {
        data        = <<EOF
ROOT_USERNAME=root
ROOT_PASSWORD={{with secret "kv/data/api/config"}}{{.Data.data.root_password}}{{end}}
EOF
        destination = "secrets/env"
        env         = true
      }

      action "get-home" {
        command = "/bin/sh"
        args = [
          "-c",
          "curl -s http://localhost:${NOMAD_PORT_http}"
        ]
      }
      action "show-secrets" {
        command = "cat"
        args = [
          "/secrets/env"
        ]
      }
    }
  }
}
