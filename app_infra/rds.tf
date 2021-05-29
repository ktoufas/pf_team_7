resource "aws_subnet" "rds_subnet" {
  count                   = "${length(var.avail_zones)}"
  vpc_id                  = "${aws_vpc.app_vpc.id}"
  cidr_block              = "10.20.${length(var.avail_zones) + count.index}.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${element(var.avail_zones, count.index)}"
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "db-subnet-group"
  subnet_ids  = [for sn in aws_subnet.rds_subnet : "${sn.id}"]
}
resource "aws_security_group" "rds_security_group" {
  vpc_id      = "${aws_vpc.app_vpc.id}"
  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.app_sec_group.id}"]
  }
  
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds_database" {
  identifier                = "projectf6-rds"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "8.0.23"
  instance_class            = "db.t2.micro"
  name                      = "${var.DB_DBNAME}"
  username                  = "${var.DB_USERNAME}"
  password                  = "${var.DB_PASSWORD}"
  db_subnet_group_name      = "${aws_db_subnet_group.rds_subnet_group.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds_security_group.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}