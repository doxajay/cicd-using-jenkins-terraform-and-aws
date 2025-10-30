pipeline {
    agent any

    environment {
        TF_API_TOKEN = credentials('terraform-cloud-token')  // Jenkins secret
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
                    echo "🔍 Checking if Terraform token is set..."
                    sh 'echo $TF_API_TOKEN | wc -c'

                    // ✅ Export the token to Terraform expected variable name
                    sh '''
                        export TF_TOKEN_app_terraform_io=$TF_API_TOKEN
                        terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh '''
                        export TF_TOKEN_app_terraform_io=$TF_API_TOKEN
                        terraform plan -input=false -out=tfplan
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('infra') {
                    sh '''
                        export TF_TOKEN_app_terraform_io=$TF_API_TOKEN
                        terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                dir('infra') {
                    sh 'terraform output || true'
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
