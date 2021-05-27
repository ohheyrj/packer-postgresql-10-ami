packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "aws_base_image" {
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-hvm-*-arm64-gp2"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  region        = "eu-west-2"
  ami_name      = "postgresql_10_{{timestamp}}"
  ssh_username  = "ec2-user"
  instance_type = "t4g.nano"
}

build {
  sources = [
    "source.amazon-ebs.aws_base_image"
  ]
  provisioner "shell" {
    inline = [
      "sudo yum -y update",
      "sudo amazon-linux-extras install postgresql10 vim epel",
      "sudo yum install -y postgresql-server postgresql-devel",
      "/usr/bin/postgresql-setup –-initdb",
      "sudo systemctl enable postgresql",
    ]
  }
}