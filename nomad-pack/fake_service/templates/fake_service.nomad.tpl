job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool = [[ var "node_pool" . ]]
  type = "service"

  group "app" {
    count = [[ var "count" . ]]

    network {
      [[ if var "network_mode" . -]]
      mode = [[ var "network_mode" . ]]
      [[- end ]]
      port "http" {}
    }

    [[ if var "register_service" . ]]
    service {
      name = "[[ var "service_name" . ]]"
      tags = [[ var "service_tags" . | toStringList ]]
      provider = "nomad"
      port = "http"
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = "panchalravi/fake-service:0.24.2"
        ports = ["http"]
      }

      env {
        LISTEN_ADDR = "0.0.0.0:${NOMAD_PORT_http}"
        MESSAGE = [[ var "message" . | quote ]]
      }
    }
  }
}
