variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least two public subnet CIDRs are required."
  }
}

variable "private_subnet_cidrs" {
  type = list(string)
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least two private subnet CIDRs are required."
  }
}

variable "availability_zones" {
  type = list(string)
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least two availability zones are required."
  }
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

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}
