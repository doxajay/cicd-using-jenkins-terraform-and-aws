output "vpc_id"           { value = aws_vpc.main.id }
output "public_subnet_id" { value = aws_subnet.public_1.id }
output "jenkins_ip"       { value = aws_instance.jenkins.public_ip }
output "ecr_repo"         { value = aws_ecr_repository.app_repo.repository_url }
