variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "allowed_cidr" {
  description = "Allowed inbound CIDR"
  type        = string
  default     = "0.0.0.0/0"
}
