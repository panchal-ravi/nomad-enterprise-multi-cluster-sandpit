job "api" {

  group "api" {
    count = 2
    network {
      mode = "bridge"
      port "http" {}
    }

    service {
      name = "api"
      port = "http"
      tags = ["http"]
    }

    task "api" {
      driver = "docker"
      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
      }
      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
        MESSAGE = "api-service"
      }
    }
  }

}
