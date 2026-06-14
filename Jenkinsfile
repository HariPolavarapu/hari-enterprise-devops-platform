pipeline {
  agent any

  environment {
    AWS_REGION = credentials('aws-region')
    AWS_ACCOUNT_ID = credentials('aws-account-id')
    ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    IMAGE_TAG = "${env.GIT_COMMIT ?: env.BUILD_NUMBER}"
  }

  stages {
    stage('Validate') {
      parallel {
        stage('Java') {
          steps {
            dir('applications/employee-java-service') {
              sh 'mvn -B clean verify'
            }
          }
          post {
            always {
              junit 'applications/employee-java-service/target/surefire-reports/*.xml'
            }
          }
        }
        stage('Python') {
          steps {
            dir('applications/notification-python-service') {
              sh 'python -m venv .venv'
              sh '. .venv/bin/activate && pip install -r requirements.txt && pytest --junitxml=test-results.xml'
            }
          }
          post {
            always {
              junit 'applications/notification-python-service/test-results.xml'
            }
          }
        }
        stage('Dotnet') {
          steps {
            dir('applications/payroll-dotnet-service') {
              sh 'dotnet restore'
              sh 'dotnet build --configuration Release --no-restore'
            }
          }
        }
        stage('Frontend') {
          steps {
            dir('applications/frontend-angular') {
              sh 'npm install'
              sh 'npm run build'
            }
          }
        }
        stage('Infrastructure') {
          steps {
            dir('infrastructure/terraform') {
              sh 'terraform fmt -check -recursive'
              sh 'terraform init -backend=false'
              sh 'terraform validate'
            }
            sh 'helm lint gitops/helm-charts/*'
          }
        }
      }
    }

    stage('SonarQube') {
      steps {
        withSonarQubeEnv('sonarqube') {
          sh 'sonar-scanner -Dsonar.projectKey=enterprise-devops-platform'
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage('Build Images') {
      steps {
        sh '''
          docker build -t ${ECR_REGISTRY}/employee-service:${IMAGE_TAG} applications/employee-java-service
          docker build -t ${ECR_REGISTRY}/notification-service:${IMAGE_TAG} applications/notification-python-service
          docker build -t ${ECR_REGISTRY}/payroll-service:${IMAGE_TAG} applications/payroll-dotnet-service
          docker build -t ${ECR_REGISTRY}/frontend:${IMAGE_TAG} applications/frontend-angular
        '''
      }
    }

    stage('Trivy Gate') {
      steps {
        sh '''
          for image in employee-service notification-service payroll-service frontend; do
            trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed \
              ${ECR_REGISTRY}/${image}:${IMAGE_TAG}
          done
        '''
      }
    }

    stage('Publish ECR') {
      when {
        branch 'main'
      }
      steps {
        sh '''
          aws ecr get-login-password --region ${AWS_REGION} |
            docker login --username AWS --password-stdin ${ECR_REGISTRY}
          for image in employee-service notification-service payroll-service frontend; do
            docker push ${ECR_REGISTRY}/${image}:${IMAGE_TAG}
          done
        '''
      }
    }

    stage('Publish Java Artifact') {
      when {
        branch 'main'
      }
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'nexus-credentials',
          usernameVariable: 'NEXUS_USERNAME',
          passwordVariable: 'NEXUS_PASSWORD'
        )]) {
          dir('applications/employee-java-service') {
            sh 'mvn -B deploy -DskipTests -s ../../cicd/nexus/settings.xml'
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: '**/target/*.jar', allowEmptyArchive: true
      cleanWs()
    }
  }
}
