pipeline {
    agent {label 'master'}

    triggers {
        // This trigger runs every 30 minutes (cron syntax)
        cron('H/30 * * * *')
    }

    stages {
        //stage('Checkout') {
           // steps {
                // Checkout the repository (make sure your GitHub credentials are configured in Jenkins)
               // git 'https://github.com/your-repository-url.git'
           // }
       // }

        stage('Run Auto Push Script') {
            steps {
                script {
                    // Ensure the script is executable
                    sh '''
                    chmod +x auto_push.sh
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
