pipeline {
    agent any

    environment {
        AWS_REGION       = "us-west-2"
        TF_CLOUD_ORG     = "cloudgenius-acme"
        TF_WORKSPACE     = "cicd-using-jenkins-terraform-and-aws"
        TF_API_TOKEN     = credentials('terraform-cloud-token')
        AWS_CREDENTIALS  = credentials('aws-jenkins-creds')
        APP_NAME         = "terraform-eks-app"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    echo '🔍 Initializing Terraform...'
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('infra') {
                    echo '✅ Validating Terraform configuration...'
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    echo '🧩 Running Terraform Plan...'
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform plan -input=false'
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                dir('app') {
                    echo '🛠 Building Docker image...'
                    script {
                        // Get AWS account ID dynamically
                        def accountId = sh(
                            script: "aws sts get-caller-identity --query Account --output text",
                            returnStdout: true
                        ).trim()

                        def ecrRepo = "${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"

                        // Authenticate Docker to ECR
                        sh """
                            aws ecr get-login-password --region ${AWS_REGION} | \
                            docker login --username AWS --password-stdin ${accountId}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        """

                        // Build and push Docker image
                        sh """
                            docker build -t ${ecrRepo}:latest .
                            docker push ${ecrRepo}:latest
                        """
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    echo '🚀 Applying Terraform changes...'
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform apply -auto-approve -input=false'
                    }
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                echo '✅ Deployment completed successfully.'
                sh 'terraform output'
            }
        }
    }

    post {
        success {
            echo '🎉 Pipeline completed successfully.'
        }
        failure {
            echo '❌ Build failed — check console logs.'
        }
    }
}
