pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // שלב זה מושך את הקוד מה-Git שהגדרנו ב-Job
                checkout scm
            }
        }
        stage('Verify Environment') {
            steps {
                sh 'java -version'
                sh 'terraform -version'
            }
        }
    }
}