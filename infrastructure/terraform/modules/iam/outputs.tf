output "devops_instance_profile" {
  value = aws_iam_instance_profile.devops_profile.name
}

output "k8s_instance_profile" {
  value = aws_iam_instance_profile.k8s_profile.name
}

output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node.arn
}
