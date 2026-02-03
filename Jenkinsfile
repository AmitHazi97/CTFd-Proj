pipeline {
    agent any
    
    parameters {
        // Allows controlling infrastructure destruction via the Jenkins UI
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure instead of creating it')
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
                // Initializing Terraform backend and downloading required providers
                sh 'terraform init'
            }
        }

        stage('Infrastructure Execution') {
            steps {
                script {
                    if (params.DESTROY_INFRA) {
                        echo "Starting infrastructure destruction flow..."
                        // Using parallelism=1 to ensure stability on AWS Free Tier (t3.micro)
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
                // Only run validation if we are not destroying the infrastructure
                expression { params.DESTROY_INFRA == false }
            }
            steps {
                script {
                    // Ensuring all Python dependencies are present on the Jenkins host
                    echo "Ensuring Python dependencies are installed (pip3 and Flask)..."
                    
                    // Using sudo with -y for automated installation, avoiding environment variable errors
                    sh "sudo apt-get update -y && sudo apt-get install -y python3-pip"
                    sh "pip3 install flask --user"
                    
                    // Waiting for the EC2 instance to finish its initial boot
                    echo "Waiting 15 seconds for system stability..."
                    sleep 15
                    
                    // Fetching the dynamic Public IP address from Terraform outputs
                    echo "Fetching dynamic Public IP from Terraform outputs..."
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    
                    echo "Running Reachability Plugin for Target IP: ${serverIp}"
                    
                    // Setting PYTHONPATH to include the current workspace so Python finds the CTFd module
                    timeout(time: 2, unit: 'MINUTES') {
                        sh "export PYTHONPATH=\$PYTHONPATH:\$(pwd) && python3 \$(find . -name '__init__.py' | grep reachability_validator) ${serverIp}"
                    }
                }
            }
        }
    }

    post {
        success {
            // Notification for a fully successful automation cycle
            echo "Pipeline completed successfully! All requirements for Section 6 are met."
        }
        failure {
            // Error handling notification
            echo "Pipeline failed. Check Terraform logs, Python dependencies, or target connectivity."
        }
    }
}
