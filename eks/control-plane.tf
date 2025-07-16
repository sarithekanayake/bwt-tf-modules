resource "aws_iam_role" "eks" {
  name = "${var.eks_name}-eks-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
    policy_arn  = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role        = aws_iam_role.eks.name
}

resource "aws_eks_cluster" "eks" {
    name = "${var.eks_name}"
    version = "${var.eks_version}"
    role_arn = aws_iam_role.eks.arn
    vpc_config {
      endpoint_private_access = false
      endpoint_public_access = true

      subnet_ids = var.private_subnet_ids
    }
    access_config {
      authentication_mode = "API"
      bootstrap_cluster_creator_admin_permissions = true
    }
    depends_on = [ aws_iam_role_policy_attachment.eks ]
}