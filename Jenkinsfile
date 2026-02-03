pipeline {
    agent any
    
    parameters {
        // Toggle to destroy or create infrastructure
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure')
    }

    environment {
        // Injecting AWS Credentials from Jenkins Global Credentials Provider
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'eu-central-1' 
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulling the latest code from the GitHub repository
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initialize Terraform and download necessary providers/modules
                sh 'terraform init'
            }
        }

        stage('Infrastructure Execution') {
            steps {
                script {
                    if (params.DESTROY_INFRA) {
                        echo "Destroying infrastructure as requested..."
                        sh 'terraform destroy -auto-approve -parallelism=1'
                    } else {
                        echo "Applying infrastructure changes..."
                        // Using -input=false to prevent the pipeline from hanging on user prompts
                        sh 'terraform apply -auto-approve -parallelism=1 -input=false'
                    }
                }
            }
        }

        stage('Validation & Output') {
            when {
                expression { params.DESTROY_INFRA == false }
            }
            steps {
                script {
                    // Extracting the Public IP from Terraform Outputs
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    
                    echo "----------------------------------------------------"
                    echo "SUCCESS! Your CTF server is up at: http://${serverIp}:8000"
                    echo "----------------------------------------------------"
                    
                    // Giving Docker containers some time to initialize services
                    echo "Waiting 20 seconds for CTFd startup..."
                    sleep 20
                    
                    // Health check to verify port 8000 is reachable
                    sh "curl -s --connect-timeout 10 http://${serverIp}:8000 > /dev/null || echo 'Service is still initializing...'"
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Please review the logs above for troubleshooting."
        }
    }
}
