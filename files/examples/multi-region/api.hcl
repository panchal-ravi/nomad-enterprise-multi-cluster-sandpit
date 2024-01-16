job "api" {

  group "api" {
    count = 1
    network {
      mode = "bridge"
      port "http" {}
    }

    service {
      name     = "api"
      port     = "http"
      tags     = ["http"]
      provider = "nomad"
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
      identity {
        # Expose Workload Identity in NOMAD_TOKEN env var
        env = true
        # Expose Workload Identity in ${NOMAD_SECRETS_DIR}/nomad_token file
        file = true
      }
    }
  }

}
