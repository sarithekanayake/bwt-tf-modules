resource "aws_iam_role" "nodes" {
  name = "${var.eks_name}-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn    = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role          = aws_iam_role.nodes.name 
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn    = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role          = aws_iam_role.nodes.name 
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  policy_arn    = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role          = aws_iam_role.nodes.name 
}

resource "aws_eks_node_group" "node_group" {
  cluster_name = aws_eks_cluster.eks.name
  version = "${var.eks_version}"
  node_group_name = "worker-node-group"
  node_role_arn = aws_iam_role.nodes.arn

  subnet_ids = var.private_subnet_ids

   capacity_type = "ON_DEMAND"
   instance_types = ["t4g.medium"]
   ami_type = "AL2023_ARM_64_STANDARD"

   scaling_config {
     desired_size = var.desired_size
     max_size     = var.max_size
     min_size     = var.min_size
   }
  update_config {
    max_unavailable = 1
  }

  depends_on = [ 
    aws_iam_role_policy_attachment.ecr_read_only,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.worker_node_policy
  ]
  lifecycle {
    ignore_changes = [ scaling_config[0].desired_size ]
  }
}