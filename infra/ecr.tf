resource "aws_ecr_repository" "app_repo" {
  name                 = "acme-app-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
  tags = { Name = "acme-app-repo" }
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
