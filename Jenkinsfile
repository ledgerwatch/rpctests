pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }

    stages {

        stage('Stop Erigon and RPCdaemon') {

            input {
                message "Would you like to stop Erigon and RPCdaemon?"
                parameters{
                    string(name: 'STOP', defaultValue: 'yes', description: 'This will just stop Ergion and RPCdaemon')
                }
            }

            when {
                expression {
                    "{$STOP}" == 'yes'
                }
            }

            steps {
                script {
                    println "----------------- Stop Erigon and RPCdaemon -----------------"
                }
                sh "./build.sh"
            }
        }

        // stage('Build') {

        //     input {
        //         message "Please enter an Erigon branch you wish to test:"
        //         parameters{
        //             string(name: 'BRANCH', defaultValue: 'stable', description: 'Erigon branch name')
        //         }
        //     }

        //     steps {
        //         script {
        //             println "----------------- Build Stage -----------------"
        //         }
        //         sh "./build.sh --branch=$BRANCH"
        //     }

        // }

        // stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

        //     steps{
        //         script {
        //             println "----------------- (Re)Start Stage -----------------"
        //         }

        //         sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
        //     }
        // }

    }

}
