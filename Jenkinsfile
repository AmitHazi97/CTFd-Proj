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
                sh 'terraform init'
            }
        }

        stage('Infrastructure Execution') {
            steps {
                script {
                    if (params.DESTROY_INFRA) {
                        echo "Starting infrastructure destruction flow..."
                        // Using parallelism=1 to prevent t2.micro CPU exhaustion
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
                    // Critical: Wait for system stability before running scripts on a weak instance
                    echo "Waiting 15 seconds for system stability..."
                    sleep 15
                    
                    echo "Fetching dynamic Public IP from Terraform outputs..."
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    
                    echo "Running Reachability Plugin for Target IP: ${serverIp}"
                    
                    // Safety: Prevent the pipeline from hanging indefinitely if the target is unreachable
                    timeout(time: 2, unit: 'MINUTES') {
                        sh "python3 CTFd/plugins/reachability_validator/__init__.py ${serverIp}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! All requirements for Section 6 are met."
        }
        failure {
            echo "Pipeline failed. Check Terraform logs or connectivity to the target instance."
        }
    }
}
