output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_frontend_repository_url" {
  value = module.ecr.frontend_repo_url
}

output "postgres_endpoint" {
  value     = module.rds.postgres_endpoint
  sensitive = true
}
