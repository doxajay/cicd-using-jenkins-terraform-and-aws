pipeline {
    agent any

    environment {
        TF_API_TOKEN = credentials('terraform-cloud-token')  // Jenkins secret with your Terraform Cloud token
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git'
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    echo "Checking if Terraform token is set..."
                    sh 'echo $TF_API_TOKEN | wc -c'
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                dir('infra') {
                    sh 'terraform output'
                }
            }
        }
    }

    post {
        success {
            echo '✅ Terraform infrastructure deployed successfully!'
        }
        failure {
            echo '❌ Build failed — check console logs.'
        }
    }
}
