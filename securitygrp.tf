# mgmt Security group
 resource "aws_security_group" "mgmt-security-group" {
  name        = "mgmt-secgrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id 

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr]
  }

  tags = {
    Name = "mgmt-secgrp"
  }
 }

# Security group for Web 
 resource "aws_security_group" "web-security-group" {
  name        = "web-secgrp"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id 

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr]
  }

  tags = {
    Name = "web-secgrp"
  }
}