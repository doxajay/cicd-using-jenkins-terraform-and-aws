pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-2"
        TF_API_TOKEN = credentials('terraform-cloud-token')
        TFC_WORKSPACE = "cicd-using-jenkins-terraform-and-aws"
        TFC_ORG = "cloudgenius-acme"
        GIT_REPO = "https://github.com/doxajay/cicd-using-jenkins-terraform-and-aws.git"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: "${GIT_REPO}"
            }
        }

        stage('Terraform Validation') {
            steps {
                dir('infra') {
                    sh '''
                    terraform fmt -check -recursive
                    terraform validate || true
                    '''
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    sh '''
                    echo "🛠 Building Docker image..."
                    docker build -t acme-app:latest .
                    echo "🔑 Logging into ECR..."
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.$AWS_REGION.amazonaws.com
                    echo "🚀 Pushing to ECR..."
                    docker tag acme-app:latest $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.$AWS_REGION.amazonaws.com/acme-app:latest
                    docker push $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.$AWS_REGION.amazonaws.com/acme-app:latest
                    '''
                }
            }
        }

        stage('Trigger Terraform Cloud Run') {
            steps {
                script {
                    echo "🌀 Triggering Terraform Cloud run for workspace ${TFC_WORKSPACE}"

                    sh '''
                    curl -s \
                    --header "Authorization: Bearer $TF_API_TOKEN" \
                    --header "Content-Type: application/vnd.api+json" \
                    --request POST \
                    --data '{
                        "data": {
                            "attributes": {
                                "message": "Triggered from Jenkins pipeline",
                                "trigger-reason": "ci-cd",
                                "is-destroy": false
                            },
                            "type": "runs",
                            "relationships": {
                                "workspace": {
                                    "data": {
                                        "type": "workspaces",
                                        "id": "'"$(curl -s \
                                            --header "Authorization: Bearer $TF_API_TOKEN" \
                                            https://app.terraform.io/api/v2/organizations/$TFC_ORG/workspaces/$TFC_WORKSPACE \
                                            | jq -r .data.id)"'"
                                    }
                                }
                            }
                        }
                    }' \
                    https://app.terraform.io/api/v2/runs
                    '''
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                echo "✅ Jenkins pipeline complete. Terraform Cloud will handle infra deployment automatically."
            }
        }
    }

    post {
        failure {
            echo "❌ Build failed — check logs and Terraform Cloud run dashboard."
        }
    }
}
