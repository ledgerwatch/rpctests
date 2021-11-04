pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }

    stages {
        stage('Build') {

            input {
                message "Please enter an Erigon branch you wish to test:"
                parameters{
                    string(name: 'BRANCH', defaultValue: 'devel', description: 'Erigon branch name')
                }
            }

            steps {
                sh "./build.sh --branch=$BRANCH"
            }

        }

        stage('Restart') { // restart erigon and rpcdaemon if they are running
            steps{
                sh "sudo ./restart.sh --buildid=${env.BUILD_ID}" 
            }
        }

        stage('Test') {
            steps{
                script {
                    def date = new Date()
                    println date.format("yyMMdd_HHmmSS", TimeZone.getTimeZone('UTC'))
                }
                sh "sudo ./run_tests.sh --buildid=${env.BUILD_ID}"
            }
        }

        // stage('Deploy') {
        //     steps{
        //         sh "./deploy.sh --buildid=${env.BUILD_ID}"
        //     }
        // }
    }

}
