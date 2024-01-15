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
    }
}