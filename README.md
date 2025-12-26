🚀 Jenkins CI/CD for Containerized AWS Deployments
(Docker • Terraform • ECR • ECS)

This repository demonstrates production-style CI/CD pipelines using Jenkins to build, push, and deploy Python applications as containers on AWS.

The focus is on modern container workflows, using Terraform, Amazon ECR, and Amazon ECS (Fargate)—not legacy EC2-based deployments.

🧠 What This Repository Covers

✔ Jenkins Declarative Pipelines
✔ Dockerized Python applications
✔ Infrastructure as Code using Terraform
✔ Secure AWS access using IAM Roles
✔ Amazon ECR for container images
✔ Amazon ECS (Fargate) for deployment
✔ Parameter-based Apply / Destroy workflows

🏗️ Supported Deployment Models
1️⃣ Jenkins + Terraform + Docker (Build Stage)

Jenkins builds a Docker image for a Python application

Image is versioned and prepared for deployment

Same Docker image used across environments

Use case: Standardized container builds

2️⃣ Jenkins + Terraform + ECR + ECS (Fargate)

Jenkins builds Docker image

Pushes image to Amazon ECR

Terraform deploys application to Amazon ECS (Fargate)

Jenkins supports Apply / Destroy using parameters

Use case:
✔ Production-grade deployments
✔ Serverless containers (no EC2 management)

🧩 High-Level Architecture
GitHub
  ↓
Jenkins (CI/CD)
  ├── Docker Build
  ├── Push Image to ECR
  └── Terraform
        ├── APPLY  → Deploy ECS
        └── DESTROY → Tear Down
  ↓
Amazon ECS (Fargate)

📁 Repository Structure
.
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── terraform/
│   ├── provider.tf
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   └── outputs.tf
│
└── Jenkinsfile

🔐 Security Best Practices Used

✅ IAM Roles for Jenkins (no AWS access keys)

✅ No secrets in Jenkinsfile

✅ Terraform .tfvars for environment config

✅ Parameter-based approval (no input() issues)

▶️ Jenkins Pipeline Controls
Deploy Infrastructure & App
Build with Parameters → ACTION=apply

Destroy Infrastructure
Build with Parameters → ACTION=destroy


This approach avoids Jenkins UI deadlocks and is CI/CD friendly.

🧪 Jenkins Patterns Used

Declarative pipelines

Docker build & push

Terraform lifecycle management

Environment isolation using tfvars

Idempotent deployments

🧠 Interview-Ready Summary

“This project demonstrates a Jenkins-driven CI/CD pipeline that builds Docker images, pushes them to Amazon ECR, and deploys containerized applications on Amazon ECS Fargate using Terraform.”

🛠️ Prerequisites

- Jenkins (running on Linux agents or an EC2 node that supports `sh` steps)
- Docker (for local image builds if used on the agent)
- Terraform (or use a Terraform container/agent)
- AWS CLI (optional, for local testing)

Jenkins credentials required for this repo:
- **SSH key** credential id: `ec2-ssh-key` — private key used by the pipeline to SSH into the target EC2 instance

Option A — IAM instance role (recommended):
- Attach an IAM Role to the Jenkins server with the required Terraform permissions (ECR, ECS, IAM, CloudWatch, VPC etc.). When using an instance profile, Terraform on the Jenkins agent will pick up credentials automatically and **no `aws-credentials` binding is required**.

Option B — Static AWS credentials (optional):
- If you cannot use an instance role, you can add an AWS access key/secret Jenkins credential with id `aws-credentials` and update the pipeline to use that binding (not required for instance-role setups).

Note: The pipeline's EC2-based deployment stage clones the repo and builds/runs the Docker image on the target host via SSH (requires `ec2-user` to have `sudo` for Docker or to be in the `docker` group).

**Local testing:** To build images locally, ensure your Docker daemon is running (e.g., Docker Desktop on Windows). Alternatively run the build on a Linux Jenkins agent or use a Terraform/CI container that includes the required tools.

🚀 When to Use This Approach
Requirement	Solution
Containerized apps	Docker
Secure image storage	ECR
Serverless containers	ECS Fargate
Repeatable infra	Terraform
Safe approvals	Jenkins parameters
🏁 Final Notes

This repository is designed to reflect:

Modern DevOps practices

Production-ready container deployments

Secure AWS authentication

Clean, maintainable Jenkins pipelines