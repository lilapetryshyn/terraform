resource "aws_key_pair" "default" {
  key_name = "ec2"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_instance" "nat" {
   ami  = "ami-0032ea5ae08aa27a2"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.public-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.natsg.id}"]
   associate_public_ip_address = true
   source_dest_check = false

  tags {
    Name = "nat"
  }
}

resource "aws_instance" "test" {
   ami  = "ami-6cd6f714"
   instance_type = "t2.micro"
   key_name = "${aws_key_pair.default.id}"
   subnet_id = "${aws_subnet.private-subnet.id}"
   vpc_security_group_ids = ["${aws_security_group.test.id}"]

  tags {
    Name = "test"
  }
}



