pipeline {
    agent any

    triggers {
        // This trigger runs every 30 minutes (cron syntax)
        cron('H/30 * * * *')
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout the repository (you need to ensure you have the correct SCM configured in Jenkins)
                git 'https://github.com/your-repository-url.git'
            }
        }

        stage('Run Auto Push Script') {
            steps {
                script {
                    // Make sure your script is in the repository or in a place Jenkins can access it
                    sh '''
                    # Ensure the script is executable
                    chmod +x auto_push.sh
                    
                    # Run the script
                    ./auto_push.sh
                    '''
                }
            }
        }
    }

    post {
        always {
            // Always run after the pipeline execution (for cleanup or logging)
            echo 'Pipeline execution complete.'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed. Check the logs.'
        }
    }
}
