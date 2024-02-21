# What

This Terraform state manages a service account key per node operator, and then provisions a Cloud Function per each of these service accounts to export their service account keys using the corresponding node operator's GPG public keys.

Be sure to activate the following APIs manually:
- `iam.googleapis.com`
- `cloudbuild.googleapis.com`
- `cloudfunctions.googleapis.com`
