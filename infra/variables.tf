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
# Key pair name for connecting to the EC2 instance
variable "key_name" {
  description = "The name of the existing EC2 key pair to use for SSH access"
  type        = string
  default     = "acme-key"  # <-- Replace this with your actual AWS key pair name
}

