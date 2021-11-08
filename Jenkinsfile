pipeline {
    agent any

    tools {
        go 'go-1.17.2'
    }

    environment {
        STOP_ONLY = 'stop only'
        RESTART = 'restart'
        RESTART_NEW_BRANCH = 'restart with new branch'
    }

    parameters{
        choice(name: 'OPTION', choices: [
            'stop only', 
            'restart', 
            'restart with new branch'], 
            description: 'What can I do for you?')
    }


    stages {

        stage('Stop Erigon and RPCdaemon') {

            when {
                expression {
                    "${params.OPTION}" == 'stop' 
                }
            }

            steps {
                script {
                    println "----------------- Stop Erigon and RPCdaemon -----------------"
                }
                // sh "./start_stop.sh"
                echo "Choice: ${params.OPTION}"
            }
        }

        stage('Build') {

            steps {
                script {
                    println "----------------- Build Stage -----------------"
                }
                // sh "./build.sh --branch=$BRANCH"
                echo "Choice: ${params.OPTION}"
            }

        }

        stage('(Re)Start') { // restart erigon and rpcdaemon if they are running

            steps{
                script {
                    println "----------------- (Re)Start Stage -----------------"
                }
                echo "Choice: ${params.OPTION}"
                // sh "sudo ./restart.sh --url=${env.JENKINS_URL}" 
            }
        }

    }

}
