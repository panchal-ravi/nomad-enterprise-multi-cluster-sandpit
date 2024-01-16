job "app" {
  datacenters = ["dc1"]

  group "app" {
    count = 1

    network {
      mode = "bridge"
      port "api" {}
      port "web" {}
    }

    service {
        name = "api"
        port = "api"
    }

    service {
        name = "web"
        port = "web"
    }

    task "api" {
      driver = "docker"

      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["api"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_api}"
      }
    }

    task "web" {
      driver = "docker"

      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["web"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_web}"
      }
    }

  }
}
