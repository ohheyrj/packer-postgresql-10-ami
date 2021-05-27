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
      "sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-aarch64/pgdg-redhat-repo-latest.noarch.rpm",
      "sudo dnf -qy module disable postgresql",
      "sudo dnf install -y postgresql10-server",
      "sudo /usr/pgsql-10/bin/postgresql-10-setup initdb",
      "sudo systemctl enable postgresql-10"
    ]
  }
}