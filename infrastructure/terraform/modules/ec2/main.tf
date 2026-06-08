resource "aws_key_pair" "project_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.root}/${var.public_key_path}")
}

# =========================================================
# WINDOWS JUMP SERVER
# =========================================================

resource "aws_instance" "windows_jump_server" {

  ami                    = "ami-0fc682b2a42e57ca2"
  instance_type          = "t3.medium"

  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.windows_jump_server_sg_id]

  associate_public_ip_address = true

  key_name = aws_key_pair.project_key.key_name

  tags = {
    Name = "${var.project_name}-windows-jump-server"
  }
}

# =========================================================
# DEVOPS VM
# =========================================================

resource "aws_instance" "devops" {

  ami                    = var.ami_id
  instance_type          = "t2.medium"

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.devops_sg_id]

  key_name = aws_key_pair.project_key.key_name

  iam_instance_profile = var.devops_instance_profile

  tags = {
    Name = "${var.project_name}-devops"
  }
}

# =========================================================
# KUBERNETES VM
# =========================================================

resource "aws_instance" "k8s" {

  ami                    = var.ami_id
  instance_type          = "t2.medium"

  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.k8s_sg_id]

  key_name = aws_key_pair.project_key.key_name

  iam_instance_profile = var.k8s_instance_profile

  tags = {
    Name = "${var.project_name}-k8s"
  }
}

# =========================================================
# ELASTIC IP
# =========================================================

resource "aws_eip" "windows_jump_server_eip" {

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-windows-jump-server-eip"
  }
}

resource "aws_eip_association" "windows_jump_server_eip_assoc" {

  instance_id   = aws_instance.windows_jump_server.id
  allocation_id = aws_eip.windows_jump_server_eip.id
}