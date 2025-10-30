pipeline {
    agent any

    environment {
        AWS_REGION     = 'us-west-2'
        TF_API_TOKEN   = credentials('tf-api-token')
        AWS_CREDS      = credentials('aws-access-key')
        ACCOUNT_ID     = sh(script: "aws sts get-caller-identity --query Account --output text", returnStdout: true).trim()
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git',
                    credentialsId: 'github-token'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    echo "🔍 Initializing Terraform..."
                    sh '''
                      export TF_TOKEN_app_terraform_io=${TF_API_TOKEN}
                      terraform init -input=false
                    '''
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
                    sh '''
                      export TF_TOKEN_app_terraform_io=${TF_API_TOKEN}
                      terraform plan -input=false
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🛠 Building Docker image..."
                sh '''
                  aws ecr get-login-password --region ${AWS_REGION} | \
                  docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                  
                  docker build -t ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest .
                  docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest
                '''
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    echo "🚀 Applying Terraform configuration..."
                    sh '''
                      export TF_TOKEN_app_terraform_io=${TF_API_TOKEN}
                      terraform apply -auto-approve -input=false
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Build and deployment successful!"
        }
        failure {
            echo "❌ Build failed — check console logs."
        }
    }
}
