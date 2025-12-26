pipeline {
  agent any

  parameters {
    booleanParam(
      name: 'TAINT_RESOURCE',
      defaultValue: true,
      description: 'Taint EC2 resource before terraform apply'
    )
    string(
      name: 'TAINT_TARGET',
      defaultValue: 'aws_instance.app_ec2',
      description: 'Terraform resource to taint'
    )
  }

  environment {
    TF_DIR = 'terraform'
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
        expression { params.TAINT_RESOURCE }
      }
      steps {
        dir(TF_DIR) {
          sh "terraform taint ${params.TAINT_TARGET}"
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

    stage('Deploy to EC2 (Docker on EC2 only)') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          script {
            def ip = sh(
              script: "cd terraform && terraform output -raw public_ip",
              returnStdout: true
            ).trim()

            sh """
ssh -o StrictHostKeyChecking=no ec2-user@${ip} "bash -l" <<EOF
set -e

echo "Connected to target EC2"
which docker
docker --version

APP_DIR=/home/ec2-user/demo-app

if [ ! -d "\$APP_DIR" ]; then
  git clone https://github.com/get-bishtified/deployapp-ec2-jenkins.git \$APP_DIR
fi

cd \$APP_DIR/app

docker build -t python-jenkins-app .
docker rm -f python-app || true
docker run -d -p 5000:5000 --name python-app python-jenkins-app

echo "Application deployed successfully on EC2"
EOF
"""
          }
        }
      }
    }
  }
}
