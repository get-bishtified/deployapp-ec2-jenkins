pipeline {
  agent any

  environment {
    TF_DIR = 'terraform'
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

    stage('Deploy to EC2 (Build & Run on EC2)') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {

          script {
            def ip = sh(
              script: "cd terraform && terraform output -raw public_ip",
              returnStdout: true
            ).trim()

            sh """
              ssh -o StrictHostKeyChecking=no ec2-user@${ip} << 'EOF'
                set -e

                echo "Connected to EC2"

                if ! command -v docker >/dev/null 2>&1; then
                  echo "Docker not found"
                  exit 1
                fi

                APP_DIR=/home/ec2-user/demo-app

                if [ ! -d "\$APP_DIR" ]; then
                  git clone https://github.com/get-bishtified/deployapp-ec2-jenkins.git \$APP_DIR
                fi

                cd \$APP_DIR/app

                docker build -t python-jenkins-app .
                docker rm -f python-app || true
                docker run -d -p 5000:5000 --name python-app python-jenkins-app

                echo "Application deployed successfully"
              EOF
            """
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Deployment completed successfully'
    }
    failure {
      echo 'Deployment failed'
    }
  }
}
