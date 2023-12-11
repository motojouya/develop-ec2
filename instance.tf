# data "aws_ami" "develop_ami" {
#   owners           = ["amazon"]
#   executable_users = ["self"]
#   most_recent      = true
# 
#   filter {
#     name   = "architecture"
#     values = ["x86_64"] # , "arm64"
#   }
#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   filter {
#     name   = "name"
#     values = ["${var.ami_name_prefix}*"]
#   }
# }

resource "aws_instance" "develop" {
    # ami           = data.aws_ami.develop_ami.id
    ami           = "${var.ami_id}"
    instance_type = "${var.instance_type}"

    associate_public_ip_address = true
    availability_zone           = "${var.region}"
    subnet_id                   = "${var.subnet_id}"
    security_groups             = ["${var.security_group_name}"]
    # vpc_security_group_ids      = ["${var.security_group_id}"]

    key_name             = "${var.keypair_name}"
    iam_instance_profile = "${var.profile_name}"

    instance_market_options {
      market_type = "spot"
      spot_options {
        max_price = "var.max_price"
      }
    }

    user_data = <<EOF
      #!/bin/bash
      curl https://raw.githubusercontent.com/motojouya/develop-ec2/resources/master/init.sh | bash -s -- ${var.region} ${var.ssh_port} ${var.volume_id} ${var.device_name} ${var.user_name}
    EOF

    tags = {
        Name = "develop"
    }
}

resource "aws_volume_attachment" "develop_ebs_attachment" {
  device_name = "${var.device_name}"
  volume_id   = "${var.volume_id}"
  instance_id = aws_instance.develop.id
}
