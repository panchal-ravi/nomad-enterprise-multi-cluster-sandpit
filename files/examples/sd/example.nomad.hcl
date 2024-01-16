job "example" {

  group "cache" {
    network {
      /* mode = "bridge" */
      mode = "host"
      port "redis" {
        to     = 6379
        /* static = 6379 */
      }
    }

    service {
      name = "redis"
      port = "redis"
      tags = ["redis"]
    }

    task "redis" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "redis:7"
        ports        = ["redis"]
        /* auth_soft_fail = true */
      }

      /* identity {
        env  = true
        file = true
      } */

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
