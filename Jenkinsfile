pipeline {
  agent any

  environment {
    TF_DIR  = 'terraform'
    APP_DIR = 'app'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init & Apply') {
      steps {
        dir(TF_DIR) {
          sh '''
            terraform init
            terraform apply -auto-approve
          '''
        }
      }
    }

    stage('Build Docker Image') {
      steps {
        dir(APP_DIR) {
          sh 'docker build -t python-jenkins-app .'
        }
      }
    }

    stage('Deploy to EC2') {
      steps {
        script {
          def ip = sh(
            script: "cd terraform && terraform output -raw public_ip",
            returnStdout: true
          ).trim()

          sh """
            ssh -o StrictHostKeyChecking=no ec2-user@${ip} << 'EOF'
              docker rm -f python-app || true
              docker run -d -p 5000:5000 --name python-app python-jenkins-app
            EOF
          """
        }
      }
    }
  }
}
