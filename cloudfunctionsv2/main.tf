
# ---------------------------------------------------------------------------------------------------------------------
# Cloud Build resources (WIP)
# ---------------------------------------------------------------------------------------------------------------------


#resource "google_cloudbuild_worker_pool" "pool" {
#  name = "worker2"
#  location = "us-central1"
#  worker_config {
#    disk_size_gb = 100
#    machine_type = "e2-standard-4"
#    no_external_ip = true
#  }
#  network_config {
#    peered_network = "projects/prj-n-shared-base-a45b/global/networks/vpc-n-shared-base"
#    peered_network_ip_range = "/29"
#  }
#}
#

# ---------------------------------------------------------------------------------------------------------------------
# IAM Resources and roles
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "cfv2_service_account" {
  account_id   = "cfv2-runtime-sa"
  display_name = "Service Account for CFV2 runtime"
}

resource "google_service_account" "cfv2_eventarc_trigger_sa" {
  account_id   = "eventarc-sa-by-cfv2"
  display_name = "Service Account for Eventarc trigger"
}

resource "google_project_iam_binding" "role_binding" {
  project = var.cfv2_project
  role    = "roles/run.invoker"

  members = [
    "serviceAccount:${google_service_account.cfv2_eventarc_trigger_sa.email}",
  ]
}

# ---------------------------------------------------------------------------------------------------------------------
# Storage and objects resources
# ---------------------------------------------------------------------------------------------------------------------


resource "google_storage_bucket" "bucket" {
  name                        = "${var.cfv2_project}-cfv2-${var.cfv2_name}-source" # Every bucket name must be globally unique
  location                    = "us-central1"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "cfv2-${var.cfv2_name}-code.zip" #object name to be created
  bucket = google_storage_bucket.bucket.name
  source = "function-source.zip" # Add path to the local zipped function source code

}


#resource "google_artifact_registry_repository" "cfv2_artifact_registry" {
#  provider = google-beta
#
#  location      = var.cfv2_region
#  repository_id = "cmek-repo"
#  format        = "DOCKER"
#  kms_key_name  = var.cmek
#}
#

# ---------------------------------------------------------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------------------------------------------------------


resource "google_vpc_access_connector" "connector" {
  name    = var.vpc_connector
  region  = var.cfv2_region
  project = "prj-bu1-n-sample-base-bd59"
  subnet {
    name = "sb-n-shared-base-us-central1-serverless-vac"
    project_id = "prj-n-shared-base-a45b"
  }
  machine_type = "e2-standard-4"
}


# ---------------------------------------------------------------------------------------------------------------------
# Cloud Function V2
# ---------------------------------------------------------------------------------------------------------------------

resource "google_cloudfunctions2_function" "function" {
  name        = var.cfv2_name
  location    = var.cfv2_region
  description = "Cloud Function V2"
  #kms_key_name = var.cmek
  labels = var.cfv2_labels

  build_config {
    runtime     = var.cfv2_runtime
    entry_point = var.cfv2_entry_point
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
    #worker_pool = google_cloudbuild_worker_pool.pool.id 
  }

  service_config {
    max_instance_count               = var.cfv2_max_instances
    min_instance_count               = var.cfv2_min_instances
    available_memory                 = var.cfv2_available_memory_mb
    timeout_seconds                  = var.cfv2_timeout
    max_instance_request_concurrency = var.cfv2_max_instance_request_concurrency
    available_cpu                    = var.cfv2_available_cpu
    vpc_connector                    = google_vpc_access_connector.connector.name #should be replaced by var.vpc_connector since will be out of the scope of this script
    vpc_connector_egress_settings    = var.vpc_connector_egress_settings
    ingress_settings                 = var.cfv2_ingress_settings
    environment_variables            = var.cfv2_env_var
    service_account_email            = google_service_account.cfv2_service_account.email # should be replaced by var.cfv2_runtime_sa since sa creation will be out of the scope of this script
  }

  # Dynamic resource block for Eventarc trigger managed by the CFV2

  dynamic "event_trigger" {
    for_each = var.cfv2_evtarc_trigger != null ? [true] : []

    content {
      event_type   = var.cfv2_evtarc_trigger.type
      retry_policy = var.cfv2_evtarc_trigger_retry
      service_account_email = "" # should be replaced by var.cfv2_evtarc_trigger.service_account_email since sa creation will be out of the scope of this script
    }
  }

}
