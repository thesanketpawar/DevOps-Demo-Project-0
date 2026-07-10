pipeline {

    agent any

    environment {
        DOCKER_USERNAME = "thesanketpawar"
        IMAGE_NAME = "flask-app"
        NAMESPACE = "devops-demo"
        DEPLOYMENT = "flask-app"
        CONTAINER = "flask-app"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t $DOCKER_USERNAME/$IMAGE_NAME:${BUILD_NUMBER} application
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo "$DOCKER_PASS" | docker login \
                    -u "$DOCKER_USER" \
                    --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh """
                docker push $DOCKER_USERNAME/$IMAGE_NAME:${BUILD_NUMBER}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {

                sh """
                kubectl set image deployment/$DEPLOYMENT \
                $CONTAINER=$DOCKER_USERNAME/$IMAGE_NAME:${BUILD_NUMBER} \
                -n $NAMESPACE
                """
            }
        }

        stage('Verify Rollout') {

            steps {

                sh """
                kubectl rollout status deployment/$DEPLOYMENT \
                -n $NAMESPACE
                """
            }

        }

    }

    post {

        success {

            echo "Deployment Successful"

        }

        failure {

            echo "Deployment Failed"

        }

        always {

            sh "docker image prune -f"

        }

    }

}
