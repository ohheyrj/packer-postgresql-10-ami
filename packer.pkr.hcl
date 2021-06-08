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
  provisioner "file" {
    source = "pg_hba.conf"
    destination = "/tmp/pg_hba.conf"
  }
  provisioner "file" {
    source = "postgresql.conf"
    destination = "/tmp/postgresql.conf"
  }
  provisioner "shell" {
    inline = [
      "sudo yum -y update",
      "sudo amazon-linux-extras install postgresql10 vim epel",
      "sudo yum install -y postgresql-server postgresql-devel postgresql-client",
      "sudo /usr/bin/postgresql-setup --initdb",
      "sudo mv /tmp/pg_hba.conf /var/lib/pgsql/data/",
      "sudo mv /tmp/postgresql.conf /var/lib/pgsql/data/",
      "sudo chown postgres: /var/lib/pgsql/data/pg_hba.conf",
      "sudo chown postgres: /var/lib/pgsql/data/postgresql.conf",
      "sudo systemctl enable postgresql",
      "sudo systemctl start postgresql",
      "sudo systemctl status postgresql.service",
      "sudo -H -u postgres sh -c 'psql --command \"CREATE USER ha_user;\"'",
      "sudo -H -u postgres sh -c 'createdb home_assistant;'",
      "sudo -H -u postgres sh -c 'psql --command \"grant all privileges on database home_assistant to ha_user;\"'"
    ]
  }
}