job "focus" {
  datacenters = ["velp"]
  type        = "service"

  group "focus" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "focus"
      port = "http"

      check {
        type     = "http"
        name     = "focus-http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "focus" {
      driver = "docker"

      config {
        image = "chrisvanmeer/focus"
        ports = ["http"]
      }

      resources {
        cpu    = 100
        memory = 50
      }

    }
  }
}
