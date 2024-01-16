job "web" {

  group "web" {
    network {
      mode = "bridge"
      port "http" {}
    }

    service {
      name = "web"
      port = "http"
    }

    task "web" {
      driver = "docker"
      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
        privileged = true
      }
      template {
        data = <<EOT
        {{ range service "api" }}
        UPSTREAM_URIS="http://{{ .Address }}:{{ .Port }}"
        {{ end }}
        EOT
        destination = "local/env.txt"
        env = true
      }
      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
        MESSAGE     = "web-service"
      }
    }
  }

}
