pipeline {
    agent any
    
    parameters {
        booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check this to destroy infrastructure')
    }

    // זה החלק שהיה חסר ומקשר בין ה-Credentials ל-Pipeline
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'eu-central-1' 
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
                        // הוספת -input=false כדי למנוע מהתהליך להמתין לקלט ידני
                        sh 'terraform apply -auto-approve -parallelism=1 -input=false'
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
