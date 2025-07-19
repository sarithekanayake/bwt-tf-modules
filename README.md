# BreakWater Technology Infrastructure as Code (IaC) Terraform Modules

This repository contains reusable Terraform modules for provisioning AWS infrastructure in a version-controlled manner.
`Latest version: v1.5.0`

## Modules

- **VPC**: Creates a Virtual Private Cloud with public and private subnets, route tables, NAT Gateway, Internet Gateway and adding EKS required tags to the subnets.
  - Will create private subnets and public subnets in different AZ. It dynamically provisions the number of subnets based on the value we provide. (in this example, 4 subnets. Max 4) 4. Subnet CIDR calculation is done using the terraform function cidrsubnet()
  - AZ selection is also done using the modulus terraform operator.
  - Routing tables will be created (private, public)
  - NAT GW to route private instance traffic to the internet. 
  - Available AZs in the region will be retrieved using a data block. 

- **EKS**: Provisions EKS cluster, worker nodes and ALB Security Group to host Application workload.
  - Uses AWS managed instances to run the workloads
  - AWS Graviton instances (t4g.small) are using as it offer a balance of performance and cost-effectiveness
  - Amazon Linux 2023 ARM64 based AMI is used as Graviton instances runs on ARM64 platform
  - Setup EKS cluster add-ons: kube-proxy, pod-identity, vpc-cni, core-dns, external-dns
  - Installs AWS Loadbalancer Controller. AWS LBC will handle the ALB creation and exposing the application
  - Installs Kubernetes Cluster Autoscaler. AWS uses an Auto Scaling Group to manage the worker nodes. Based on the resource consumption of the nodes, the Cluster Autoscaler automatically scales the number of worker nodes in or out.
  - Creates ALB Security group with port 443, 80 from 0.0.0.0/0

- **DNS**:
  - Creates a Public Hosted Zone for the domain in Route53.
  - Requests a SSL certificate for the domain.
  - Adds the CNAME record in Route53 for SSL validation.

- **ECR**: Creates an ECR repository to host Docker images. This module is obsolete as ECR creation has been moved to `bootstrap.yaml` CloudFormation template.

## Usage

Each module can be integrated into Terraform configuration by specifying its source. 

```hcl
module "eks" {

  source = "git::https://github.com/sarithekanayake/bwt-tf-modules.git//eks?ref=v1.5.0"

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

}
```