# Infrastructure as Code (IaC) Terraform Modules

This repository contains reusable Terraform modules for provisioning AWS infrastructure in a version-controlled manner.
`Latest version: v1.4.1`

## Modules

- **VPC**: 
  - Creates a Virtual Private Cloud with public and private subnets, route tables, NAT Gateway, and Internet Gateway.
  - Adding EKS required tags to the subnets.

- **EKS**: 
  - Provisions EKS cluster, worker nodes and ALB SG to host Application workload.
  - Setup EKS cluster add-ons: kube-proxy, pod-identity, vpc-cni, core-dns, external-dns.
  - Installs AWS Loadbalancer Controller.

- **DNS**:
  - Creates a Public Hosted Zone for the domain in Route53.
  - Requests a SSL certificate for the domain.
  - Adds the CNAME record in Route53 for SSL validation.

- **ECR**: Creates an ECR repository to host Docker images. This module is obsolete as ECR creation has been moved to `bootstrap.yaml` CloudFormation template.

## Usage

Each module can be integrated into Terraform configuration by specifying its source. 
Example:

```hcl
module "eks" {

  source = "git::https://github.com/sarithekanayake/bwt-tf-modules.git//eks?ref=v1.4.1"

  env                =  "prod"
  vpc_id             =  "vpc-0123456789abcdefg"
  private_subnet_ids =  ["subnet-0123456789abcdefg","subnet-abcdefg0123456789"]
  public_subnet_ids  =  ["subnet-0123456789hijklmn","subnet-hijklmn0123456789"]
  
  eks_name           =  "bwt-eks"
  eks_version        =  "1.33"

  #worker node specs
  desired_size       =  2
  max_size           =  5
  min_size           =  1

  aws_lbc_version    = "1.9.2"

}
```