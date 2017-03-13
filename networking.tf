resource "google_compute_network" "cr460-sourou" {
  name                    = "cr460-sourou"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "backend" {
  name          = "backend"
  ip_cidr_range = "192.168.1.0/24"
  network       = "${google_compute_network.cr460-sourou.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "workload" {
  name          = "workload"
  ip_cidr_range = "192.168.2.0/24"
  network       = "${google_compute_network.cr460-sourou.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "public" {
  name          = "public"
  ip_cidr_range = "192.168.3.0/24"
  network       = "${google_compute_network.cr460-sourou.self_link}"
  region        = "us-east1"
}





//Règles de firewall sur Backend

resource "google_compute_firewall" "ssh-backend" {
  name    = "ssh-backend"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
    source_tags = ["public","workload"]
    target_tags = ["backend"]

}

resource "google_compute_firewall" "tcp-2379-backend" {
  name    = "tcp-2379-backend"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["2379"]
  }
    source_tags = ["public","workload"]
    target_tags = ["backend"]
}

resource "google_compute_firewall" "tcp-2380-backend" {
  name    = "tcp-2380-backend"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["2380"]
  }
    source_tags = ["public","workload"]
    target_tags = ["backend"]
}

//Règles de firewall sur Workload

resource "google_compute_firewall" "ssh-workload" {
  name    = "ssh-workload"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
    source_tags = ["public"]
    target_tags = ["workload"]
}

//Règles de firewall sur Public

resource "google_compute_firewall" "ssh-public" {
  name    = "ssh-public"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
    target_tags = ["public"]
}

resource "google_compute_firewall" "web" {
  name    = "web"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
    target_tags = ["public"]
}

resource "google_compute_firewall" "https" {
  name    = "https"
  network = "${google_compute_network.cr460-sourou.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
    target_tags = ["public"]
}


resource "google_dns_record_set" "www" {
  name = "sourouarmel.cr460lab.com."
  type = "A"
  ttl  = 300

  managed_zone = "sourouarmel"

  rrdatas = ["${google_compute_instance.jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
  rrdatas = ["${google_compute_instance.vault.network_interface.0.access_config.0.assigned_nat_ip}"]

}
