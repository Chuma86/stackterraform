########################################
# TERRAFORM + PROVIDERS
########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.7.0"
    }
  }
}

provider "aws" {
  region = var.region
}


########################################
# VPC + SUBNETS (Explicit IDs)
########################################

variable "vpc_id" {
  default = "vpc-09edcedf8bbad9437"
}

variable "subnet_id" {
  default = "subnet-0a789c54747685b25"
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
  vpc_id      = var.vpc_id

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
  owners      = ["982455489062"]
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
  subnet_id                   = var.subnet_id
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
