resource "aws_eks_addon" "kube-proxy" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "kube-proxy"
  addon_version = "v1.33.0-eksbuild.2"
  depends_on = [ aws_eks_node_group.node_group ]
}

resource "aws_eks_addon" "pod-identity" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "v1.1.0-eksbuild.1"

  depends_on = [ aws_eks_addon.kube-proxy ]
}


resource "aws_iam_role" "vpc_cni" {
  name               = "AmazonEKSPodIdentityAmazonVPCCNIRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_eks_addon" "vpc-cni" {
  cluster_name = var.eks_name
  addon_name   = "vpc-cni"
  addon_version = "v1.19.5-eksbuild.1"
  pod_identity_association {
    role_arn = aws_iam_role.vpc_cni.arn
    service_account = "aws-node"
  }
  depends_on = [ aws_iam_role_policy_attachment.vpc_cni, aws_eks_addon.pod-identity ]
  
}

resource "aws_eks_addon" "core-dns" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "coredns"
  addon_version = "v1.12.1-eksbuild.2"

  depends_on = [ aws_eks_addon.vpc-cni ]
}

resource "aws_eks_addon" "metrics-server" {
  cluster_name = aws_eks_cluster.eks.name
  addon_name   = "metrics-server"
  addon_version = "v0.8.0-eksbuild.1"

  depends_on = [ aws_eks_addon.vpc-cni ]
}


##### External DNS Ad-on #############
resource "aws_iam_role" "ex_dns" {
  name               = "AmazonEKSPodIdentityExternalDNSRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ex_dns" {
  role       = aws_iam_role.ex_dns.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_eks_addon" "external_dns" {
  cluster_name = var.eks_name
  addon_name   = "external-dns"
  addon_version = "v0.18.0-eksbuild.1"
  pod_identity_association {
    role_arn = aws_iam_role.ex_dns.arn
    service_account = "external-dns"
  }
  depends_on = [ aws_eks_addon.vpc-cni ]
  
}