## project
variable "project_id" {
  description = "The GCP project ID."
}

variable "region" {
  description = "The GCP region."
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone."
  default     = "us-central1-a"
}

## service account
variable "service_account_id" {
  description = "service account id for instance."
}
variable "service_account_name" {
  description = "service account name for instance."
}

## instance
variable "instance_name" {
  description = "The GCE instance name."
}

variable "machine_type" {
  description = "The GCE machine type."
  default     = "e2-small"
}

variable "image" {
  description = "The GCE instance boot disk image."
  default     = "debian-cloud/debian-10"
}

variable "tags" {
  type        = list(string)
  description = "The GCE instance tags. refered by security module."
}

variable "rdp_port" {
  description = "The GCE instance rdp port."
}

variable "ssh_port" {
  description = "The GCE instance ssh port."
}

variable "instance_user" {
  description = "The GCE instance user."
}

variable "device" {
  description = "attached disk device name."
}

variable "disk_name" {
  description = "attached disk name."
}
