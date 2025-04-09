pipeline {
    agent any

    stages {
        stage('building docker image') {
            steps {
                sh "docker build -t PCard ."
                echo "building success"
            }
        }
         stage('running the container') {
            steps {
                sh "docker run -d -p 3000:80 my-card ."
                echo "running container success"
            }
        }
    }
}
