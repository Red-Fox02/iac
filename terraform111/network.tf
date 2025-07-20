# Создаем VPC сеть
resource "yandex_vpc_network" "main" {
  name        = "main-network"
  description = "Основная сеть для инфраструктуры сайта"
}

# NAT Gateway для выхода в интернет из приватных подсетей
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

# Таблица маршрутов для приватных подсетей
resource "yandex_vpc_route_table" "private" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# Приватные подсети
resource "yandex_vpc_subnet" "private-a" {
  name           = "private-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

resource "yandex_vpc_subnet" "private-b" {
  name           = "private-subnet-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private.id
}

# Публичная подсеть
resource "yandex_vpc_subnet" "public-a" {
  name           = "public-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

# Security Groups
resource "yandex_vpc_security_group" "bastion" {
  name        = "bastion-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для Bastion хоста"

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Разрешить SSH из интернета"
  }
}

resource "yandex_vpc_security_group" "web" {
  name        = "web-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для веб-серверов"

  ingress {
    protocol       = "TCP"
    port           = 80
    security_group_id = yandex_vpc_security_group.alb.id
    description    = "Разрешить HTTP от ALB"
  }

  ingress {
    protocol       = "TCP"
    port           = 9100
    security_group_id = yandex_vpc_security_group.monitoring.id
    description    = "Разрешить доступ к Node Exporter"
  }

  ingress {
    protocol       = "TCP"
    port           = 22
    security_group_id = yandex_vpc_security_group.bastion.id
    description    = "Разрешить SSH только с Bastion"
  }
}

resource "yandex_vpc_security_group" "alb" {
  name        = "alb-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для Application Load Balancer"

  ingress {
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Разрешить HTTP из интернета"
  }
}

resource "yandex_vpc_security_group" "monitoring" {
  name        = "monitoring-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для сервисов мониторинга"

  ingress {
    protocol       = "TCP"
    port           = 9090
    security_group_id = yandex_vpc_security_group.grafana.id
    description    = "Разрешить доступ к Prometheus"
  }
}

resource "yandex_vpc_security_group" "grafana" {
  name        = "grafana-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для Grafana"

  ingress {
    protocol       = "TCP"
    port           = 3000
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Разрешить доступ к Grafana"
  }
}

resource "yandex_vpc_security_group" "logging" {
  name        = "logging-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для Elasticsearch"

  ingress {
    protocol       = "TCP"
    port           = 9200
    security_group_id = yandex_vpc_security_group.kibana.id
    description    = "Разрешить доступ к Elasticsearch"
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name        = "kibana-security-group"
  network_id  = yandex_vpc_network.main.id
  description = "Группа безопасности для Kibana"

  ingress {
    protocol       = "TCP"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"]
    description    = "Разрешить доступ к Kibana"
  }
}