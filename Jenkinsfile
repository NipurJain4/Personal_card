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
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    '''
                    echo "✅ Logged into ECR"
                }
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
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sshagent(['nipur-ssh-key']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                            echo "🔐 SSH into EC2 successful"

                            # Install AWS CLI if not present
                            if ! command -v aws &> /dev/null; then
                                echo "🛠 Installing AWS CLI..."
                                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                                unzip awscliv2.zip
                                sudo ./aws/install
                            fi

                            export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                            export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                            aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}

                            docker rm -f card || true
                            docker pull ${ECR_URI}
                            docker run -d -p 3000:3000 --name card ${ECR_URI}
                            EOF
                        """
                    }
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
