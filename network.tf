resource "aws_vpc" "auto-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "${var.env}-vpc-auto"
  }
}

resource "aws_subnet" "auto-public-subnet-1" {
  vpc_id     = aws_vpc.auto-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}a"

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-public-subnet-1"
  }
}

resource "aws_subnet" "auto-public-subnet-2" {
  vpc_id     = aws_vpc.auto-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "${var.region}c"

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-public-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.auto-vpc.id

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-igw"
  }
}

resource "aws_default_route_table" "default-rt" {
  default_route_table_id = aws_vpc.auto-vpc.default_route_table_id

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-default-rt"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.auto-vpc.id

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-public-rt"
  }
}

resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.auto-public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.auto-public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "internet-access" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_lb" "lb-1" {
  name               = "${aws_vpc.auto-vpc.tags.Name}-lb-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.auto-public-subnet-1.id, aws_subnet.auto-public-subnet-2.id]

  tags = {
    Environment = var.env
  }
}

resource "aws_lb_listener" "lb-1-http" {
  load_balancer_arn = aws_lb.lb-1.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found - T101 Study"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "auto-tg" {
  name = "${aws_vpc.auto-vpc.tags.Name}-lb-1-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.auto-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 5
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "akbun-albrule" {
  listener_arn = aws_lb_listener.lb-1-http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auto-tg.arn
  }
}

