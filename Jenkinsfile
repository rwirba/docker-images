pipeline {
    agent any

    environment {
        IMAGE_NAME = "secure-kafka-connect"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/rwirba/docker-images.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'sudo docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'
            }
        }

        stage('Scan with Trivy') {
            steps {
                sh 'sudo trivy image --severity CRITICAL,HIGH --exit-code 1 ${IMAGE_NAME}:${IMAGE_TAG}'
            }
        }
    }

    post {
        failure {
            echo "❌ Build failed due to critical vulnerabilities"
        }
        success {
            echo "✅ Build passed — no critical/high vulnerabilities found"
        }
    }
}
