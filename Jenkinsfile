pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        AWS_ACCOUNT_ID = 'YOUR_ACCOUNT_ID'
        TF_API_TOKEN = credentials('terraform-cloud-token')
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app"
        TFC_ORG = "cloudgenius-acme"
        TFC_WORKSPACE = "cicd-using-jenkins-terraform-and-aws"
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
                    echo "🔍 Initializing Terraform..."
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform init -input=false'
                    }
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('infra') {
                    echo "✅ Validating Terraform configuration..."
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    echo "🧩 Running Terraform Plan..."
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform plan -input=false'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    echo "🛠 Building Docker image..."
                    sh '''
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                        docker build -t ${ECR_REPO}:latest .
                        docker push ${ECR_REPO}:latest
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    echo "🚀 Applying Terraform configuration..."
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_API_TOKEN}"]) {
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                echo "🎉 Deployment complete. Infrastructure and Docker image are ready!"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline executed successfully!'
        }
        failure {
            echo '❌ Build failed — check console logs.'
        }
    }
}
