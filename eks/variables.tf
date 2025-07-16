variable "env" {}
variable "vpc_id" {}
variable "private_subnet_ids" {}
variable "public_subnet_ids" {}
variable "eks_name" {}
variable "eks_version" {}

variable "desired_size" {
  type = number
  description = "Desired Worker nodes"
  default = 1
}

variable "max_size" {
  type = number
  description = "Max Worker nodes"
  default = 2
}

variable "min_size" {
  type = number
  description = "Min Worker nodes"
  default = 1
}

variable "aws_lbc_version" {
  type = string
  description = "Helm chart version of AWS Load Balancer Controller"
  default = "1.9.2"
}