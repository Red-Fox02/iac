resource "yandex_compute_instance" "web-a" {
  name        = "web-a"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit" # Ubuntu 20.04
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    security_group_ids = [yandex_vpc_security_group.web.id]
    nat               = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "web-b" {
  name        = "web-b"
  platform_id = "standard-v3"
  zone        = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit" # Ubuntu 20.04
      size     = 10
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-b.id
    security_group_ids = [yandex_vpc_security_group.web.id]
    nat               = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_alb_target_group" "web" {
  name = "web-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.private-a.id
    ip_address = yandex_compute_instance.web-a.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private-b.id
    ip_address = yandex_compute_instance.web-b.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "web" {
  name = "web-backend-group"

  http_backend {
    name             = "web-backend"
    weight          = 1
    port            = 80
    target_group_ids = [yandex_alb_target_group.web.id]
    
    healthcheck {
      timeout          = "10s"
      interval         = "2s"
      healthy_threshold   = 5
      unhealthy_threshold = 3
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "web" {
  name = "web-router"
}

resource "yandex_alb_virtual_host" "web" {
  name           = "web-virtual-host"
  http_router_id = yandex_alb_http_router.web.id
  
  route {
    name = "web-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "web" {
  name        = "web-balancer"
  network_id  = yandex_vpc_network.main.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-a.id
    }
  }

  listener {
    name = "web-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [80]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.web.id
      }
    }
  }
}