pipeline {
    agent any

    environment{
        AWS_REGION = 'ap-south-1'
        AWS_ACCOUNT_ID = '8977-2912-1177'
        ECR_REPO_NAME = 'profilecard'
        ECR_URI ='897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard'
    }

    stages {
        stage('building docker image') {
            steps {
                sh "docker build -t pcard ."
                echo "building success"
            }
        }
        stage('Tag the image') {
            steps {
                sh "docker tag pcard 897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard"
                echo "tagging success"
            }
        }
        stage('login to ECR') {
            steps {
                sh "aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 897729121177.dkr.ecr.ap-south-1.amazonaws.com"
                echo "login success"
            }
        }
        stage('push the image') {
            steps {
                sh "docker push 897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard"
                echo "pushing success"
            }
        }
        stage('SSH to EC2 instance'){
            steps{
                sh 'sudo ssh -i "nipur.pem" ubuntu@ec2-43-204-96-219.ap-south-1.compute.amazonaws.com' <<EOF
                echo "ssh success"
            }
        }
        stage('pulling the image') {
            steps {
                sh "docker pull 897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard"
                echo "pulling success"
            }
        }
        stage('run the container') {
            steps {
                sh "docker run -d -p 3000:80 --name card 897729121177.dkr.ecr.ap-south-1.amazonaws.com/profilecard"
                echo "running container success"
            }
        }
    }
    post {
        success {
            echo "✅ Application deployed successfully to EC2!"
        }
        failure {
            echo "❌ Deployment failed. Check the Jenkins logs for more details."
        }
    }
}
