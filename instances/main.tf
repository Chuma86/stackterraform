########################################
# TERRAFORM + PROVIDERS
########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.74.0"
    }
  }
}

provider "aws" {
  region = var.region
}

########################################
# DEFAULT VPC + DEFAULT SUBNETS
########################################

# Automatically detect the default VPC
data "aws_vpc" "default" {
  default = true
}

# Automatically detect all default subnets inside the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

########################################
# SSH KEY PAIR
########################################

resource "aws_key_pair" "Stack_KP" {
  key_name   = "packerkp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

########################################
# SECURITY GROUP
########################################

resource "aws_security_group" "sg_22_80" {
  name        = "stack-sg"
  description = "Allow SSH, HTTP, Web traffic"
  vpc_id      = data.aws_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # App port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################################
# DYNAMIC AMI DISCOVERY (NEWEST Packer AMI)
########################################

data "aws_ami" "stack" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-stack-*"]
  }
}

########################################
# EC2 INSTANCE
########################################

resource "aws_instance" "application_server" {
  ami                         = data.aws_ami.stack.id
  instance_type               = "t2.micro"
  subnet_id                   = data.aws_subnets.default.ids[0]
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.Stack_KP.key_name

  tags = {
    Name = "Test_Instance"
    Environment = var.environment_tag
  }
}

########################################
# OUTPUTS
########################################

output "public_ip" {
  description = "EC2 public IP address"
  value       = aws_instance.application_server.public_ip
}

output "ami_used" {
  description = "AMI ID used for EC2 instance"
  value       = data.aws_ami.stack.id
}
