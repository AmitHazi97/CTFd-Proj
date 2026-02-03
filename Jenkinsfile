pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure')
    }

    stages {
        stage('Checkout') {
            steps {
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
                        sh 'terraform destroy -auto-approve -parallelism=1'
                    } else {
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
                    sh "sudo apt-get update -y && sudo apt-get install -y curl"
                    echo "Waiting 30 seconds for service startup..."
                    sleep 30
                    def serverIp = sh(script: "terraform output -raw public_ip", returnStdout: true).trim()
                    echo "Validating reachability to: ${serverIp} on port 8000"
                    timeout(time: 2, unit: 'MINUTES') {
                        sh "curl -s --connect-timeout 15 http://${serverIp}:8000 > /dev/null || ping -c 3 ${serverIp}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs."
        }
    }
}
