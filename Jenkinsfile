pipeline {
    agent any

    environment {
        AWS_REGION = "us-west-2"
        TF_API_TOKEN = credentials('terraform-cloud-token')  // Jenkins Credential (Secret Text)
        TFC_ORG = "cloudgenius-acme"
        TFC_WORKSPACE = "cicd-using-jenkins-terraform-and-aws"
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
                    echo "🔍 Validating Terraform syntax..."
                    terraform fmt -check -recursive
                    terraform validate || true
                    '''
                }
            }
        }

        stage('Docker Build & Push to ECR') {
            steps {
                script {
                    sh '''
                    echo "🛠 Building Docker image..."
                    docker build -t acme-app:latest .

                    echo "🔑 Logging into ECR..."
                    AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
                    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    echo "🚀 Tagging and pushing image..."
                    docker tag acme-app:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/acme-app:latest
                    docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/acme-app:latest
                    '''
                }
            }
        }

        stage('Trigger Terraform Cloud Run') {
            steps {
                script {
                    echo "🌀 Triggering Terraform Cloud run for workspace ${TFC_WORKSPACE}..."

                    def workspace_id = sh(
                        script: '''
                        curl -s \
                        --header "Authorization: Bearer ${TF_API_TOKEN}" \
                        https://app.terraform.io/api/v2/organizations/${TFC_ORG}/workspaces/${TFC_WORKSPACE} | jq -r .data.id
                        ''',
                        returnStdout: true
                    ).trim()

                    def run_id = sh(
                        script: '''
                        curl -s \
                        --header "Authorization: Bearer ${TF_API_TOKEN}" \
                        --header "Content-Type: application/vnd.api+json" \
                        --request POST \
                        --data "{
                            \\"data\\": {
                                \\"attributes\\": {
                                    \\"message\\": \\"Triggered from Jenkins pipeline\\",
                                    \\"is-destroy\\": false
                                },
                                \\"type\\": \\"runs\\",
                                \\"relationships\\": {
                                    \\"workspace\\": {
                                        \\"data\\": {
                                            \\"type\\": \\"workspaces\\",
                                            \\"id\\": \\"${workspace_id}\\"
                                        }
                                    }
                                }
                            }
                        }" \
                        https://app.terraform.io/api/v2/runs | jq -r .data.id
                        ''',
                        returnStdout: true
                    ).trim()

                    echo "🧩 Terraform Cloud run triggered — Run ID: ${run_id}"

                    echo "⏳ Waiting for Terraform Cloud run to finish..."
                    sh '''
                    while true; do
                        STATUS=$(curl -s \
                            --header "Authorization: Bearer ${TF_API_TOKEN}" \
                            https://app.terraform.io/api/v2/runs/${run_id} | jq -r .data.attributes.status)
                        echo "Current run status: $STATUS"
                        if [ "$STATUS" = "applied" ] || [ "$STATUS" = "planned_and_finished" ]; then
                            echo "✅ Terraform apply completed successfully!"
                            break
                        elif [ "$STATUS" = "errored" ] || [ "$STATUS" = "canceled" ]; then
                            echo "❌ Terraform run failed or was canceled!"
                            exit 1
                        fi
                        sleep 20
                    done
                    '''
                }
            }
        }

        stage('Post-Deployment Info') {
            steps {
                echo "🎉 Jenkins pipeline complete. Terraform Cloud run applied successfully!"
                echo "Visit Terraform Cloud workspace for details:"
                echo "🔗 https://app.terraform.io/app/${TFC_ORG}/workspaces/${TFC_WORKSPACE}/runs"
            }
        }
    }

    post {
        failure {
