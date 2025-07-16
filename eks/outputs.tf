output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "ca_data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "name" {
  value = aws_eks_cluster.eks.name
}