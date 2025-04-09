pipeline {
    agent any

    stages {
        stage('building docker image') {
            steps {
                sh "docker build -t pcard ."
                echo "building success"
            }
        }
         stage('running the container') {
            steps {
                sh "docker run -d -p 3000:80 pcard ."
                echo "running container success"
            }
        }
    }
}
