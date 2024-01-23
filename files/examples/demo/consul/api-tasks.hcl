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
      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
        MESSAGE     = "api-service"
      }
      template {
        data        = <<EOF
        Consul Services:
        {{- range services}}
          * {{.Name}}{{end}}

        Consul KV for "api/config":
        {{- range ls "api/config"}}
          * {{.Key}}: {{.Value}}{{end}}
        EOF
        destination = "local/consul-info.txt"
      }
    }
  }

}
