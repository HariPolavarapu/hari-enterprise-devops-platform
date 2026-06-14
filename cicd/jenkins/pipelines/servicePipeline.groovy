def servicePath = env.JOB_NAME.tokenize('/').last()
def services = [
  'employee-service': 'applications/employee-java-service',
  'notification-service': 'applications/notification-python-service',
  'payroll-service': 'applications/payroll-dotnet-service',
  'frontend': 'applications/frontend-angular'
]
def context = services[servicePath]

if (!context) {
  error "Unsupported service job: ${servicePath}"
}

pipeline {
  agent any
  stages {
    stage('Build and test') {
      steps {
        dir(context) {
          script {
            if (servicePath == 'employee-service') sh 'mvn -B clean verify'
            if (servicePath == 'notification-service') sh 'pip install -r requirements.txt && pytest'
            if (servicePath == 'payroll-service') sh 'dotnet build --configuration Release'
            if (servicePath == 'frontend') sh 'npm install && npm run build'
          }
        }
      }
    }
    stage('Build image') {
      steps {
        sh "docker build -t ${servicePath}:${env.BUILD_NUMBER} ${context}"
      }
    }
    stage('Scan image') {
      steps {
        sh "trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed ${servicePath}:${env.BUILD_NUMBER}"
      }
    }
  }
}

return this
