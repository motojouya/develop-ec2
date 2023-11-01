variable "region" {
  description = "AWS region"
  default     = "us-central1"
}

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
