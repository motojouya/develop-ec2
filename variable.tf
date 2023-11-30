# vpc
variable "region" {}
variable "subnet_id" {}
variable "ssh_port" {}
variable "security_group_name" {}
# variable "security_group_id" {}

# instance
variable "ami_name_prefix" {} # al2023-ami-2023
variable "instance_type" {} # TODO

# profiles
variable "user_id" {}
variable "user_name" {}
variable "keypair_name" {}
variable "profile_name" {}

# storage
variable "device_name" {} # TODO /dev/sda1
variable "volume_id" {}

# others
variable "max_price" {} # 0.01
# variable "tags" {
#   type        = list(string)
# }
