variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "devops-mega"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "allowed_ssh_cidr" {
  default = "0.0.0.0/0"
}
