resource "aws_security_group" "auto_sg" {
  name        = "${aws_vpc.auto-vpc.tags.Name}-auto-sg"
  vpc_id      = aws_vpc.auto-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-auto-sg"
  }
}

resource "aws_security_group" "lb_sg" {
  name        = "${aws_vpc.auto-vpc.tags.Name}-lb-sg"
  vpc_id      = aws_vpc.auto-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${aws_vpc.auto-vpc.tags.Name}-lb-sg"
  }
}