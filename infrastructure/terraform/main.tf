module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

# Security groups (inlined from modules/security-groups)
resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-devops-sg"
  description = "Security group for DevOps VM"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from my laptop"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-devops-sg"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Postgres from DevOps VM"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
}

module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name

  ami_id = var.ami_id

  private_subnet_id = module.vpc.private_subnet_ids[0]

  devops_sg_id = aws_security_group.devops_sg.id

  devops_instance_profile = module.iam.devops_instance_profile

  public_key_path = var.public_key_path
}

module "eks" {
  source = "./modules/eks"

  project_name         = var.project_name
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  eks_node_role_arn    = module.iam.eks_node_role_arn
  private_subnet_ids   = module.vpc.private_subnet_ids
  depends_on           = [module.iam]
}

module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "rds" {
  source = "./modules/rds"

  project_name       = var.project_name
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = aws_security_group.rds_sg.id
  database_username  = var.database_username
  database_password  = var.database_password
}

module "route53" {
  source = "./modules/route53"

  vpc_id             = module.vpc.vpc_id
  jenkins_private_ip = module.ec2.jenkins_private_ip
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
}
