#############################
# GLOBAL VARIABLES
#############################

variable "environment_tag" {
  description = "Environment tag"
  default     = "Learn"
}

variable "region" {
  description = "Deployment region"
  default     = "us-east-1"
}

########################################
# KEY PAIR
########################################
variable "PATH_TO_PUBLIC_KEY" {
  description = "Local SSH public key used for EC2 login"
  default     = "../packerkp.pub"
}

########################################
# AMI NAME (from Packer build)
########################################
variable "ami_name" {
  description = "Name of the AMI created by Packer"
  default     = "ami-stack-14"
}
