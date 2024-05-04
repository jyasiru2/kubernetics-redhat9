pipeline {
  agent any

  stages {

    stage('Build Artifact - Maven') {
      steps {
        sh "mvn clean package -DskipTests=true"
        archive 'target/*.jar'
      }
    }

    stage('Unit Tests - JUnit and Jacoco') {
      steps {
        sh "mvn test"
      }
      post {
        always {
          junit 'target/surefire-reports/*.xml'
          jacoco execPattern: 'target/jacoco.exec'
        }
      }
    }
    stage('Mutation Tests - PIT') {
      steps {
        sh "mvn org.pitest:pitest-maven:mutationCoverage"
      }
      post {
        always {
          pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
        }
      }
    }

    stage('SCM') {
      steps {
        checkout scm
      }
    }

    stage('SonarQube Analysis') {
      steps {
        script {
          def mvn = tool 'Default Maven';
          withSonarQubeEnv() {
            sh "${mvn}/bin/mvn clean verify sonar:sonar -Dsonar.projectKey=NumericApplication -Dsonar.projectName='NumericApplication'"
          }
        }
      }
    }

    stage('Docker Build and Push') {
      steps {
        script {
          withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
            sh 'printenv'
            sh "docker build -t yasiru1997/numeric-app2:${GIT_COMMIT} ."
            sh "docker push yasiru1997/numeric-app2:${GIT_COMMIT}"
          }
        }
      }
    }

    stage('Kubernetes Deployment - DEV') {
      steps {
        script {
          withKubeConfig([credentialsId: 'kubeconfig']) {
            sh '''sed -i "s|yasiru1997/numeric-app2:PLACEHOLDER|yasiru1997/numeric-app2:${GIT_COMMIT}|g" k8s_deployment_service.yaml'''
            sh "kubectl apply -f k8s_deployment_service.yaml"
          }
        }
      }
    }
  }
}
