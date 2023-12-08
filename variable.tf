# network
variable "region" {}
variable "subnet_id" {}
variable "ssh_port" {}
variable "security_group_name" {}
# variable "security_group_id" {}

# instance
variable "ami_name_prefix" {}
variable "instance_type" {}
variable "max_price" {}
# variable "tags" {
#   type        = list(string)
# }

# profiles
# variable "user_id" {}
variable "user_name" {}
variable "keypair_name" {}
variable "profile_name" {}

# storage
variable "device_name" {}
variable "volume_id" {}
