# VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
}

# Internet Gateway
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
}

# Subnet Public_1
resource "aws_subnet" "public_subnet" {
  count=length(var.avail_zones)
  vpc_id = aws_vpc.app_vpc.id
  availability_zone = "${element(var.avail_zones, count.index)}"
  cidr_block = "10.30.${count.index}.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route" "route" {
  route_table_id         = "${aws_vpc.app_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.app_igw.id}"
}

#Security group
resource "aws_security_group" "app_sec_group" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.app_vpc.id

 
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.alb_sec_group.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
