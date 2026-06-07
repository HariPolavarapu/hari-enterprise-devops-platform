module "vpc" {
  source = "./modules/vpc"

  project_name        = var.project_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
}

# Security groups (inlined from modules/security-groups)
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for Bastion Host"
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
    Name = "${var.project_name}-bastion-sg"
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-devops-sg"
  description = "Security group for DevOps VM"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
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

resource "aws_security_group" "k8s_sg" {
  name        = "${var.project_name}-k8s-sg"
  description = "Security group for Kubernetes VM"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH from DevOps VM"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.devops_sg.id]
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
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
    Name = "${var.project_name}-k8s-sg"
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

  ingress {
    description     = "Postgres from Kubernetes VM"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.k8s_sg.id]
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

  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id

  bastion_sg_id = aws_security_group.bastion_sg.id
  devops_sg_id  = aws_security_group.devops_sg.id
  k8s_sg_id     = aws_security_group.k8s_sg.id

  devops_instance_profile = module.iam.devops_instance_profile
  k8s_instance_profile    = module.iam.k8s_instance_profile

  public_key_path = var.public_key_path
}
module "ecr" {
  source = "./modules/ecr"

  project_name = var.project_name
}

module "rds" {
  source = "./modules/rds"

  project_name      = var.project_name
  private_subnet_id = module.vpc.private_subnet_id
  rds_sg_id         = aws_security_group.rds_sg.id
}

module "route53" {
  source            = "./modules/route53"

  vpc_id            = module.vpc.vpc_id
  devops_private_ip = module.ec2.devops_private_ip
  k8s_private_ip    = module.ec2.k8s_private_ip
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"

  project_name = var.project_name
}
