pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '897729121177'
        ECR_REPO_NAME = 'profilecard'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
        EC2_HOST = "ec2-43-204-96-219.ap-south-1.compute.amazonaws.com"
        EC2_USER = "ubuntu"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh "docker build -t pcard ."
                echo "✅ Docker image built"
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh "docker tag pcard ${ECR_URI}"
                echo "✅ Docker image tagged"
            }
        }

        stage('Login to ECR') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                """
                echo "✅ Logged into ECR"
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                sh "docker push ${ECR_URI}"
                echo "✅ Image pushed to ECR"
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent(credentials: ['private-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                            echo "🔄 Stopping existing container (if any)..."
                            docker stop profilecard || true
                            docker rm profilecard || true

                            echo "🔐 Logging into ECR..."
                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                            echo "📥 Pulling image..."
                            docker pull ${ECR_URI}

                            echo "🚀 Running container..."
                            docker run -d -p 3000:3000 --name profilecard ${ECR_URI}
                        EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployed successfully to EC2 and running on port 3000!"
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins logs for more details."
        }
    }
}
