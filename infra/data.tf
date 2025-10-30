resource "aws_ebs_volume" "jenkins_data" {
  availability_zone = "us-west-2a" # change to match your instance AZ
  size              = 10
  type              = "gp3"
  tags = {
    Name = "jenkins-data"
  }
}
