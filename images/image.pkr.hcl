variable "aws_source_ami" {
  default = "al2023-ami-2023*-x86_64"
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "ami_name" {
  default = "ami-stack-14"
}

variable "component" {
  default = "clixx"
}

# All enterprise accounts (DEV, AUT, TEST, PROD, MAN)
variable "aws_accounts" {
  type    = list(string)
  default = ["591136340867","646082657258","634888936851","238884806751","982455489062"]
}

variable "ami_regions" {
  type    = list(string)
  default = ["us-east-1"]
}

variable "aws_region" {
  default = "us-east-1"
}

data "amazon-ami" "source_ami" {
  filters = {
    name = var.aws_source_ami
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region
}

############################################################
# SOURCE BLOCK — AMI BUILD (NO DELETION, NO OVERWRITE)
############################################################
source "amazon-ebs" "amazon_ebs" {

  # REUSE SAME AMI NAME — AWS will automatically create a new AMI ID
  ami_name  = var.ami_name

  # DO NOT delete or deregister older AMIs
  force_deregister      = false
  force_delete_snapshot = false

  ami_regions    = var.ami_regions
  ami_users      = var.aws_accounts
  snapshot_users = var.aws_accounts

  region        = var.aws_region
  source_ami    = data.amazon-ami.source_ami.id
  instance_type = var.aws_instance_type
  ssh_username  = "ec2-user"
  ssh_timeout   = "5m"
  ssh_pty       = true

  # REQUIRED — tells Packer when the build is finished
  shutdown_command = "sudo shutdown -h now"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    delete_on_termination = true
    volume_size           = 10
    volume_type           = "gp2"
    encrypted             = false
  }
}

############################################################
# BUILD BLOCK
############################################################
build {
  sources = ["source.amazon-ebs.amazon_ebs"]

  provisioner "shell" {
    script = "../scripts/setup.sh"
  }
}
