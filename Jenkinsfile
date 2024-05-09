pipeline {
    agent any

    stages {
        stage('Build Artifact - Maven') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archiveArtifacts 'target/*.jar'
            }
        }

        stage('Unit Tests - JUnit and Jacoco') {
            steps {
                sh "mvn test"
            }
        }

//         stage('Vulnerability Scan - Dependency Check') {
//             steps {
//                 sh "mvn dependency-check:check"
//             }
//         }

//         stage('Vulnerability Scan - Docker') {
//             steps {
//                 parallel(
//                     "Dependency Scan": {
//                         sh "mvn dependency-check:check"
//                     },
//                     "Trivy Scan": {
//                         sh "bash trivy-docker-image-scan.sh"
//                     },
//                     "OPA Conftest": {
//                         sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
//                     }
//                 )
//             }
//         }

//         stage('SCM Checkout') {
//             steps {
//                 checkout scm
//             }
//         }

//         stage('Refactoring') {
//             steps {
//                 // Add your refactoring steps here
//             }
//         }

//         stage('Docker Build and Push') {
//             steps {
//                 script {
//                     withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
//                         sh 'printenv'
//                         sh "sudo docker build -t yasiru1997/numeric-app2:${GIT_COMMIT} ."
//                         sh "docker push yasiru1997/numeric-app2:${GIT_COMMIT}"
//                     }
//                 }
//             }
//         }

//         stage('Mutation Tests - PIT') {
//             steps {
//                 sh "mvn org.pitest:pitest-maven:mutationCoverage"
//             }
//         }

//         stage('Kubernetes Deployment - DEV') {
//             steps {
//                 script {
//                     withKubeConfig([credentialsId: 'kubeconfig']) {
//                         sh '''sed -i "s|yasiru1997/numeric-app2:PLACEHOLDER|yasiru1997/numeric-app2:${GIT_COMMIT}|g" k8s_deployment_service.yaml'''
//                         sh "kubectl apply -f k8s_deployment_service.yaml"
//                     }
//                 }
//             }
//         }
    }

//     post {
//         always {
//             junit 'target/surefire-reports/*.xml'
//             jacoco(execPattern: 'target/jacoco.exec')
//             dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//             pitmutation killRatioMustImprove: false, minimumKillRatio: 50.0
//             //pitMutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//         }
//     }
}
