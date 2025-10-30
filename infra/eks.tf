resource "aws_eks_cluster" "main" {
  name     = "acme-eks-jenkins-cluster"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [aws_subnet.public_1.id]
  }
  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}
