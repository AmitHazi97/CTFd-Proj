pipeline {
    agent any
    
    parameters {
        // Allows controlling infrastructure destruction via the Jenkins UI
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure instead of creating it')
    }

    stages {
        stage('Checkout') {
            steps {
                // Pulling the latest code from the repository
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                // Initializing Terraform backend and providers
                sh 'terraform init'
            }
        }

        stage('Infrastructure Execution') {
            steps {
                script {
                    if (params.DESTROY_INFRA) {
                        echo "Starting infrastructure destruction flow..."
                        // Using parallelism=1 to prevent t2.micro CPU exhaustion on AWS Free Tier
                        sh 'terraform destroy -auto-approve -parallelism=1'
                    } else {
                        echo "Starting infrastructure provisioning flow..."
                        sh 'terraform apply -auto-approve -parallelism=1'
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
                    // Waiting for system stability to prevent the instance from freezing
                    echo "Waiting 15 seconds for system stability..."
                    sleep 15
                    
                    // Fetching the dynamic Public IP directly from Terraform outputs
                    echo "Fetching dynamic Public IP from Terraform outputs..."
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    
                    echo "Running Reachability Plugin for Target IP: ${serverIp}"
                    
                    timeout(time: 2, unit: 'MINUTES') {
                        // Dynamically locating the validator script to avoid path errors
                        sh "python3 \$(find . -name '__init__.py' | grep reachability_validator) ${serverIp}"
                    }
                }
            }
        }
    }

    post {
        success {
            // Success notification
            echo "Pipeline completed successfully! All requirements for Section 6 are met."
        }
        failure {
            // Failure notification with troubleshooting advice
            echo "Pipeline failed. Check Terraform logs or connectivity to the target instance."
        }
    }
}
