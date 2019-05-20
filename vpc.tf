resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "default"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet_cidr}"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = true

  tags {
    Name = "public"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.private_subnet_cidr}"
  availability_zone = "us-west-2b"

  tags {
    Name = "private"
  }
}

resource "aws_internet_gateway" "natgw" {
  vpc_id = "${aws_vpc.default.id}"

  tags {
    Name = "NAT IGW"
  }
}

resource "aws_default_route_table" "default" {
    default_route_table_id = "${aws_vpc.default.default_route_table_id}"

route {
    cidr_block = "0.0.0.0/0"
    instance_id = "${aws_instance.nat.id}"
}

  tags {
    Name = "Default RT"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = "${aws_subnet.private-subnet.id}"
  route_table_id = "${aws_default_route_table.default.id}"
}


resource "aws_route_table" "publicsub" {
  vpc_id = "${aws_vpc.default.id}"

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.natgw.id}"
} 

  tags {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table_association" "publicsub" {
  subnet_id = "${aws_subnet.public-subnet.id}"
  route_table_id = "${aws_route_table.publicsub.id}"
}

resource "aws_security_group" "natsg" {
  name        = "natsg"
  description = "SG for NAT instance"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "test" {
  name        = "test"
  description = "SG for test instance"
  vpc_id = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
