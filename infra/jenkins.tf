# Lookup the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Jenkins EC2 Instance
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_1.id
  key_name                    = var.key_name
  associate_public_ip_address  = true
  vpc_security_group_ids       = [aws_security_group.jenkins_sg.id]
  user_data                   = file("jenkins/install_jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

# Allocate an Elastic IP to persist public IP
resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  vpc      = true
}

# Output for Jenkins connection
output "jenkins_ip" {
  description = "Public IP of the Jenkins server"
  value       = aws_eip.jenkins_eip.public_ip
}

