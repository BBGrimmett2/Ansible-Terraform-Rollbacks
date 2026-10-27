terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Local backend for demo simplicity - no state file complexity
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "terraform-rollback-demo"
      ManagedBy   = "Terraform"
      Environment = "demo"
    }
  }
}

# Data source to get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.instance_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "${var.instance_name}-igw"
  }
}

# Subnet
resource "aws_subnet" "demo_subnet" {
  vpc_id                  = aws_vpc.demo_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.instance_name}-subnet"
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Route Table
resource "aws_route_table" "demo_rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }

  tags = {
    Name = "${var.instance_name}-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "demo_rta" {
  subnet_id      = aws_subnet.demo_subnet.id
  route_table_id = aws_route_table.demo_rt.id
}

# Security Group
resource "aws_security_group" "demo_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for Terraform rollback demo"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    description = "SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

# Null resource to simulate failure for demo purposes
resource "null_resource" "simulate_failure" {
  count = var.simulate_tf_failure ? 1 : 0

  provisioner "local-exec" {
    command = "exit 1"
  }

  depends_on = [
    aws_vpc.demo_vpc,
    aws_subnet.demo_subnet,
    aws_security_group.demo_sg
  ]
}

# EC2 Instance
resource "aws_instance" "demo_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.demo_subnet.id
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = {
    Name = var.instance_name
  }

  # Ensure this only creates after failure simulation (if enabled) would have failed
  depends_on = [null_resource.simulate_failure]
}
