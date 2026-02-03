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
                    echo "Ensuring basic dependencies are installed..."
                    sh "sudo apt-get update -y && sudo apt-get install -y curl"
                    
                    // Waiting for the EC2 instance and user_data to finish booting
                    echo "Waiting 30 seconds for system stability and service startup..."
                    sleep 30
                    
                    // Fetching the dynamic Public IP address from Terraform outputs
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    echo "Validating reachability to: ${serverIp} on port 8000"
                    
                    // Reliable reachability check using curl
                    timeout(time: 2, unit: 'MINUTES') {
                        sh """
                            curl -s --connect-timeout 15 http://${serverIp}:8000 > /dev/null
                            if [ \$? -eq 0 ]; then
                                echo 'SUCCESS: Server is reachable and CTFd port is open!'
                            else
                                echo 'Checking if instance is at least pingable...'
                                ping -c 3 ${serverIp}
