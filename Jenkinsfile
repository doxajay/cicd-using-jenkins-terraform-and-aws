pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-2"
        TF_CLOUD_ORG = "cloudgenius-acme"
        TF_WORKSPACE = "cicd-using-jenkins-terraform-and-aws"
        TF_TOKEN_app_terraform_io = credentials('tf-api-token')
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
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_TOKEN_app_terraform_io}"]) {
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
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_TOKEN_app_terraform_io}"]) {
                        sh 'terraform plan -input=false'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    echo "🛠 Building Docker image..."
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-creds']]) {
                        sh '''
                            AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                            docker build -t terraform-eks-app .
                            docker tag terraform-eks-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest
                            docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest
                        '''
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    echo "🚀 Applying Terraform configuration..."
                    withEnv(["TF_TOKEN_app_terraform_io=${TF_TOKEN_app_terraform_io}"]) {
                        input message: 'Approve deployment?', ok: 'Deploy'
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                dir('infra') {
                    echo "🌐 Deployment complete!"
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Build failed — check console logs.'
        }
    }
}
