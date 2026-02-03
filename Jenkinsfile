pipeline {
    agent any
    
    //let me delete the old infrastructure
    parameters {
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure instead of creating it')
    }

    stages {
        stage('Checkout') {
            steps {
                //Pull new code
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
                        //against crashs 
                        echo "Destroying infrastructure..."
                        sh 'terraform destroy -auto-approve -parallelism=1'
                    } else {
                    
                        echo "Provisioning infrastructure..."
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
                    // take the new IP every time and save it
                    echo "Fetching dynamic IP from Terraform..."
                    def serverIp = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()
                    
                
                    echo "Running Reachability Plugin for IP: ${serverIp}"
                    sh "python3 CTFd/plugins/reachability_validator/__init__.py ${serverIp}"
                }
            }
        }
    }

    post {
        //  Clear logs and failure handling
        success {
            echo "Pipeline completed successfully! All stages passed."
        }
        failure {
            echo "Pipeline failed. Please check the Console Output for Terraform or Python errors."
        }
    }
}
