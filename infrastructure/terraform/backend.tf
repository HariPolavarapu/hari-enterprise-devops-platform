terraform {
  backend "s3" {
    bucket         = "hari-devops-tfstate-996345188008"
    key            = "devops-platform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}