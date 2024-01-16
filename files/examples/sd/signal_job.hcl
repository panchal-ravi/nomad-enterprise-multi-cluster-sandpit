job "signal-job" {
  datacenters = ["dc1"]

  group "sgroup" {
    count=2
    task "stask" {
      driver = "docker"

      config {
        image = "shm32/signal_handler:1.0"
      }

      resources {
        cpu    = 200
        memory = 256
      }
    }

    shutdown_delay = "20s"

    service {
       name = "${JOB}"
    }
  }
}