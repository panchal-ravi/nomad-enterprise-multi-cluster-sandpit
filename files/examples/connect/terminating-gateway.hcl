job "terminating-gateway" {

  /* datacenters = ["dc1"] */

  group "terminating-gateway" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "terminating-gateway"

      connect {
        gateway {
          proxy {}
          terminating {
            service {
              name = "external-service"
            }
            /* service {
              name = "redis-svc"
            } */
          }
        }
      }
    }
  }
}