# Основные выходные данные инфраструктуры
output "alb_public_ip" {
  description = "Публичный IP адрес Application Load Balancer"
  value       = try(yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address, null)
}

output "bastion_public_ip" {
  description = "Публичный IP адрес Bastion хоста"
  value       = yandex_compute_instance.bastion.network_interface[0].nat_ip_address
}

# Приватные IP адреса веб-серверов
output "web_a_private_ip" {
  description = "Приватный IP адрес веб-сервера в зоне A"
  value       = yandex_compute_instance.web-a.network_interface[0].ip_address
}

output "web_b_private_ip" {
  description = "Приватный IP адрес веб-сервера в зоне B"
  value       = yandex_compute_instance.web-b.network_interface[0].ip_address
}

# Адреса серверов мониторинга
output "prometheus_private_ip" {
  description = "Приватный IP адрес сервера Prometheus"
  value       = yandex_compute_instance.prometheus.network_interface[0].ip_address
}

output "grafana_public_ip" {
  description = "Публичный IP адрес сервера Grafana"
  value       = yandex_compute_instance.grafana.network_interface[0].nat_ip_address
}

# Адреса системы логирования
output "elasticsearch_private_ip" {
  description = "Приватный IP адрес сервера Elasticsearch"
  value       = yandex_compute_instance.elasticsearch.network_interface[0].ip_address
}

output "kibana_public_ip" {
  description = "Публичный IP адрес сервера Kibana"
  value       = yandex_compute_instance.kibana.network_interface[0].nat_ip_address
}

# URL для доступа к сервисам
output "website_url" {
  description = "URL веб-сайта"
  value       = "http://${try(yandex_alb_load_balancer.web.listener[0].endpoint[0].address[0].external_ipv4_address[0].address, "ALB_NOT_CREATED")}"
}

output "grafana_url" {
  description = "URL для доступа к Grafana"
  value       = "http://${try(yandex_compute_instance.grafana.network_interface[0].nat_ip_address, "GRAFANA_NOT_CREATED")}:3000"
}

output "kibana_url" {
  description = "URL для доступа к Kibana"
  value       = "http://${try(yandex_compute_instance.kibana.network_interface[0].nat_ip_address, "KIBANA_NOT_CREATED")}:5601"
}

# Идентификаторы ресурсов
output "vpc_network_id" {
  description = "ID созданной VPC сети"
  value       = yandex_vpc_network.main.id
}


# Команды для подключения
output "ssh_bastion_command" {
  description = "Команда для подключения через Bastion"
  value       = "ssh -J ubuntu@${try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "BASTION_NOT_CREATED")} ubuntu@<private_ip>"
}

output "ssh_web_a_command" {
  description = "Команда для подключения к web-a"
  value       = "ssh -J ubuntu@${try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "BASTION_NOT_CREATED")} ubuntu@${try(yandex_compute_instance.web-a.network_interface[0].ip_address, "WEB_A_NOT_CREATED")}"
}

output "ssh_web_b_command" {
  description = "Команда для подключения к web-b"
  value       = "ssh -J ubuntu@${try(yandex_compute_instance.bastion.network_interface[0].nat_ip_address, "BASTION_NOT_CREATED")} ubuntu@${try(yandex_compute_instance.web-b.network_interface[0].ip_address, "WEB_B_NOT_CREATED")}"
}