resource "aws_key_pair" "project_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.root}/${var.public_key_path}")
}

# =========================================================
# JENKINS / DEVOPS EC2 INSTANCE
# =========================================================

resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = "t3.small"

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.devops_sg_id]

  key_name = aws_key_pair.project_key.key_name

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  iam_instance_profile = var.devops_instance_profile

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}