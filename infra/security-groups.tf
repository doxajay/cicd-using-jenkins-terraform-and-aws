# security-groups.tf
# (All Jenkins-related rules have been removed, since they're defined in jenkins.tf)

# Example: Security group for EKS nodes (if you have EKS configured)
resource "aws_security_group" "eks_sg" {
  name        = "eks-sg"
  description = "Allow EKS cluster communication"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-sg"
  }
}
