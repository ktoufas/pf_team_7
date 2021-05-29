resource "aws_security_group" "alb_sec_group" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = "${aws_vpc.app_vpc.id}"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create a new load balancer
resource "aws_alb" "app_alb" {
  name = "${var.env_name}-app-alb"
  security_groups = [aws_security_group.alb_sec_group.id]
  subnets         = ["${aws_subnet.public_subnet[0].id}","${aws_subnet.public_subnet[1].id}"]
  tags = {
    Environment = "${var.env_name}"
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "${var.env_name}-alb-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app_vpc.id}"
  target_type = "instance"
  stickiness {
    type = "lb_cookie"
  }
  # Alter the destination of the health check to be the main. page.
  health_check {
    path = "/index.html"
    port = 80
  }
}

resource "aws_lb_target_group_attachment" "alb_reg_targets" {
  count = length(aws_instance.app_servers)
  target_group_arn = aws_alb_target_group.alb_target_group.arn
  target_id        = "${aws_instance.app_servers[count.index].id}"
  port             = 80
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = "${aws_alb.app_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

output "alb_dns_name" {
  value = aws_alb.app_alb.dns_name  
}