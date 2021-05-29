terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  profile = "konstantinos"
}
#Find amazon linux ami id
data "aws_ami" "linux_vm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}


#----------INSTANCES-----------------#
resource "aws_instance" "app_servers" {
	count = var.vm_size
	ami = data.aws_ami.linux_vm.id
	instance_type = "t2.micro"
  key_name = "pf6-keypair"
	vpc_security_group_ids = ["${aws_security_group.app_sec_group.id}"]
  subnet_id = "${aws_subnet.public_subnet[count.index % 2].id}"
  associate_public_ip_address = true
	user_data = "${file("install_httpd.sh")}"
  tags = {
    "Name" = "${var.env_name}"
  }
}