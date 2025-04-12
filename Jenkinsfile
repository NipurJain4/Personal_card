@Library("sharedlib") _ 
pipeline {
    agent any

    environment {
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '897729121177'
        ECR_REPO_NAME = 'profilecard'
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
        EC2_HOST = "ec2-15-206-165-58.ap-south-1.compute.amazonaws.com"
        EC2_USER = "ubuntu"
    }

    stages {
        stage("hello from lib"){
            steps{
                script{
                    hello()
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script{
                    build("pcard")
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script{
                    tag_image("pcard", ECR_URI)
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script{
                    ecr_login(AWS_REGION, AWS_ACCOUNT_ID)
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
               script{
                push_image(ECR_URI)
               }
            }
        }

        stage('Deploy on EC2') {
            steps {
                script{
                    EC2_deploy(EC2_USER, EC2_HOST, ECR_URI, AWS_REGION, AWS_ACCOUNT_ID, ECR_REPO_NAME)
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
