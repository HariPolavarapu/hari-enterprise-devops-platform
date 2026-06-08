resource "aws_security_group" "windows_jump_server_sg" {
  name        = "${var.project_name}-windows-jump-server-sg"
  description = "Security group for Windows Jump Server"
  vpc_id      = var.vpc_id

  ingress {
    description = "RDP from my laptop"
    from_port   = 3389
    to_port     = 3389
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
    Name = "${var.project_name}-windows-jump-server-sg"
  }
}

resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-devops-sg"
  description = "Security group for DevOps VM"
  vpc_id      = var.vpc_id

  ingress {
    description     = "SSH from Windows Jump Server"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.windows_jump_server_sg.id]
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
  vpc_id      = var.vpc_id

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
  vpc_id      = var.vpc_id

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