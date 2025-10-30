pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-2"
        AWS_ACCOUNT_ID = "YOUR_ACCOUNT_ID"
        TF_API_TOKEN = credentials('terraform-token')
        AWS_CREDS = credentials('aws-creds')
        PATH = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    sh '''
                    echo "🔍 Initializing Terraform..."
                    terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('infra') {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh '''
                    echo "🧩 Running Terraform Plan..."
                    terraform plan -input=false
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return env.BRANCH_NAME == 'main' }
            }
            steps {
                dir('infra') {
                    sh '''
                    echo "🚀 Applying Terraform changes..."
                    terraform apply -auto-approve -input=false
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds'
                    ]]) {
                        sh '''
                        echo "🛠 Building Docker image..."
                        aws ecr get-login-password --region ${AWS_REGION} | \
                          docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest .
                        docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/terraform-eks-app:latest
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Build failed — check console logs."
        }
    }
}
