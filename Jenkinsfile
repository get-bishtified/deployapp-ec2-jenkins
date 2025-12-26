pipeline {
  agent any

  parameters {
    booleanParam(
      name: 'TAINT_EC2',
      defaultValue: true,
      description: 'Force recreate EC2 using terraform taint'
    )
  }

  environment {
    TF_DIR = "terraform"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Terraform Init') {
      steps {
        dir(TF_DIR) {
          sh 'terraform init'
        }
      }
    }

    stage('Terraform Taint (Optional)') {
      when {
        expression { params.TAINT_EC2 }
      }
      steps {
        dir(TF_DIR) {
          sh 'terraform taint aws_instance.app_ec2'
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(TF_DIR) {
          sh 'terraform apply -auto-approve'
        }
      }
    }

    stage('Deploy App to EC2') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          script {
            def ip = sh(
              script: "cd terraform && terraform output -raw public_ip",
              returnStdout: true
            ).trim()

            sh """
ssh -o StrictHostKeyChecking=no ec2-user@${ip} 'bash -lc "
set -e

echo Connected to EC2
docker --version
git --version

APP_DIR=/home/ec2-user/app

rm -rf \$APP_DIR
git clone ${env.GIT_URL} \$APP_DIR

cd \$APP_DIR/app

docker build -t demo-app .
docker rm -f demo-app || true
docker run -d -p 5000:5000 --name demo-app demo-app

echo Deployment completed
"'
"""
          }
        }
      }
    }
  }

  post {
    success {
      echo 'Pipeline completed successfully'
    }
    failure {
      echo 'Pipeline failed'
    }
  }
}
