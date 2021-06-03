terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.aws_conf_profile
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

#########################################
resource "aws_vpc" "civm_vpc" {
  cidr_block = "172.16.0.0/16"
}

resource "aws_internet_gateway" "civm_igw" {
  vpc_id = aws_vpc.civm_vpc.id
}

resource "aws_subnet" "civm_subnet" {
  vpc_id  = aws_vpc.civm_vpc.id
  cidr_block  = "172.16.2.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route" "route" {
  route_table_id         = "${aws_vpc.civm_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.civm_igw.id}"
}

resource "aws_security_group" "civm_sec_group" {
  name = "CI server security group"
  vpc_id = aws_vpc.civm_vpc.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#########################################
resource "aws_instance" "civm" {
  ami = data.aws_ami.linux_vm.id
  instance_type = "t2.xlarge"
  key_name = "pf6-keypair"
	vpc_security_group_ids = ["${aws_security_group.civm_sec_group.id}"]
  subnet_id = aws_subnet.civm_subnet.id
  associate_public_ip_address = true
  user_data = "${file("install.sh")}"
  tags = { 
    "Name":"CI SERVER"
    }
}

