#############################################
# Jenkins EC2 Instance with Elastic IP
#############################################

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

#############################################
# Jenkins EC2 Instance
#############################################

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.small"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
  key_name               = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install java-openjdk17 -y
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
              yum install jenkins git -y
              systemctl enable jenkins
              systemctl start jenkins
              EOF

  tags = {
    Name = "jenkins-server"
  }
}

#############################################
# Elastic IP for Jenkins
#############################################

resource "aws_eip" "jenkins_eip" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "jenkins-eip"
  }
}

#############################################
# Outputs
#############################################

output "jenkins_ip" {
  value = aws_eip.jenkins_eip.public_ip
}

output "jenkins_url" {
  value = "http://${aws_eip.jenkins_eip.public_ip}:8080"
}
