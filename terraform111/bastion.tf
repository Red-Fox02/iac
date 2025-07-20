resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
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
    subnet_id          = yandex_vpc_subnet.public-a.id
    security_group_ids = [yandex_vpc_security_group.bastion.id]
    nat               = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}