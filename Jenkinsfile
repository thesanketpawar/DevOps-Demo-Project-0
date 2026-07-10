pipeline {

    agent any

    environment {
        DOCKER_USERNAME = "thesanketpawar"
        IMAGE_NAME      = "flask-app"
        NAMESPACE       = "demo"
        DEPLOYMENT      = "flask-deployment"
        CONTAINER       = "flask"
        IMAGE_TAG       = "${BUILD_NUMBER}"
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
                echo "Building Docker image..."

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

                echo "Pushing image to Docker Hub..."

                sh """
                docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Check Namespace') {

            steps {

                script {

                    def exists = sh(
                        script: "kubectl get namespace ${NAMESPACE} --ignore-not-found",
                        returnStdout: true
                    ).trim()

                    if (!exists) {

                        echo "Namespace not found. First deployment."

                        sh """
                        kubectl apply -f kubernetes/namespace.yaml
                        kubectl apply -f kubernetes/deployment.yaml
                        kubectl apply -f kubernetes/service.yaml
                        """

                    } else {

                        echo "Namespace already exists."

                    }

                }

            }

        }

        stage('Update Deployment Image') {

            steps {

                echo "Updating deployment image..."

                sh """
                kubectl set image deployment/${DEPLOYMENT} \
                ${CONTAINER}=${DOCKER_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG} \
                -n ${NAMESPACE}
                """

            }

        }

        stage('Verify Rollout') {

            steps {

                echo "Waiting for rollout..."

                sh """
                kubectl rollout status deployment/${DEPLOYMENT} \
                -n ${NAMESPACE}
                """

            }

        }

        stage('Verify Pods') {

            steps {

                sh """
                kubectl get pods -n ${NAMESPACE}
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

            echo "Cleaning unused Docker images..."

            sh "docker image prune -f"

        }

    }

}
