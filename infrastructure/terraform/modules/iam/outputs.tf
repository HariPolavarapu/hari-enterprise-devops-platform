output "devops_instance_profile" {
  value = aws_iam_instance_profile.devops_profile.name
}

output "k8s_instance_profile" {
  value = aws_iam_instance_profile.k8s_profile.name
}
