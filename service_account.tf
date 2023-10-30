# data "google_iam_policy" "develop-instance" {
#   binding {
#     role = "roles/iam.serviceAccountUser"
# 
#     members = [
#       "user:motojouya@google.com",
#     ]
#   }
# }

## gceにつけるservice account
resource "google_service_account" "developer" {
  account_id   = var.service_account_id
  display_name = var.service_account_name
}

# resource "google_service_account_iam_policy" "admin-account-iam" {
#   service_account_id = google_service_account.developer.name
#   policy_data        = data.google_iam_policy.develop-instance.policy_data
# }
#
