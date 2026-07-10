pipeline {

    agent any

    environment {
        DOCKER_USERNAME = "thesanketpawar"
        IMAGE_NAME      = "flask-app"
        IMAGE_TAG       = "${BUILD_NUMBER}"

        NAMESPACE       = "demo"
        DEPLOYMENT      = "flask-app"
        CONTAINER       = "flask-app"
    }

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Checkout Source') {
            steps {
                echo "Checking out source code..."
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker Image..."

                sh """
                docker build \
                -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                application
                """
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {

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
                echo "Pushing Docker Image..."

                sh """
                docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {

                echo "Applying Kubernetes manifests..."

                sh """
                kubectl apply -f kubernetes/namespace.yml
                kubectl apply -f kubernetes/deployment.yml
                kubectl apply -f kubernetes/service.yml
                """

                echo "Updating Deployment Image..."

                sh """
                kubectl set image deployment/${DEPLOYMENT} \
                ${CONTAINER}=${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                -n ${NAMESPACE}
                """

            }
        }

        stage('Verify Rollout') {
            steps {

                sh """
                kubectl rollout status deployment/${DEPLOYMENT} \
                -n ${NAMESPACE}
                """

            }
        }

        stage('Verify Deployment') {
            steps {

                sh """
                kubectl get deployments -n ${NAMESPACE}
                kubectl get pods -o wide -n ${NAMESPACE}
                kubectl get svc -n ${NAMESPACE}
                """

            }
        }

    }

    post {

        success {
            echo "Application deployed successfully."
        }

        failure {
            echo "Pipeline failed."
        }

        always {

            echo "Cleaning Docker images..."

            sh """
            docker image prune -f
            """

        }
    }
}
