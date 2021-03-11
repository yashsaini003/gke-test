 resource "google_container_cluster" "main_cluster" {
  provider                 = google 
  name                     = "${var.name}-${var.stage}"
  location                 = var.location
  initial_node_count       = var.remove_default_node_pool != "false" ? 1 : var.initial_node_count
  remove_default_node_pool = var.remove_default_node_pool == "true" ? true : false

  /*network            = var.vpc_link != null ? var.vpc_link : null
  subnetwork         = var.subnet_link != null ? var.subnet_link : null
  min_master_version = var.gke_master_version != null ? var.gke_master_version : null

  ip_allocation_policy {
    services_secondary_range_name = var.ip_policy[0].services_sec_range_name != null ? var.ip_policy.services_sec_range_name : null
    cluster_secondary_range_name  = var.ip_policy[0].cluster_sec_range_name != null ? var.ip_policy.cluster_sec_range_name : null
  }*/

  /*addons_config {
    http_load_balancing {
      disabled = var.addons_config[0].disable_load_balancing != "false" ? true : false
    }
    horizontal_pod_autoscaling {
      disabled = var.addons_config[0].disable_horiz_pod_autoscal != "false" ? true : false
    }
    istio_config {
      enabled = var.addons_config[0].enable_istio_config != "true" ? false : true
    }
  }*/
}

resource "google_container_node_pool" "node_pools" {
  count    = var.remove_default_node_pool != "false" ? length(var.node_pools) : 0
  location = var.location
  cluster  = google_container_cluster.main_cluster.name
  project  = var.gcloud_project

  initial_node_count = lookup(var.node_pools[count.index], "min_node_per_zone", 1)
  max_pods_per_node  = lookup(var.node_pools[count.index], "max_pods_per_node", 1)
  name               = lookup(var.node_pools[count.index], "name", )

  node_config {
  
      #name         = "alex-engine-high-cpu-mem"
      machine_type = "e2-standard-8"
      preemptible  = false
      image_type   = "Container"
      disk_size_gb = 100 
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append",
      ]
      /*min_node_per_zone = 0
      max_node_per_zone = 0
    

      name         = ""
      machine_type = ""
      preemptible  = false
      image_type   = ""
      disk_size_gb = 
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append",
      ]
      min_node_per_zone = 
      max_node_per_zone = 
  
      name         = ""
      machine_type = ""
      preemptible  = false
      image_type   = ""
      disk_size_gb = 
      oauth_scopes = [
        "https://www.googleapis.com/auth/logging.write",
        "https://www.googleapis.com/auth/monitoring",
        "https://www.googleapis.com/auth/devstorage.read_only",
        "https://www.googleapis.com/auth/servicecontrol",
        "https://www.googleapis.com/auth/service.management.readonly",
        "https://www.googleapis.com/auth/trace.append",
      ]
      min_node_per_zone = 1
      max_node_per_zone = 1
    }*/
  }

  autoscaling {
    min_node_count = lookup(var.node_pools[count.index], "min_node_per_zone", 1)
    max_node_count = lookup(var.node_pools[count.index], "max_node_per_zone", 1)
  }

  management {
    auto_repair  = lookup(var.node_pools[count.index], "auto_repair", true)
    auto_upgrade = lookup(var.node_pools[count.index], "auto_upgrade", true)
  }

  lifecycle {
    create_before_destroy = true
  }
}
