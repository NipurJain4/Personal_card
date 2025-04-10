pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '897729121177'
        ECR_REPO_NAME = 'profilecard'
        ECR_URI = "897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard"
        EC2_HOST = "ec2-43-204-96-219.ap-south-1.compute.amazonaws.com"
        EC2_USER = "ubuntu"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh "docker build -t pcard ."
                echo "✅ Image built"
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh "docker tag pcard ${ECR_URI}"
                echo "✅ Image tagged"
            }
        }

        stage('Login to ECR') {
            steps {
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}"
                echo "✅ Logged in to ECR"
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh "docker push ${ECR_URI}"
                echo "✅ Image pushed to ECR"
            }
        }

        stage('Deploy to EC2') {
            steps {
                // Use Jenkins SSH credentials (e.g., ID = 'nipur-ssh-key')
                sshagent(['nipur-ssh-key']) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                        echo "🔐 SSH into EC2 success"
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}
                        docker rm -f card || true
                        docker pull ${ECR_URI}
                        docker run -d -p 3000:80 --name card ${ECR_URI}
                        EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Application deployed successfully to EC2 on port 3000!"
        }
        failure {
            echo "❌ Deployment failed. Check Jenkins console logs for details."
        }
    }
}
