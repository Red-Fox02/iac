# Инфраструктурный проект на Terraform + Ansible

## Описание проекта
Проект автоматизирует развертывание мониторинговой инфраструктуры:
- Prometheus + Grafana
- Elasticsearch + Kibana
- Node exporters
- Веб-серверы

## Быстрый старт

### Предварительные требования
- Terraform 1.0+
- Ansible 2.10+
- SSH-ключ `id_ed25519` в `~/.ssh/`

### Развертывание инфраструктуры
```bash
terraform init
terraform apply -auto-approve
Пример вывода:

Outputs:

alb_public_ip = "130.193.46.88"
bastion_public_ip = "89.169.155.214"
elasticsearch_private_ip = "192.168.10.27"
grafana_public_ip = "51.250.84.118"
grafana_url = "http://51.250.84.118:3000"
kibana_public_ip = "89.169.128.55"
kibana_url = "http://89.169.128.55:5601"
prometheus_private_ip = "192.168.10.28"
ssh_bastion_command = "ssh -J ubuntu@89.169.155.214 ubuntu@<private_ip>"
ssh_web_a_command = "ssh -J ubuntu@89.169.155.214 ubuntu@192.168.10.31"
ssh_web_b_command = "ssh -J ubuntu@89.169.155.214 ubuntu@192.168.20.21"
vpc_network_id = "enp7fcljgkekoecdbk0d"
web_a_private_ip = "192.168.10.31"
web_b_private_ip = "192.168.20.21"
website_url = "http://130.193.46.88"
```

Для реализации подключения использован обычный проброс id_ed25519 ключа:
```bash
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
```

Для подключения используйте:
```bash
ssh ubuntu@host-ip
```
### Развертывание сервисов
Для ускорения исталяции серсисов написаны ansible playbooks
playbook-web.yml
playbook-prometheus.yml
playbook-grafana.yml
playbook-elasticsearch.yml
playbook-kibana.yml
filebeat.yml
exporters.yml 

Инициализация Ansible-plabooks:
```bash
ansible-playbook -i inventory.ini playbook-web.yml
ansible-playbook -i inventory.ini playbook-prometheus.yml
ansible-playbook -i inventory.ini playbook-grafana.yml
ansible-playbook -i inventory.ini playbook-elasticsearch.yml
ansible-playbook -i inventory.ini playbook-kibana.yml
ansible-playbook -i inventory.ini filebeat.yml
ansible-playbook -i inventory.ini exporters.yml
```

### Конфигурация inventory.ini
inventory.ini предварительно настроен для работы через бастион:
```bash
[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/id_ed25519 ubuntu@89.169.155.214"'
```
Это позволит избежать установки шаг с утановокой ansible и повторным формированием конфигов.


Для корректного взаимодействия сервисов меж собой, требуется проверить открыты ли порты этих сервисов на локальных машинах,
поэтому после инсталяции репомендуется дополнительно прокинуть порты ранее установленных сервисов.

```
Сервис:    Порт по умолчанию: 
Node-exporter  - 9100
Grafana        - 3000
Kibana         - 5601
Elasticsearch  - 9200
Prometheus     - 9090
```
Пример команды для хоста с Prometheus:
```bash
sudo iptables -A INPUT -p tcp --dport 9100 -j ACCEPT
```

Cкриншоты работоспособности доступны по:
https://docs.google.com/document/d/1IW89RO8RPyDNjuUJVsQX8giNVA2ULsoP/edit?usp=drive_web&ouid=100249948308320252751&rtpof=true
