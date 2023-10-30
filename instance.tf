# os loginはdefaultでtrueっぽい
# 本来はinstanceのmetadataに指定する
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  attached_disk {
    source      = "projects/${var.project_id}/zones/${var.zone}/disks/${var.disk_name}"
    device_name = var.disk_name
  }

  metadata = {
    enable-oslogin : "TRUE"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.developer.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOF
#!/bin/bash
curl https://raw.githubusercontent.com/motojouya/develop-gcp/main/gce/resources/init.sh | bash -s -- ${var.instance_user} ${var.ssh_port} ${var.device} ${var.rdp_port}
EOF

  scheduling {
    preemptible         = true
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }
}
