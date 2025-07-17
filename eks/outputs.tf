output "endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "ca_data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "name" {
  value = aws_eks_cluster.eks.name
}

output "alb_sg" {
  value = aws_security_group.alb.id
}

output "cluster_sg" {
  value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
}