variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidr" {
  type = string
}

variable "private_subnet_cidr" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "eks_node_role_arn" {
  type = string
}

variable "my_ip" {
  description = "Your public IP address (CIDR) for SSH access"
  type        = string
  default     = "0.0.0.0/32"
}

variable "ami_id" {
  type = string
}

variable "public_key_path" {
  description = "Relative path to the SSH public key file under the Terraform root module."
  type        = string
  validation {
    condition     = !(startswith(var.public_key_path, "/") || can(regex("^[A-Za-z]:", var.public_key_path)))
    error_message = "public_key_path must be relative to the Terraform root module, not an absolute path."
  }
}
