resource "aws_iam_role" "devops_role" {
  name = "${var.project_name}-devops-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-devops-role"
  }
}

resource "aws_iam_role_policy_attachment" "devops_ecr" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "devops_cloudwatch" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "devops_ssm" {
  role       = aws_iam_role.devops_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "devops_profile" {
  name = "${var.project_name}-devops-profile"
  role = aws_iam_role.devops_role.name
}

resource "aws_iam_role" "k8s_role" {
  name = "${var.project_name}-k8s-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-k8s-role"
  }
}

resource "aws_iam_role_policy_attachment" "k8s_ecr" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_role_policy_attachment" "k8s_cloudwatch" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "k8s_ssm" {
  role       = aws_iam_role.k8s_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k8s_profile" {
  name = "${var.project_name}-k8s-profile"
  role = aws_iam_role.k8s_role.name
}
