output "windows_jump_server_public_ip" {
  value = aws_eip.windows_jump_server_eip.public_ip
}

output "devops_private_ip" {
  value = aws_instance.devops.private_ip
}

output "k8s_private_ip" {
  value = aws_instance.k8s.private_ip
}
