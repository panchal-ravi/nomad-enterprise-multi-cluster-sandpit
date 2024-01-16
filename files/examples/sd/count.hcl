job "count-api" {
  datacenters = ["dc1"]

  group "count-api" {
    count = 2

    network {
      port "http" {
        static = 9001
        to     = 9001
      }
    }

    service {
      name = "count-api"
      port = "http"

      check {
        type = "http"
        name = "app_health"
        path = "/"
        protocol = "http"

        interval = "5s"
        timeout = "2s"
      }
    }

    task "count-api" {
      driver = "docker"

      config {
        image = "hashicorpdev/counter-api:v3"
        ports = ["http"]
      }
    }

    shutdown_delay = "10s"
  }
}
