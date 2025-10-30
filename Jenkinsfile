pipeline {
    agent any

    environment {
        TF_CLOUD_ORG = "cloudgenius-acme"
        TF_WORKSPACE = "cicd-using-jenkins-terraform-and-aws"
        TF_API_TOKEN = credentials('terraform-cloud-token')
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git'
            }
        }

        stage('Terraform Init') {
            steps {
                sh '''
                terraform login || true
                terraform init -input=false
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -input=false -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                input message: 'Approve apply?', ok: 'Deploy'
                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }

        stage('Post-Deployment Info') {
            steps {
                sh 'terraform output'
            }
        }
    }

    post {
        success { echo '✅ Terraform infrastructure deployed successfully!' }
        failure { echo '❌ Build failed — check console logs.' }
    }
}
