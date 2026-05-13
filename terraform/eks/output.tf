output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_ca_certificate" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "eks_cluster_arn" {
  value = aws_eks_cluster.main.arn
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group_role.arn
}

output "eks_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks_oidc.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller_role.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler_role.arn
}
