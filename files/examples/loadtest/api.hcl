job "api" {

  group "api" {
    network {
      mode = "bridge"
      port "http" {}
    }
    task "api" {
      driver = "docker"
      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
        privileged = true
      }

      env {
        LISTEN_ADDR = "127.0.0.1:${NOMAD_PORT_http}"
        MESSAGE = "api-service"
        LOAD_MEMORY_PER_REQUEST = "4000000"
        LOAD_CPU_PERCENTAGE = "50"
        TIMING_99_PERCENTILE = "0.2s"
      }
      /* 
      resources {
        cpu = 100
        memory = 128
      } 
      */
    }

    service {
      name = "api"
      port = "http"
      /* port = "9090" */

      connect {
        sidecar_service {}
        sidecar_task {
          user = "envoy"
        }
      }
    }

  }

}
