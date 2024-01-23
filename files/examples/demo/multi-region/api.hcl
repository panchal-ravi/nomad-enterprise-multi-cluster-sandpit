job "api" {


  multiregion {
    strategy {
      max_parallel = 1
      on_failure   = "fail_all"
    }
    region "sg" {
      count       = 2
      datacenters = ["dc1"]
      node_pool   = "dev"
    }
    region "my" {
      count       = 1
      datacenters = ["dc1"]
      node_pool   = "dev"
    }
  }

  update {
    max_parallel      = 1
    min_healthy_time  = "10s"
    healthy_deadline  = "2m"
    progress_deadline = "3m"
    auto_revert       = true
    auto_promote      = true
    canary            = 1
    stagger           = "30s"
  }

  group "api" {
    count = 0
    network {
      # mode = "bridge"
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
