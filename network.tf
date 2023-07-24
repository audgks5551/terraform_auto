resource "aws_vpc" "auto-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${var.env}-vpc-auto"
  }
}

resource "aws_subnet" "auto-public-subnet-1" {
  vpc_id     = aws_vpc.auto-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-auto-public-subnet-1"
  }
}