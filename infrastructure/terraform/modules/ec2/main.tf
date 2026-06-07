resource "aws_key_pair" "project_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("${path.root}/${var.public_key_path}")
}

resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = aws_key_pair.project_key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-bastion"
  }
}

resource "aws_instance" "devops" {
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.devops_sg_id]
  key_name               = aws_key_pair.project_key.key_name

  iam_instance_profile = var.devops_instance_profile

  tags = {
    Name = "${var.project_name}-devops"
  }
}

resource "aws_instance" "k8s" {
  ami                    = var.ami_id
  instance_type          = "t2.medium"
  subnet_id              = var.private_subnet_id
  vpc_security_group_ids = [var.k8s_sg_id]
  key_name               = aws_key_pair.project_key.key_name

  iam_instance_profile = var.k8s_instance_profile

  tags = {
    Name = "${var.project_name}-k8s"
  }
}

resource "aws_eip" "bastion_eip" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-bastion-eip"
  }
}

resource "aws_eip_association" "bastion_eip_assoc" {
  instance_id   = aws_instance.bastion.id
  allocation_id = aws_eip.bastion_eip.id
}
