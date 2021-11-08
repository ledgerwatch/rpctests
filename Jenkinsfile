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
                    "$STOP" == 'yes'
                }
            }

            steps {
                script {
                    println "----------------- Stop Erigon and RPCdaemon -----------------"
                }
                sh "./start_stop.sh"
                env.STOP = "$STOP"
            }
        }

        stage('Build') {

            // when {
            //     expression {
            //         "$STOP" == 'no'
            //     }
            // }

            input {
                message "Please enter an Erigon branch you wish to test:"
                parameters{
                    string(name: 'BRANCH', defaultValue: 'stable', description: 'Erigon branch name')
                }
            }

            steps {
                script {
                    println "----------------- Build Stage -----------------"
                }
                // sh "./build.sh --branch=$BRANCH"
                echo "STOP=$env.STOP"
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            steps{
                script {
                    println "----------------- (Re)Start Stage -----------------"
                }
                echo "STOP=$env.STOP"
                // sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
            }
        }

    }

}
