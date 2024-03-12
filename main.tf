# Define provider
provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = var.CIDR
  tags = {
    Name = "${var.tag_name}-vpc"
  }
}

# Create subnets within the VPC
resource "aws_subnet" "Subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet_cidr
  tags = {
    Name = "${var.tag_name}-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.tag_name}-igw"
  }
}

# Create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "${var.tag_name}-rt"
  }
}

# Associate subnets with the route table
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.Subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# Create a security group
resource "aws_security_group" "my_sg" {
  name        = var.sg_name
  description = "Allowing inbound and outbound rules through terraform"
  vpc_id      = aws_vpc.my_vpc.id

  # Allow inbound rules
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  # Allow outbound rule
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
  tags = {
    Name = "${var.tag_name}-sg"
  }
}

# Create a key pair
resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.my_key_pair.public_key_openssh
}

# Generate a private key
resource "tls_private_key" "my_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_s3_bucket_object" "private_key_object" {
  bucket  = var.bucket_name
  key     = "${var.bucket_path}/${var.key_pair_name}.pem"
  content = tls_private_key.my_key_pair.private_key_pem
}

# Provision an EC2 instance
resource "aws_instance" "my_ec2_instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = aws_subnet.Subnet.id
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.my_sg.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y nginx
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF
  tags = {
    Name = "${var.tag_name}-VM"
  }
}