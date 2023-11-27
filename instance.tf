
resource "aws_instance" "hello-world" {
    ami                           = "${AMI}"
    instance_type                 = "${instance_type}"
    availability_zone             = "${region}"
    subnet_id                     = "${subnet_id}"
    key_name                      = "${keypair_name}"
    associate_public_ip_address   = "true"
    iam_instance_profile          = "${profile_name}"
    vpc_security_group_ids        = "${security_group}"
    user_data                     = <<EOF
      #!/bin/bash
      curl https://raw.githubusercontent.com/motojouya/develop-ec2/resources/master/init.sh | bash -s -- ${var.region} ${var.userId} ${var.userName} ${var.sshPort} ${var.volumeId}
    EOF
    # TODO EBS
    # TODO spot fleet

    tags = {
        Name = "develop"
    }
}

# Spot Fleet Request
resource "aws_spot_fleet_request" "ml-spot-request" {
  iam_fleet_role = "${aws_iam_role.spot-fleet-role.arn}"

  # spot_price      = "0.1290" # Max Price デフォルトはOn-demand Price
  target_capacity                     = "${var.spot_target_capacity}"
  terminate_instances_with_expiration = true
  wait_for_fulfillment                = "true" # fulfillするまでTerraformが待つ

  launch_specification {
    ami                         = "${var.spot_instance_ami}"
    instance_type               = "${var.spot_instance_type}"
    key_name                    = "${aws_key_pair.ml-key.key_name}"
    vpc_security_group_ids      = ["${aws_security_group.ml-web-sg.id}"]
    subnet_id                   = "${element(aws_subnet.ml-subnet-public.*.id, 0)}"
    associate_public_ip_address = true

    root_block_device {
      volume_size = "${var.gp2_volume_size}"
      volume_type = "gp2"
    }

    tags {
      Name = "ml-instance"
    }
  }

  launch_specification {
    ami                         = "${var.spot_instance_ami}"
    instance_type               = "${var.spot_instance_type}"
    key_name                    = "${aws_key_pair.ml-key.key_name}"
    vpc_security_group_ids      = ["${aws_security_group.ml-web-sg.id}"]
    subnet_id                   = "${element(aws_subnet.ml-subnet-public.*.id, 1)}"
    associate_public_ip_address = true

    root_block_device {
      volume_size = "${var.gp2_volume_size}"
      volume_type = "gp2"
    }

    tags {
      Name = "ml-instance"
    }
  }
}

data "aws_instance" "ml-instance" {
  filter {
    name   = "tag:Name"
    values = ["ml-instance"]
  }

  depends_on = ["aws_spot_fleet_request.ml-spot-request"]
}

const getSpotFleetRequestConfig = (region, userId, userName, sshPort, volumeId) => {

  const instanceSetting = {
    "BlockDeviceMappings": [
      {
        "DeviceName": "/dev/sda1",
        "Ebs": {
          "DeleteOnTermination": true,
          "VolumeType": "gp2",
          "VolumeSize": 8,
          "SnapshotId": ""
        }
      }
    ],
  };

  const launchSpecifications = [
    {
      "InstanceType": "m5.large",
      "SpotPrice": "0.124",
    },
    {
      "InstanceType": "m5a.large",
      "SpotPrice": "0.112",
    },
    {
      "InstanceType": "m5d.large",
      "SpotPrice": "0.146",
    },
  ].map(item => Object.assign(Object.assign({}, instanceSetting), item));

  const validFrom = new Date();
  const validUntil = new Date();
  validUntil.setHours(validFrom.getHours() + 2);
  validUntil.setMinutes(validFrom.getMinutes() + 30);

  return {
    "IamFleetRole": "",
    "AllocationStrategy": "lowestPrice",
    "TargetCapacity": 1,
    "SpotPrice": "0.146",
    "ValidFrom": validFrom.toISOString(),
    "ValidUntil": validUntil.toISOString(),
    "TerminateInstancesWithExpiration": true,
    "LaunchSpecifications": launchSpecifications,
    "Type": "request"
  };
};
