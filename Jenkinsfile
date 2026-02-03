pipeline {
    agent any
    
    parameters {
        //  Destroy 
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check to destroy infrastructure instead of creating it')
    }

    stages {
        stage('Checkout') {
            steps {
               // Checkout repositories
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Infrastructure Execution') {
            steps {
                script {
                    if (params.DESTROY_INFRA) {
                        //  ( - Destroy stage)
                        sh 'terraform destroy -auto-approve'
                    } else {
                        // (infrastructure provisioning)
                        sh 'terraform apply -auto-approve'
                    }
                }
            }
        }

        stage('Plugin Validation') {
            when {
                expression { params.DESTROY_INFRA == false }
            }
            steps {
                script {
                    // ( Passing Terraform outputs)
                    def serverIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    
                    // ( vulnerable instance deployment & verification)
                    sh "python3 CTFd/plugins/reachability_validator/__init__.py ${serverIp}"
                }
            }
        }
    }

    post {
        //Clear logs and failure handling
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check Terraform logs or connectivity."
        }
    }
}
