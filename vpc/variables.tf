variable "env" {}
variable "vpc_cidr_block" {
  description = "CIDR Range for VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "eks_name" {}

variable "no_of_pri_subs" {
  description = "Number of private subnets need (Max. 2)"
  type = number
  default = 2
}

variable "no_of_pub_subs" {
  description = "Number of public subnets need (Max. 2)"
  type = number
  default = 2
}