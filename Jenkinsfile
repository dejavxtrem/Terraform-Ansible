pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('Terraform_login')
    }
    stages {
        stage('Init') {
            steps {
                sh 'ls'
                sh 'TF_IN_AUTOMATION=true'
            }
        }
        stage('Plan') {
            steps {
                sh 'TF_IN_AUTOMATION=true'
                sh 'terraform plan -no-color'
            }
        }
    }
}