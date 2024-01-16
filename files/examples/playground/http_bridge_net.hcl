job "http" {
  datacenters = ["dc1"]

  group "http" {
    count = "1"

    network {
      mode = "bridge"
      port "http" {
        to = "5678"
      }
    }
    task "http" {
      driver = "docker"

      config {
        image        = "hashicorp/http-echo"
        ports        = ["http"]
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
