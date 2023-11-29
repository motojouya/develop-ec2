
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

resource "aws_launch_template" "foo" {
  name = "foo"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 4
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_stop        = true
  disable_api_termination = true

  ebs_optimized = true

  elastic_gpu_specifications {
    type = "test"
  }

  elastic_inference_accelerator {
    type = "eia1.medium"
  }

  iam_instance_profile {
    name = "test"
  }

  image_id = "ami-test"

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t2.micro"

  kernel_id = "test"

  key_name = "test"

  license_specification {
    license_configuration_arn = "arn:aws:license-manager:eu-west-1:123456789012:license-configuration:lic-0123456789abcdef0123456789abcdef"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = true
  }

  network_interfaces {
    associate_public_ip_address = true
  }

  placement {
    availability_zone = "us-west-2a"
  }

  ram_disk_id = "test"

  vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "test"
    }
  }

  user_data = filebase64("${path.module}/example.sh")
}

resource "aws_ec2_fleet" "spot_fleet_develop" {
  type = "request"

  terminate_instances                 = true
  terminate_instances_with_expiration = true
  excess_capacity_termination_policy  = "termination"

  launch_template_config {
    launch_template_specification {
      launch_template_id = aws_launch_template.example.id
      version            = aws_launch_template.example.latest_version
    }
  }

  tags {
    Name = "develop"
  }

  target_capacity_specification {
    default_target_capacity_type = "spot"
    total_target_capacity        = 1
  }

  spot_options {
    max_total_price = "0.1290"
  }
}

resource "aws_spot_fleet_request" "spot-fleet-request" {
  iam_fleet_role = "${aws_iam_role.spot-fleet-role.arn}"
  launch_specification {
    ami                         = "${var.spot_instance_ami}"
    instance_type               = "${var.spot_instance_type}"
    key_name                    = "${aws_key_pair.ml-key.key_name}"
    vpc_security_group_ids      = ["${aws_security_group.ml-web-sg.id}"]
    subnet_id                   = "${var.vpc_subnet_id}"
    associate_public_ip_address = true

    root_block_device {
      volume_size           = "${var.gp2_volume_size}" # 8
      volume_type           = "gp2"
      delete_on_termination = true
      device_name           = "/dev/sda1"
    }

    tags {
      Name = "develop"
    }
  }
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
