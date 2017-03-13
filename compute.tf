
// création de etcd1
resource "google_compute_instance" "etcd1" {
  name         = "etcd1"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
    auto_delete = true

  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.backend.name}"
    access_config {

    }
  }

  metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
  }

// création de etcd2
  resource "google_compute_instance" "etcd2" {
    name         = "etcd2"
    machine_type = "f1-micro"
    zone         = "us-east1-b"

    disk {
      image = "coreos-cloud/coreos-stable"
      auto_delete = true

    }

    network_interface {
      subnetwork = "${google_compute_subnetwork.backend.name}"
      access_config {

      }
    }

    metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
    }

    // création de etcd3
      resource "google_compute_instance" "etcd3" {
        name         = "etcd3"
        machine_type = "f1-micro"
        zone         = "us-east1-b"

        disk {
          image = "coreos-cloud/coreos-stable"
          auto_delete = true

        }

        network_interface {
          subnetwork = "${google_compute_subnetwork.backend.name}"
          access_config {

          }
        }

        metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
        }

        // Création de Jumphost
        resource "google_compute_instance" "jumphost" {
          name         = "jumphost"
          machine_type = "f1-micro"
          zone         = "us-east1-b"

          disk {
            image = "debian-cloud/debian-8"
          }

          network_interface {
            subnetwork = "${google_compute_subnetwork.public.name}"
            access_config {

            }
          }

          metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
        }


        // Création de Vault
        resource "google_compute_instance" "vault" {
          name         = "vault"
          machine_type = "f1-micro"
          zone         = "us-east1-b"

          disk {
            image = "coreos-cloud/coreos-stable"
          }

          network_interface {
            subnetwork = "${google_compute_subnetwork.public.name}"
            access_config {

            }
          }

          metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
        }





// Instance Master du Workload
resource "google_compute_instance" "master" {
  name         = "master"
  machine_type = "f1-micro"
  zone         = "us-east1-b"

  disk {
    image = "coreos-cloud/coreos-stable"
    auto_delete = true

  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
    access_config {

    }
  }

  metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
  }


// Instances Workers du Workload

resource "google_compute_instance_template" "cr460-work" {
  name      = "cr460-work"
  machine_type         = "f1-micro"
  can_ip_forward       = false


  // Create a new boot disk from an image
  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete = true

  }


  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
  }

}

resource "google_compute_instance_group_manager" "cr460-work" {
  name        = "cr460-work"

  base_instance_name = "worker"
  instance_template  = "${google_compute_instance_template.cr460-work.self_link}"
  zone               = "us-east1-b"

}

resource "google_compute_autoscaler" "cr460-work" {
  name   = "cr460-work"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.cr460-work.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
