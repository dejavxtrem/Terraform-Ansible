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
                sh 'cat $BRANCH_NAME.tfvars'
                sh 'terraform init -no-color'
            }
        }
        stage('Plan') {
            steps {
                sh 'terraform plan -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }
        stage('validate apply') {
            when {
                beforeInput true
                branch "devbranch"
            }
            input {
                message "Do you want to apply this plan"
                ok "Apply this plan."
            }
            steps {
                echo 'Apply Accepted'
            }
        }
        stage('Apply') {
            steps {
                sh 'terraform apply -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }
        stage ('Ec2 Wait') {
            steps {
                sh 'aws ec2 wait instance-status-ok --region us-east-2'
            }
        }
        stage ('validate ec2 provision') {
            input {
                message "Do you want to run Ansible?"
                ok "Run Ansible"
            }
            steps {
                echo 'Ansible Approved'
            }
        }
        stage('Ansible') {
            steps {
                ansiblePlaybook(credentialsId: 'SSH-private-key' , inventory: 'aws_hosts' , playbook: 'playbooks/main-playbook.yml')
            }
        }
        stage('Validate Destroy') {
            input {
                message "Do you want to destroy?"
                ok "Destroy"
            }
            steps {
                echo 'Destroy Approved'
            }
        }
        stage('Destroy') {
            steps {
                sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
            }
        }
    }
    post {
        success {
            echo 'Success!'
        }
        failure {
            sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
        }
        aborted {
        sh 'terraform destroy -auto-approve -no-color -var-file="$BRANCH_NAME.tfvars"'
    }
    }
    
}