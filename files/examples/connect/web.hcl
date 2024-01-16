job "web" {

  group "web" {
    network {
      mode = "bridge"
      port "http" {
        /* static = 9090 */
        to = 9090
      }
    }

    service {
      name = "web"
      port = "http"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "api"
              local_bind_port = "9091"
            }
            upstreams {
              destination_name = "external-service"
              local_bind_port = "9092"
            }
          }
        }
      }
    }

    task "web" {
      driver = "docker"
      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
        privileged = true
      }
      
      env {
        /* LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}" */
        LISTEN_ADDR = "127.0.0.1:${NOMAD_PORT_http}"
        MESSAGE     = "web-service"
        UPSTREAM_URIS = "http://${NOMAD_UPSTREAM_ADDR_api}, http://${NOMAD_UPSTREAM_ADDR_external-service}"
      }
    }
  }

}
