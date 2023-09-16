job "hashiflip" {
  datacenters = ["{{ datacenter_name }}"]
  type        = "service"

  group "hashiflip" {
    count = 1

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "hashiflip"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.hashiflip.entrypoints=websecure",
        "traefik.http.routers.hashiflip.rule=Host(`hashiflip.{{ consul_domain }}`)",
        "traefik.http.routers.hashiflip.tls.certResolver={{ traefikee_vault_resolver }}"
      ]
    }

    task "hashiflip" {
      driver = "docker"

      config {
        image = "chrisvanmeer/hashiflip"
        ports = ["http"]
      }

    }
  }
}
