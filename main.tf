terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.33.0"
    }
  }
}


provider "aws" {
  region = "ap-south-1"
}

# ------------------------------------
# 1. Create VPC
# ------------------------------------
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# ------------------------------------
# 2. Create Internet Gateway
# ------------------------------------
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my-igw"
  }
}

# ------------------------------------
# 3. Public Subnet
# ------------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true

  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-subnet"
  }
}

# ------------------------------------
# 4. Route Table
# ------------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# ------------------------------------
# 5. Associate subnet with the route table
# ------------------------------------
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------
# 6. Security Group
# ------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# ------------------------------------
# 7. Create EC2 Instance in Public Subnet
# ------------------------------------
resource "aws_instance" "my-server" {
  ami           = "ami-0f5ee92e2d63afc18"   # Amazon Linux 2 (ap-south-1)
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  key_name = "mat125"   # Replace with your existing key pair name

  
 tags = {
    Name = "my-server"
  }
}

