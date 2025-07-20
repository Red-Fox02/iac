resource "yandex_compute_instance" "elasticsearch" {
  name        = "elasticsearch"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit" # Ubuntu 20.04
      size     = 30
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private-a.id
    security_group_ids = [yandex_vpc_security_group.logging.id]
    nat               = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit" # Ubuntu 20.04
      size     = 15
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public-a.id
    security_group_ids = [yandex_vpc_security_group.kibana.id]
    nat               = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}