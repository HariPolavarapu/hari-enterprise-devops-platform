resource "aws_ecr_repository" "frontend" {
  name = "frontend-angular"
}

resource "aws_ecr_repository" "employee_service" {
  name = "employee-java-service"
}

resource "aws_ecr_repository" "notification_service" {
  name = "notification-python-service"
}

resource "aws_ecr_repository" "payroll_service" {
  name = "payroll-dotnet-service"
}
