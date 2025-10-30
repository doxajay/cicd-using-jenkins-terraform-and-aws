# =============================
# JENKINS EC2 INSTANCE SETUP
# =============================

# Lookup latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Jenkins Security Group (open port 8080 + SSH)
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP (Jenkins UI)"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
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
    Name = "jenkins-sg"
  }
}

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type                = "t3.small"
  subnet_id                    = aws_subnet.public_1.id
  vpc_security_group_ids       = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address  = true
  key_name                     = var.key_name

  # Jenkins install script (placed inside /infra/jenkins/install_jenkins.sh)
  user_data = file("${path.module}/jenkins/install_jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

# Allocate Elastic IP to Jenkins instance
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "jenkins-eip"
  }
}

# =============================
# OUTPUTS
# =============================
output "jenkins_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

output "jenkins_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}
