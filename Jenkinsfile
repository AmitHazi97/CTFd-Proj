pipeline {
    agent any
    
    parameters {
        // דרישת סעיף 6: שלב Destroy נשלט על ידי פרמטר
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check to destroy infrastructure instead of creating it')
    }

    stages {
        stage('Checkout') {
            steps {
                // משיכת הקוד מה-Git (סעיף 6 - Checkout repositories)
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
                        // שלב Destroy (סעיף 6 - Destroy stage)
                        sh 'terraform destroy -auto-approve'
                    } else {
                        // הקמת התשתית (סעיף 6 - infrastructure provisioning)
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
                    // העברת פלט Terraform לשכבת הפייתון (סעיף 6 - Passing Terraform outputs)
                    def serverIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    
                    // הרצת ה-Plugin (סעיף 6 - vulnerable instance deployment & verification)
                    sh "python3 CTFd/plugins/reachability_validator/__init__.py ${serverIp}"
                }
            }
        }
    }

    post {
        // דרישת סעיף 6: Clear logs and failure handling
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check Terraform logs or connectivity."
        }
    }
}