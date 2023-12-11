# network
variable "region" {}
variable "availability_zone" {}
variable "subnet_id" {}
variable "ssh_port" {}
variable "security_group_id" {}
# variable "security_group_name" {}

# instance
variable "instance_type" {}
variable "max_price" {}
variable "ami_id" {}
# variable "ami_name_prefix" {}
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
