job "http" {
  datacenters = ["dc1"]
  namespace = "api-dev"

  group "http" {
    count = "1"

    network {
      mode = "host"
      port "http" {
        /* to = "5678" */
        static = "5678"
      }
    }
    task "http" {
      driver = "docker"

      config {
        image        = "hashicorp/http-echo"
        ports        = ["http"]
        network_mode = "host"
        args = [
          "-listen",
          ":5678",
          "-text",
          "hello world",
        ]
      }
    }
  }
}
