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

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.auto-public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route" "internet-access" {
  route_table_id         = aws_route_table.public-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}