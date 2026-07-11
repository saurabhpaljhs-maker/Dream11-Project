variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "devops-mega"
}

variable "instance_type" {
  description = "Master machine size (t2.large as per design)"
  default     = "t2.large"
}

variable "allowed_ssh_cidr" {
  description = "Lock this down to YOUR IP in real usage, e.g. 1.2.3.4/32"
  default     = "0.0.0.0/0"
}
