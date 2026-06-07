output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "devops_sg_id" {
  value = aws_security_group.devops_sg.id
}

output "k8s_sg_id" {
  value = aws_security_group.k8s_sg.id
}

output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}