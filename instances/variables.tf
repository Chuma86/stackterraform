# General Environment Tag
variable "environment_tag" {
  description = "Environment tag"
  default     = "Learn"
}

# AWS Region
variable "region" {
  description = "AWS region for deployment"
  default     = "us-east-1"
}

# Existing VPC ID (already created manually)
variable "vpc_id" {
  description = "Existing VPC ID where instance will be deployed"
  default     = "vpc-0f4f7791ee45bf272"
}

# List of existing subnets
variable "subnets" {
  description = "List of subnets for EC2 placement"
  type        = list(string)
  default = [
    "subnet-06c8b1ff4097e99b9",
    "subnet-03d7aa9975115f22e",
  ]
}

# SSH Public key used for aws_key_pair resource
variable "PATH_TO_PUBLIC_KEY" {
  description = "Path to SSH public key for EC2 login"
  default     = "ses_key.pub"
}

# (Optional) AMI name input from Jenkins/Packer.
# Terraform no longer uses this directly, but keeping it avoids breaking modules.
variable "ami_name" {
  description = "Name of AMI to be built (used by Packer)"
  default     = "ami-stack-14"
}
