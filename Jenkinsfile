pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('Terraform_login')
        AWS_ACCESS_KEY_ID = credentials('AWS_KEYS')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_KEYS')
    }
    stages {
        stage('Init') {
            steps {
                sh 'ls'
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -no-color'
            }
        }
        stage('Apply') {
            steps {
                sh 'terraform apply -auto-approve -no-color'
            }
        }
        stage ('Ec2 Wait') {
            steps {
                sh 'aws ec2 wait instance-status-ok --region us-east-2'
            }
        }
        stage('Ansible') {
            steps {
                ansiblePlaybook(credentialsId: 'SSH-private-key' , inventory: 'aws_hosts' , playbook: 'playbooks/main-playbook.yml')
            }
        }
        stage('Destroy') {
            steps {
                sh 'terraform destroy -auto-approve -no-color'
            }
        }
    }
}