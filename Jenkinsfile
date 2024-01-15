pipeline {
    agent any
    environment {
        TF_IN_AUTOMATION = 'true'
        TF_CLI_CONFIG_FILE = credentials('Terraform_login')
        TF_CLI_CONFIG_FILE = credentials('AWS_KEYS')
    }
    stages {
        stage('Init') {
            steps {
                sh 'ls'
                sh 'TF_IN_AUTOMATION=true'
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                withAWS(credentials: 'AWS_KEYS', region: 'us-east-2') (
                    sh 'TF_IN_AUTOMATION=true'
                    sh 'terraform plan -no-color'
                )
               
            }
        }
    }
}