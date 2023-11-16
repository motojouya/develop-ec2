
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




# os loginはdefaultでtrueっぽい
# 本来はinstanceのmetadataに指定する
resource "google_compute_instance" "default" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  attached_disk {
    source      = "projects/${var.project_id}/zones/${var.zone}/disks/${var.disk_name}"
    device_name = var.disk_name
  }

  metadata = {
    enable-oslogin : "TRUE"
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    email  = google_service_account.developer.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<EOF
#!/bin/bash
curl https://raw.githubusercontent.com/motojouya/develop-ec2/main/resources/init.sh | bash -s -- ${var.instance_user} ${var.ssh_port} ${var.device} ${var.rdp_port}
EOF

  scheduling {
    preemptible         = true
    on_host_maintenance = "TERMINATE"
    automatic_restart   = false
  }
}

