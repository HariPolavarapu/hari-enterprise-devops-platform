resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-db-subnet-group"

  subnet_ids = [
    var.private_subnet_id
  ]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier          = "${var.project_name}-postgres"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20

  username            = "postgres"
  password            = "Password123!"

  publicly_accessible = false
  skip_final_snapshot = true

  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.project_name}-postgres"
  }
}
