pipeline {
  agent any

  parameters {
    booleanParam(
      name: 'TAINT_RESOURCE',
      defaultValue: false,
      description: 'Taint EC2 resource before terraform apply (default: false)'
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

    stage('Verify Environment') {
      steps {
        sh '''
          echo "Checking required tools on agent..."
          terraform --version || echo "terraform not found; ensure the agent has terraform or use a terraform docker image as agent"
          ssh -V || true
          docker --version || echo "docker not found on agent (not required for remote EC2 deploy)"
        '''
      }
    }

    stage('Terraform Init') {
      steps {
        dir(TF_DIR) {
          sh '''
            if command -v aws >/dev/null 2>&1; then
              echo "AWS CLI found, caller identity:"
              aws sts get-caller-identity || true
            else
              echo "AWS CLI not installed; assuming Jenkins instance profile / role is used by Terraform"
            fi

            terraform init
          '''
        }
      }
    }

    stage('Terraform Taint (Optional)') {
      when {
        expression { params.TAINT_RESOURCE }
      }
      steps {
        dir(TF_DIR) {
          sh '''
            if command -v aws >/dev/null 2>&1; then
              echo "Running with Jenkins instance role (caller identity):"
              aws sts get-caller-identity || true
            else
              echo "AWS CLI not installed; proceeding and assuming instance role is available to Terraform"
            fi

            terraform taint ${params.TAINT_TARGET}
          '''
        }
      }
    }

    stage('Terraform Apply') {
      steps {
        dir(TF_DIR) {
          sh '''
            if command -v aws >/dev/null 2>&1; then
              echo "Verifying AWS caller identity before apply:"
              aws sts get-caller-identity || true
            else
              echo "AWS CLI not installed; terraform will rely on environment / instance role"
            fi

            terraform apply -auto-approve
          '''
        }
      }
    }

    stage('Deploy to EC2 (Docker runs ONLY on EC2)') {
      steps {
        sshagent(credentials: ['ec2-ssh-key']) {
          script {
            def ip = sh(
              script: "cd terraform && terraform output -raw public_ip",
              returnStdout: true
            ).trim()

            sh """
ssh -o StrictHostKeyChecking=no ec2-user@${ip} bash -lc '
set -e

echo "Connected to target EC2"
echo "PATH=\$PATH"

# Verify tools (must succeed)
docker --version
git --version

APP_DIR=/home/ec2-user/demo-app

if [ ! -d "\$APP_DIR" ]; then
  git clone https://github.com/get-bishtified/deployapp-ec2-jenkins.git \$APP_DIR
fi

cd \$APP_DIR/app

sudo docker build -t python-jenkins-app .
sudo docker rm -f python-app || true
sudo docker run -d -p 5000:5000 --name python-app python-jenkins-app

echo "Application deployed successfully on EC2"
'
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
