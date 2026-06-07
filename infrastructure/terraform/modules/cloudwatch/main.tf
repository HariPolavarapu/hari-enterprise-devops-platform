resource "aws_cloudwatch_log_group" "devops" {
  name              = "/aws/devops-vm"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "k8s" {
  name              = "/aws/k8s-vm"
  retention_in_days = 7
}
