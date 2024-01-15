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
                sh 'terraform init'
            }
        }
        stage('Plan') {
            steps {
                withAWS(credentials: 'AWS_KEYS', region: 'us-east-2') (
                    sh 'terraform plan -no-color'
                )
               
            }
        }
    }
}