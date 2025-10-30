# ===================================================
# Variables for Terraform Cloud workspace
# ===================================================

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access resources"
  type        = string
  default     = "0.0.0.0/0"
}
