locals {
  node_operators = [
    "node-op1",
    "node-op2",
  ]

  operatorToGPGPubkeyPath = {
    "node-op1" = "dummy_key_1.asc"
    "node-op2" = "dummy_key_2.asc"
  }

  project_id = "cayenne-410322"
}


terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  credentials = file("cayenne-410322-c9a8c9f5a371.json")

  project = local.project_id
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

// Create service account per each node operator
resource "google_service_account" "default" {
  for_each     = toset(local.node_operators)
  project      = local.project_id
  display_name = "${each.value} Dummy"
  account_id   = "${each.value}-dummy"
  description  = "Terraform Managed service account for ${each.value}"
}

module "distributor" {
  source = "github.com/hwrdtm/terraform-google-single-key-distributor"

  for_each = toset(local.node_operators)

  project_id      = local.project_id
  public_key_file = local.operatorToGPGPubkeyPath[each.key]

  depends_on = [google_service_account.default]

  function_name                = "${each.value}-distributor"
  function_members             = ["user:howard@litprotocol.com"]
  service_account_email_target = google_service_account.default[each.key].email
}
