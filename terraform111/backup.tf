resource "yandex_compute_snapshot_schedule" "daily" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "0 1 * * *" # Ежедневно в 1:00
  }

  snapshot_count = 7 # Храним 7 дней

  snapshot_spec {
    description = "daily-snapshot"
  }

  disk_ids = [
    yandex_compute_instance.web-a.boot_disk.0.disk_id,
    yandex_compute_instance.web-b.boot_disk.0.disk_id,
    yandex_compute_instance.prometheus.boot_disk.0.disk_id,
    yandex_compute_instance.grafana.boot_disk.0.disk_id,
    yandex_compute_instance.elasticsearch.boot_disk.0.disk_id,
    yandex_compute_instance.kibana.boot_disk.0.disk_id,
    yandex_compute_instance.bastion.boot_disk.0.disk_id
  ]
}