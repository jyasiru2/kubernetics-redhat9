pipeline {
    agent any

    stages {
        // Stage to build the Maven artifact
        stage('Build Artifact - Maven') {
            steps {
                sh "mvn clean package -DskipTests=true" // Clean and package the Maven project
                archiveArtifacts 'target/*.jar' // Archive the built JAR artifact
            }
        }

        // Stage to run unit tests using JUnit and Jacoco for code coverage
        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test" // Run unit tests
            }
        }

        // Stage to perform vulnerability scan using Dependency Check
        stage('Vulnerability Scan - Dependency Check') {
            steps {
                sh "mvn dependency-check:check" // Run Dependency Check for vulnerability scanning
            }
        }

        // Stage to perform vulnerability scan on Docker images
        stage('Vulnerability Scan - Docker') {
            steps {
                parallel( // Run scans in parallel
                    "Dependency Scan": {
                        sh "mvn dependency-check:check" // Dependency Check for Docker
                    },
                    "Trivy Scan": {
                        sh "bash trivy-docker-image-scan.sh" // Trivy scan for Docker images
                    },
                    "OPA Conftest": {
                        sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile' // OPA Conftest for Dockerfile security
                    }
                )
            }
        }

        // Stage to checkout source code from the version control system
        stage('SCM Checkout') {
            steps {
                checkout scm // Checkout the source code
            }
        }

        // Stage to build and push Docker image
        stage('Docker Build and Push') {
            steps {
                script {
                    withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                        sh 'printenv' // Print environment variables
                        sh "sudo docker build -t yasiru1997/numeric-app2:${GIT_COMMIT} ." // Build Docker image
                        sh "docker push yasiru1997/numeric-app2:${GIT_COMMIT}" // Push Docker image to registry
                    }
                }
            }
        }

        // Stage to run mutation tests using PIT
        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage" // Run mutation tests
            }
        }

        stage('Vulnerability Scan - Kubernetes(k8s)') {
              steps {
                sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
              }
            }

        // Stage to deploy to Kubernetes environment (DEV)
        stage('Kubernetes Deployment - DEV') {
            steps {
                script {
                    withKubeConfig([credentialsId: 'kubeconfig']) {
                        sh '''sed -i "s|yasiru1997/numeric-app2:PLACEHOLDER|yasiru1997/numeric-app2:${GIT_COMMIT}|g" k8s_deployment_service.yaml''' // Replace placeholder with image tag
                        sh "kubectl apply -f k8s_deployment_service.yaml" // Apply Kubernetes deployment
                    }
                }
            }
        }
    }

    post {
        always {
            junit 'target/surefire-reports/*.xml' // Publish JUnit test results
            jacoco(execPattern: 'target/jacoco.exec') // Publish Jacoco code coverage report
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml' // Publish Dependency Check report
            pitmutation killRatioMustImprove: false, minimumKillRatio: 50.0 // Publish PIT mutation test results
        }
    }
}
//