variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "devops-mega"
}

variable "cluster_name" {
  default = "devops-mega-eks"
}

variable "k8s_version" {
  default = "1.29"
}

variable "node_instance_type" {
  default = "t3.medium"
}
