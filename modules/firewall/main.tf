resource "google_compute_firewall" "allow_internal" {
    project = var.project_id
    name = "allow-internal"
    network = var.vpc_name
    

    allow {
      protocol = "tcp"
    }

    allow {
      protocol = "udp"
    }

    allow {
      protocol = "icmp"
    }

    source_ranges = [ "10.0.0.0/8" ]
}

resource "google_compute_firewall" "allow_health_check" {
    project = var.project_id
    name = "allow-health-checks"
    network = var.vpc_name

    allow {
      protocol = "tcp"
      ports = [ "10256","8080","443" ]
    }

    source_ranges = [ "35.191.0.0/16", "130.211.0.0/22"]
    target_tags = [ "gke-node" ]
    
}


resource "google_compute_firewall" "allow_master_to_nodes" {
    project = var.project_id
    name = "allow-master-to-nodes"
    network = var.vpc_name

    allow {
      protocol = "tcp"
      ports = [ "443","10250" ]
    }

    source_ranges = [ "172.16.0.0/28", "172.16.1.0/28"]
    target_tags = [ "gke-node" ]
}