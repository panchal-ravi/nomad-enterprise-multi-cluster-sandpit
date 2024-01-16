job "web-ingw" {

  /* datacenters = ["dc1"] */

  group "web-ingw" {

    /* count = 2 */
    network {
      mode = "bridge"
      port "web-inbound" {
        static = 8085
        to     = 8085
      }
    }

    service {
      name = "web-ingw"
      port = "web-inbound"

      /*
      tags = [
        "urlprefix-/petclinic/"
      ]
      */

      connect {
        gateway {
          proxy {}

          ingress {
            listener {
              port     = 8085
              protocol = "http"
              service {
                name  = "api"
                hosts = ["*"]
              }
            }
          }
        }
      }

      /* check {
        type     = "http"
        port     = "web-inbound"
        path     = "/petclinic/index.html"
        interval = "10s"
        timeout  = "2s"
      } */

    }

  }
}
